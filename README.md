# f-streams

`f-streams` is yet another streams library for Lua.

A stream is simply a function or any value with a `__call` metamethod.

A stream produces a new value each time is called.
When a stream returns `nil`, it indicates its termination.
Them, all subsequent calls to the stream must also return `nil`.

Streams can be combined with other streams or values to create new streams.

The API is divided into three groups: sources, combinators and sinks.

A source has the prefix `fr_` and creates a stream from the given values.
A combinator combines streams and values to create new streams.
A sink has the prefix `to_` and consumes a stream, producing results, until it
terminates.

- Sources
    - `fr_const(v)`:    stream of constants `v`
    - `fr_counter(a)`:  stream of numbers from `a` to infinity
    - `fr_range(a,b)`:  stream of numbers from `a` to `b`
    - `fr_table(t)`:    stream of values from `t`

<!--
    - `fr_value(v)`:    stream of a single value `v`
-->

- Combinators
    - `map(s,f)`:       applies `f` to each value of `s`
    - `filter(s,f)`:    filters `s` based on `f`
    - `take(s, n)`:     takes the first `n` values of `s`
    - `skip(s, n)`:     skips the first `n` values of `s`
    - `distinct(s)`:    removes duplicate values of `s`
    - `flatten(ss)`:    flattens a stream of streams into a single stream

<!--
- `zip(s1, s2)`: combines two streams `s1` and `s2` into a single stream
- `concat(s1, s2)`: concatenates two streams `s1` and `s2` into a single stream
- `cycle(s)`: repeats the stream `s` infinitely
- `drop_while(s, f)`: drops values from the stream `s` while the function `f` is true
- `take_while(s, f)`: takes values from the stream `s` while the function `f` is true
- `partition(s, f)`: partitions the stream `s` into two or more streams based on the function `f`
-->

- Sinks
    - `to_table(s)`:    appends to a table all values of `s`
    - `to_sum(s)`:      sum of all values of `s`
    - `to_mul(s)`:      multiplication of all values of `s`
    - `to_min(s)`:      minimum value of `s`
    - `to_max(s)`:      maximum value of `s`
    - `to_acc(s, f)`:   accumulates all values of `s` based on `f(acc,v)`
    - `to_each(s, f)`:  applies `f` to each value of `s`

<!--
    - only if as it goes...
    - `to_sorted(s)`: collects the values of the stream `s` into a sorted table
--
