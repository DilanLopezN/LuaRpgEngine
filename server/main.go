package main

import (
	"flag"
	"log"
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
		log.Fatalf("listen: %v", err)
	}
	defer ln.Close()
	log.Printf("LuaRpgEngine server listening on %s", listenAddr)

	game := NewGame(db, cache)
	go game.Loop()

	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Printf("accept: %v", err)
			continue
		}
		go game.HandleConn(conn)
	}
}
