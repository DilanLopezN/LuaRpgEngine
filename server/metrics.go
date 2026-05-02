package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"runtime"
	"sync"
	"sync/atomic"
	"time"
)

// Phase 5 — Observabilidade.
//
// Two pieces:
//
//   1. Structured logging (slog) wired against stderr. Every gameplay
//      log path that used `log.Printf` should call mlog.* — the leveled
//      output is JSON-friendly so a future shipper (loki, vector) can
//      consume it without parsing.
//
//   2. A tiny Prometheus-format /metrics endpoint exposed on a separate
//      HTTP listener. We hand-format the text exposition to keep the
//      server free of a runtime-only dependency on prometheus/client_golang.
//      The metric set is purposefully small: connection count, tick
//      throughput, message rate, and a few process gauges.

var (
	metricsConnTotal       atomic.Int64
	metricsConnActive      atomic.Int64
	metricsTickTotal       atomic.Int64
	metricsTickPlayersSeen atomic.Int64
	metricsLineTotal       atomic.Int64
	metricsLineDropped     atomic.Int64
	metricsBroadcasts      atomic.Int64
	metricsStartTime       = time.Now()

	// Phase 5 — per-player outQueue back-pressure tracking. We keep
	// a watermark per player so the gauge surfaces the worst-case
	// depth observed since reset rather than the instantaneous value
	// (which is almost always 0 because the writer drains fast).
	metricsOutQueueMu     sync.Mutex
	metricsOutQueueMax    = make(map[int]int)
	metricsOutQueueGlobal atomic.Int64
)

// mlog is the package-level slog handle. Subpackages should not need a
// separate logger — the engine is intentionally one binary.
var mlog *slog.Logger

func init() {
	level := slog.LevelInfo
	if os.Getenv("LOG_LEVEL") == "debug" {
		level = slog.LevelDebug
	}
	mlog = slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{Level: level}))
}

func metricsConnOpened()       { metricsConnTotal.Add(1); metricsConnActive.Add(1) }
func metricsConnClosed()       { metricsConnActive.Add(-1) }
func metricsLineObserved()     { metricsLineTotal.Add(1) }
func metricsLineDropObserved() { metricsLineDropped.Add(1) }
func metricsBroadcastObserved(n int) {
	if n > 0 {
		metricsBroadcasts.Add(int64(n))
	}
}

func metricsTickObserved(playerFrames int) {
	metricsTickTotal.Add(1)
	if playerFrames > 0 {
		metricsTickPlayersSeen.Add(int64(playerFrames))
	}
}

// metricsObserveOutQueueDepth records the depth of one send. The map
// stores the watermark (max observed) per player; the global counter
// keeps the worst case across all connections so a single Prometheus
// scrape surfaces back-pressure even when the offending player has
// already disconnected.
func metricsObserveOutQueueDepth(playerID, depth int) {
	if depth <= 0 {
		return
	}
	metricsOutQueueMu.Lock()
	if cur := metricsOutQueueMax[playerID]; depth > cur {
		metricsOutQueueMax[playerID] = depth
	}
	metricsOutQueueMu.Unlock()
	for {
		cur := metricsOutQueueGlobal.Load()
		if int64(depth) <= cur {
			return
		}
		if metricsOutQueueGlobal.CompareAndSwap(cur, int64(depth)) {
			return
		}
	}
}

// metricsClearOutQueue drops the watermark for a player when their
// connection closes — keeps the per-player map bounded by the active
// connection count.
func metricsClearOutQueue(playerID int) {
	metricsOutQueueMu.Lock()
	delete(metricsOutQueueMax, playerID)
	metricsOutQueueMu.Unlock()
}

// startMetricsServer launches a background HTTP server on METRICS_ADDR
// (default :9091) exposing /metrics in Prometheus text exposition
// format. Failures to bind are logged but never fatal — observability
// is best-effort.
func startMetricsServer() {
	addr := os.Getenv("METRICS_ADDR")
	if addr == "" {
		addr = ":9091"
	}
	mux := http.NewServeMux()
	mux.HandleFunc("/metrics", handleMetrics)
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.Write([]byte("ok"))
	})
	srv := &http.Server{
		Addr:              addr,
		Handler:           mux,
		ReadHeaderTimeout: 3 * time.Second,
	}
	go func() {
		mlog.Info("metrics server starting", "addr", addr)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			mlog.Warn("metrics server stopped", "err", err.Error())
		}
	}()
}

