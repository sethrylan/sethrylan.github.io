---
layout: post
title: trivially parallelize blocking queries with Futures
---

# {{ page.title }}

tldr: we took some imperative, blocking code and made it concurrent without changing the structure of the code, just adding a few characters to each line. Clojure rocks.

My hackerschool friend [Julien Fantin](https://github.com/julienfantin) is writing a [music recommendation webapp, based on SoundCloud.com](https://github.com/julienfantin/sndcld-clj), a music social network. SoundCloud provides API access to their social graph, so Julien can start with a track that we want to find more music like, find users who 'like' the track, find the other thing these users like, and weight these suggestions against the intersection of their like list with my like list. The business logic looks something like follows. Don't look too hard, its just a little example.

    (defn recommendations [user track]
      (let [user-favorites (get-user-favorites user)
            track-favoriters (get-track-favoriters user track)
            favoriters-favorites (get-favoriters-favorites track-favoriters)
            sorted-favoriters (sort-users-by-similarity user track-favoriters)
            top-favoriter (first (sorted-favoriters))]
        (future (get-user-favorites top-favoriter))))

each `get-` method implies a query, or multiple queries. the SoundCloud API doesn't support fetching favorites in bulk--e.g., fetch the set of favorites for each user in this set of users--so `get-favoriters-favorites` fires off a query for each of N users who favorited the track.

The Clojure `let` form evaluates each expression in order, so this code is effectively imperative--each value (const variable) is bound in order, so subsequent statements can use prior values. Analysing the dependencies of each statement we see there is room for parallelization. the first two statements, `user-favorites` and `track-favoriters`, can be executed in parallel; `favoriters-favorites` doesn't depend on the result of `user-favorites`; et cetera.

We spent a solid hour or two thinking about different approaches based on Clojure's concurrency primitives, we ended up using futures. `future` works by scheduling its body (the expression inside the future) in the context of another thread to be evaluated at some point in the future, then returning a "future object" which is like a pointer to a value that might not be ready. When you need the value, you use the `@` symbol in front of the returned future object, which says blocking if the value isn't ready yet. here's how it looks. Note the @ symbols.

    (defn recommendations [user track]
      (let [user-favorites (future (get-user-favorites user))
            track-favoriters (future (get-track-favoriters user track))
            favoriters-favorites (future (get-favoriters-favorites @track-favoriters))
            sorted-favoriters (future (sort-users-by-similarity user @track-favoriters))
            top-favoriter (future @sorted-favoriters)] ;simplified this to not be a
                                                       ;list as proof of concept
        (future (get-user-favorites @top-favoriter))))

and mock out the queries with sleeps.

    (defn get-user-favorites [user]
      (Thread/sleep 10000) (prn 1)
      1)

    (defn get-track-favoriters [user track]
      (Thread/sleep 1000) (prn 2)
      2)

    (defn get-favoriters-favorites [favoriters]
    (let [results []] ;non-idiomatic hack because we were being bitten by lazy map
        (dotimes [n 10]
          (conj results (future (get-user-favorites nil))))
        (map deref results)) ;`deref` is a function that performs `@`
      (prn 3)
      3)

    (defn sort-users-by-similarity [user favoriters]
      (Thread/sleep 1000) (prn 4)
      4)

note the impl of get-favoriters-favorites schedules his own set of futures and blocks on them. this is OK because get-favoriters-favorites itself is running inside a future.

running `@(recommendations nil nil)` (we're passing nil for user and track since we're not actually executing any queries) yields the following output:

    user> @(recommendations nil nil)
    2
    3
    4
    1
    11

    1
    1
    1
    1
    1
    1
    1
    1
    1
    => 1 ;return value

2, 3, 4 are executed in parallel with 1 - and since they don't depend on the result of 1, they can happen while the value of 1 is not yet available.

Something like this is not nearly as nice in a language like Java because each `future` expression's body is inside a closure over the future objects in lexical scope above it. That's why the @ statements don't block - they are evaluated in another thread, as a closure which has access to the other future objects. The closed-over values are shared across threads, but this is all abstracted away by the `future` statement. This is totally possible in Java, but manually building the closures required would make this code extremely verbose.
