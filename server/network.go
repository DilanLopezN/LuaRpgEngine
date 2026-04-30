package main

import (
	"bufio"
	"fmt"
	"log"
	"net"
)

func (g *Game) HandleConn(conn net.Conn) {
	defer conn.Close()

	out := make(chan string, 64)
	p := g.addPlayer(out)
	log.Printf("player %d connected from %s", p.ID, conn.RemoteAddr())
	defer func() {
		g.removePlayer(p.ID)
		log.Printf("player %d disconnected", p.ID)
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

	out <- fmt.Sprintf("WELCOME %d %d\n", p.ID, mapSize)

	scanner := bufio.NewScanner(conn)
	for scanner.Scan() {
		g.handleLine(p, scanner.Text())
	}

	close(out)
	<-writeDone
}
