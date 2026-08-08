---
title: "Taming Concurrency: Goroutines and Channels"
date: 2026-06-30 17:30:00 -0500
categories: [Software Engineering, Systems]
tags: [go, concurrency, backend]
description: A practical worker-pool pattern in Go, and the concurrency bugs it quietly prevents.
---

## The problem

I had a batch job hammering an API one request at a time. Firing all of them at
once would get me rate-limited; doing them serially was painfully slow. The answer
is a bounded worker pool.

## The pattern

A buffered channel of jobs, a fixed number of workers, and a `WaitGroup` to know
when everyone's done:

```go
func run(jobs []Job, workers int) []Result {
    in := make(chan Job)
    out := make(chan Result)
    var wg sync.WaitGroup

    for i := 0; i < workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for j := range in {
                out <- process(j)
            }
        }()
    }

    go func() { // feeder
        for _, j := range jobs {
            in <- j
        }
        close(in)
    }()

    go func() { // closer
        wg.Wait()
        close(out)
    }()

    var results []Result
    for r := range out {
        results = append(results, r)
    }
    return results
}
```

## The subtle bit

The two goroutines at the bottom matter more than they look. Closing `in` after
the feeder finishes lets each worker's `range` terminate; closing `out` only after
`wg.Wait()` guarantees no worker is still trying to send when the collector stops
reading. Get the order wrong and you get either a deadlock or a send-on-closed
panic.

## Takeaway

`go` is one keyword, but correct concurrency lives in *who closes which channel,
and when*. This little pool has become my default shape for any "do N things,
politely" task.
