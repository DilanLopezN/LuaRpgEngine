// loadtest fan-outs N TCP connections to a running LuaRpgEngine
// server and replays randomized player input (NAME/MOVE/ATTACK) so the
// host can be profiled under realistic load. Useful for the Phase 5
// performance work — pair with `go tool pprof -http=:8080 cpu.prof`
// after the run completes.
//
// Usage:
//
//	go run ./cmd/loadtest -addr 127.0.0.1:7777 -bots 100 -duration 30s
//
// The bots intentionally do nothing destructive: they walk in random
// directions, basic-attack on cooldown, and disconnect cleanly when
// the duration elapses.
package main

import (
	"bufio"
	"context"
	"flag"
	"fmt"
	"math/rand"
	"net"
	"os"
	"os/signal"
	"sync"
	"sync/atomic"
	"syscall"
	"time"
)

func main() {
	addr := flag.String("addr", "127.0.0.1:7777", "server address")
	bots := flag.Int("bots", 50, "concurrent bot connections")
	duration := flag.Duration("duration", 30*time.Second, "total run time")
	moveEvery := flag.Duration("move-every", 200*time.Millisecond, "per-bot move cadence")
	attackEvery := flag.Duration("attack-every", 800*time.Millisecond, "per-bot attack cadence")
	flag.Parse()

	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel()
	deadline, deadlineCancel := context.WithTimeout(ctx, *duration)
	defer deadlineCancel()

	var (
		linesIn  atomic.Int64
		linesOut atomic.Int64
		errs     atomic.Int64
		opened   atomic.Int64
	)

	var wg sync.WaitGroup
	for i := 0; i < *bots; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			conn, err := net.Dial("tcp", *addr)
			if err != nil {
				errs.Add(1)
				return
			}
			defer conn.Close()
			opened.Add(1)

			rd := bufio.NewReader(conn)
			done := make(chan struct{})
			go func() {
				defer close(done)
				for {
					_, err := rd.ReadString('\n')
					if err != nil {
						return
					}
					linesIn.Add(1)
				}
			}()

			fmt.Fprintf(conn, "NAME bot_%04d\n", id)
			linesOut.Add(1)

			r := rand.New(rand.NewSource(int64(id) ^ time.Now().UnixNano()))
			moveT := time.NewTicker(*moveEvery)
			defer moveT.Stop()
			attackT := time.NewTicker(*attackEvery)
			defer attackT.Stop()

			for {
				select {
				case <-deadline.Done():
					return
				case <-done:
					return
				case <-moveT.C:
					dx, dy := r.Intn(3)-1, r.Intn(3)-1
					fmt.Fprintf(conn, "MOVE %d %d\n", dx, dy)
					linesOut.Add(1)
				case <-attackT.C:
					fmt.Fprintf(conn, "ATTACK\n")
					linesOut.Add(1)
				}
			}
		}(i)
	}

	report := time.NewTicker(2 * time.Second)
	defer report.Stop()
	start := time.Now()
	go func() {
		for {
			select {
			case <-deadline.Done():
				return
			case <-report.C:
				elapsed := time.Since(start).Seconds()
				fmt.Fprintf(os.Stderr,
					"t=%.1fs bots=%d in=%d out=%d (%.0f/s out, %.0f/s in) errs=%d\n",
					elapsed, opened.Load(),
					linesIn.Load(), linesOut.Load(),
					float64(linesOut.Load())/elapsed,
					float64(linesIn.Load())/elapsed,
					errs.Load())
			}
		}
	}()

	wg.Wait()
	elapsed := time.Since(start).Seconds()
	fmt.Fprintf(os.Stderr,
		"DONE elapsed=%.1fs bots=%d in=%d out=%d errs=%d\n",
		elapsed, opened.Load(), linesIn.Load(), linesOut.Load(), errs.Load())
}
