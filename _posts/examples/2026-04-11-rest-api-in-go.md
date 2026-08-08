---
title: "Designing a REST API in Go"
date: 2026-04-11 09:00:00 -0500
categories: [Software Engineering, Web]
tags: [go, api, backend]
description: A clean, dependency-light REST API in Go using only the standard library router.
---

## Why the standard library?

Go 1.22's `net/http` router finally supports method-and-path patterns, so for a
small service you don't need a framework at all. Less magic, fewer dependencies.

## Routing

```go
mux := http.NewServeMux()
mux.HandleFunc("GET /posts/{id}", getPost)
mux.HandleFunc("POST /posts", createPost)

log.Fatal(http.ListenAndServe(":8080", logging(mux)))
```

Path values come straight off the request:

```go
func getPost(w http.ResponseWriter, r *http.Request) {
    id := r.PathValue("id")
    post, err := store.Find(id)
    if err != nil {
        http.Error(w, "not found", http.StatusNotFound)
        return
    }
    writeJSON(w, http.StatusOK, post)
}
```

## Middleware without a framework

Middleware is just a function that wraps a handler, no special API required:

```go
func logging(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        next.ServeHTTP(w, r)
        log.Printf("%s %s %s", r.Method, r.URL.Path, time.Since(start))
    })
}
```

## Takeaway

For anything CRUD-shaped, the standard library gets you a clean, testable API with
almost no ceremony. Reach for a framework when you actually feel the friction.
