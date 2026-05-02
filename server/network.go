package main

import (
	"bufio"
	"fmt"
	"net"
	"strings"
	"sync/atomic"
	"time"
)

// Per-connection wire size cap. The largest legitimate payload is a
// SAVE_MAP JSON blob; anything beyond saveMapMaxPayload is malformed
// or hostile and gets dropped at the scanner.
const networkMaxLineBytes = saveMapMaxPayload + 64*1024

// Phase 5 — heartbeat. The server emits PING every heartbeatInterval and
// expects a PONG reply within heartbeatTimeout, otherwise the conn is
// torn down. Detecting a dead peer at the application layer matters
// because TCP RST can take minutes to surface (idle keepalive defaults
// are way longer than a game server can tolerate).
const (
	heartbeatInterval = 10 * time.Second
	heartbeatTimeout  = 30 * time.Second
	outQueueCapacity  = 64
)

func (g *Game) HandleConn(conn net.Conn) {
	defer conn.Close()

	// Phase 5 — TCP-NoDelay. Nagle adds visibly worse latency for the
	// short, frequent input/snapshot frames the engine ships, so we
	// disable it on every accepted connection. ListenTCP returns
	// *net.TCPConn; defensively type-assert in case of net.Pipe / test
	// fakes.
	if tcp, ok := conn.(*net.TCPConn); ok {
		_ = tcp.SetNoDelay(true)
	}

	out := make(chan string, outQueueCapacity)
	p := g.addPlayer(out)
	metricsConnOpened()
	mlog.Info("player connected",
		"id", p.ID,
		"remote", conn.RemoteAddr().String())
	defer func() {
		g.removePlayer(p.ID)
		metricsConnClosed()
		fmt.Printf(">>> player %d DISCONNECTED\n", p.ID)
		mlog.Info("player disconnected", "id", p.ID)
	}()

	// lastPong is read by the heartbeat goroutine and written by
	// handleLine when a PONG arrives. Atomic int64 is enough; we only
	// compare against time.Now and never reason about ordering.
	var lastPong atomic.Int64
	lastPong.Store(time.Now().UnixNano())
	p.lastPong = &lastPong

	writeDone := make(chan struct{})
	go func() {
		defer close(writeDone)
		w := bufio.NewWriter(conn)
		for msg := range out {
			// Phase 5 — observability: track outQueue depth so a
			// back-pressured peer surfaces in /metrics before a player
			// notices the lag. len(out) sampled before consuming the
			// frame is the count still queued behind us.
			metricsObserveOutQueueDepth(p.ID, len(out)+1)
			if _, err := w.WriteString(msg); err != nil {
				return
			}
			if err := w.Flush(); err != nil {
				return
			}
		}
	}()

	// Heartbeat goroutine. Sends PING every interval and rips down the
	// conn if no PONG has been observed within heartbeatTimeout.
	heartbeatStop := make(chan struct{})
	go func() {
		ticker := time.NewTicker(heartbeatInterval)
		defer ticker.Stop()
		for {
			select {
			case <-heartbeatStop:
				return
			case now := <-ticker.C:
				last := time.Unix(0, lastPong.Load())
				if now.Sub(last) > heartbeatTimeout {
					mlog.Warn("heartbeat timeout, closing conn",
						"id", p.ID, "since", now.Sub(last).String())
					_ = conn.Close()
					return
				}
				select {
				case out <- "PING\n":
				default:
					// outQueue full → peer is wedged; drop the conn.
					mlog.Warn("outQueue full on PING, closing conn",
						"id", p.ID)
					_ = conn.Close()
					return
				}
			}
		}
	}()

	scanner := bufio.NewScanner(conn)
	scanner.Buffer(make([]byte, 64*1024), networkMaxLineBytes)
	for scanner.Scan() {
		metricsLineObserved()
		line := scanner.Text()
		if isHeartbeatLine(line) {
			handleHeartbeatLine(line, &lastPong, out)
			continue
		}
		g.handleLine(p, line)
	}
	if err := scanner.Err(); err != nil {
		fmt.Printf(">>> scanner error player=%d err=%v\n", p.ID, err)
	}
	fmt.Printf(">>> scanner EOF player=%d\n", p.ID)

	close(heartbeatStop)
	close(out)
	<-writeDone
	metricsClearOutQueue(p.ID)
}

// isHeartbeatLine recognises the two heartbeat verbs without going
// through the full parser. The hot path stays cheap and a misbehaving
// client cannot inject heartbeat-only frames into gameplay state.
func isHeartbeatLine(line string) bool {
	return line == "PING" || line == "PONG" ||
		strings.HasPrefix(line, "PING ") || strings.HasPrefix(line, "PONG ")
}

func handleHeartbeatLine(line string, lastPong *atomic.Int64, out chan<- string) {
	if line == "PONG" || strings.HasPrefix(line, "PONG ") {
		lastPong.Store(time.Now().UnixNano())
		return
	}
	// Client-initiated PING — reply with PONG so symmetric clients can
	// also detect a dead server.
	select {
	case out <- "PONG\n":
	default:
	}
}
