package main

import (
	"bufio"
	"net"
)

// Per-connection wire size cap. The largest legitimate payload is a
// SAVE_MAP JSON blob; anything beyond saveMapMaxPayload is malformed
// or hostile and gets dropped at the scanner.
const networkMaxLineBytes = saveMapMaxPayload + 64*1024

func (g *Game) HandleConn(conn net.Conn) {
	defer conn.Close()

	out := make(chan string, 64)
	p := g.addPlayer(out)
	metricsConnOpened()
	mlog.Info("player connected",
		"id", p.ID,
		"remote", conn.RemoteAddr().String())
	defer func() {
		g.removePlayer(p.ID)
		metricsConnClosed()
		mlog.Info("player disconnected", "id", p.ID)
	}()

	writeDone := make(chan struct{})
	go func() {
		defer close(writeDone)
		w := bufio.NewWriter(conn)
		for msg := range out {
			if _, err := w.WriteString(msg); err != nil {
				return
			}
			if err := w.Flush(); err != nil {
				return
			}
		}
	}()

	scanner := bufio.NewScanner(conn)
	scanner.Buffer(make([]byte, 64*1024), networkMaxLineBytes)
	for scanner.Scan() {
		metricsLineObserved()
		g.handleLine(p, scanner.Text())
	}

	close(out)
	<-writeDone
}
