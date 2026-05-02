package main

import (
	"flag"
	"net"
	"os"
)

func main() {
	addr := flag.String("addr", "", "tcp listen address")
	flag.Parse()

	listenAddr := *addr
	if listenAddr == "" {
		listenAddr = os.Getenv("LISTEN_ADDR")
	}
	if listenAddr == "" {
		listenAddr = ":7777"
	}

	db := NewDB()
	cache := NewCache()

	ln, err := net.Listen("tcp", listenAddr)
	if err != nil {
		mlog.Error("listen failed", "addr", listenAddr, "err", err.Error())
		os.Exit(1)
	}
	defer ln.Close()
	mlog.Info("LuaRpgEngine server listening", "addr", listenAddr)

	startMetricsServer()

	game := NewGame(db, cache)
	go game.Loop()

	for {
		conn, err := ln.Accept()
		if err != nil {
			mlog.Warn("accept failed", "err", err.Error())
			continue
		}
		go game.HandleConn(conn)
	}
}
