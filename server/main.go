package main

import (
	"flag"
	"log"
	"net"
)

func main() {
	addr := flag.String("addr", ":7777", "tcp listen address")
	flag.Parse()

	ln, err := net.Listen("tcp", *addr)
	if err != nil {
		log.Fatalf("listen: %v", err)
	}
	defer ln.Close()
	log.Printf("LuaRpgEngine server listening on %s", *addr)

	game := NewGame()
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