func handleMetrics(w http.ResponseWriter, _ *http.Request) {
	var ms runtime.MemStats
	runtime.ReadMemStats(&ms)
	w.Header().Set("Content-Type", "text/plain; version=0.0.4")
	uptime := time.Since(metricsStartTime).Seconds()

	// Order matters only for readability; Prometheus parses any order.
	fmt.Fprintf(w, "# HELP luarpg_uptime_seconds Server uptime in seconds.\n")
	fmt.Fprintf(w, "# TYPE luarpg_uptime_seconds counter\n")
	fmt.Fprintf(w, "luarpg_uptime_seconds %.3f\n", uptime)

	fmt.Fprintf(w, "# HELP luarpg_connections_total Cumulative TCP connections accepted.\n")
	fmt.Fprintf(w, "# TYPE luarpg_connections_total counter\n")
	fmt.Fprintf(w, "luarpg_connections_total %d\n", metricsConnTotal.Load())

	fmt.Fprintf(w, "# HELP luarpg_connections_active Currently open TCP connections.\n")
	fmt.Fprintf(w, "# TYPE luarpg_connections_active gauge\n")
	fmt.Fprintf(w, "luarpg_connections_active %d\n", metricsConnActive.Load())

	fmt.Fprintf(w, "# HELP luarpg_ticks_total Game ticks processed.\n")
	fmt.Fprintf(w, "# TYPE luarpg_ticks_total counter\n")
	fmt.Fprintf(w, "luarpg_ticks_total %d\n", metricsTickTotal.Load())

	fmt.Fprintf(w, "# HELP luarpg_player_frames_total Cumulative per-player snapshot frames emitted.\n")
	fmt.Fprintf(w, "# TYPE luarpg_player_frames_total counter\n")
	fmt.Fprintf(w, "luarpg_player_frames_total %d\n", metricsTickPlayersSeen.Load())

	fmt.Fprintf(w, "# HELP luarpg_input_lines_total Inbound command lines parsed.\n")
	fmt.Fprintf(w, "# TYPE luarpg_input_lines_total counter\n")
	fmt.Fprintf(w, "luarpg_input_lines_total %d\n", metricsLineTotal.Load())

	fmt.Fprintf(w, "# HELP luarpg_input_dropped_total Command lines refused (rate limit / oversized).\n")
	fmt.Fprintf(w, "# TYPE luarpg_input_dropped_total counter\n")
	fmt.Fprintf(w, "luarpg_input_dropped_total %d\n", metricsLineDropped.Load())

	fmt.Fprintf(w, "# HELP luarpg_broadcasts_total Outgoing broadcast messages.\n")
	fmt.Fprintf(w, "# TYPE luarpg_broadcasts_total counter\n")
	fmt.Fprintf(w, "luarpg_broadcasts_total %d\n", metricsBroadcasts.Load())

	fmt.Fprintf(w, "# HELP luarpg_goroutines Active goroutines.\n")
	fmt.Fprintf(w, "# TYPE luarpg_goroutines gauge\n")
	fmt.Fprintf(w, "luarpg_goroutines %d\n", runtime.NumGoroutine())

	fmt.Fprintf(w, "# HELP luarpg_alloc_bytes Allocated heap bytes.\n")
	fmt.Fprintf(w, "# TYPE luarpg_alloc_bytes gauge\n")
	fmt.Fprintf(w, "luarpg_alloc_bytes %d\n", ms.Alloc)

	fmt.Fprintf(w, "# HELP luarpg_outqueue_max Worst-case send queue depth observed across all players since boot.\n")
	fmt.Fprintf(w, "# TYPE luarpg_outqueue_max gauge\n")
	fmt.Fprintf(w, "luarpg_outqueue_max %d\n", metricsOutQueueGlobal.Load())

	metricsOutQueueMu.Lock()
	maxActive := 0
	for _, v := range metricsOutQueueMax {
		if v > maxActive {
			maxActive = v
		}
	}
	metricsOutQueueMu.Unlock()
	fmt.Fprintf(w, "# HELP luarpg_outqueue_max_active Worst-case send queue depth among currently connected players.\n")
	fmt.Fprintf(w, "# TYPE luarpg_outqueue_max_active gauge\n")
	fmt.Fprintf(w, "luarpg_outqueue_max_active %d\n", maxActive)
}
