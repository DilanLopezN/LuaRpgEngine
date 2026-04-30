package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/redis/go-redis/v9"
)

type Cache struct {
	client *redis.Client
}

func NewCache() *Cache {
	addr := os.Getenv("REDIS_ADDR")
	if addr == "" {
		addr = "localhost:6379"
	}
	client := redis.NewClient(&redis.Options{Addr: addr})
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if err := client.Ping(ctx).Err(); err != nil {
		log.Printf("redis unavailable: %v (running without cache)", err)
		_ = client.Close()
		return &Cache{}
	}
	log.Printf("redis connected at %s", addr)
	return &Cache{client: client}
}

func (c *Cache) ctx() (context.Context, context.CancelFunc) {
	return context.WithTimeout(context.Background(), 1*time.Second)
}

func (c *Cache) SetOnline(name string) {
	if c.client == nil {
		return
	}
	ctx, cancel := c.ctx()
	defer cancel()
	c.client.SAdd(ctx, "online", name)
}

func (c *Cache) SetOffline(name string) {
	if c.client == nil {
		return
	}
	ctx, cancel := c.ctx()
	defer cancel()
	c.client.SRem(ctx, "online", name)
}

func (c *Cache) RecordKill(name string) {
	if c.client == nil {
		return
	}
	ctx, cancel := c.ctx()
	defer cancel()
	c.client.ZIncrBy(ctx, "kills", 1, name)
}
