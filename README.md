# f-streams

`f-streams` is yet another stream library for Lua.

A stream is simply a function or any value with a `__call` metamethod.

A stream produces a new value each time is called.
A `nil` as return indicates the stream end.
Then, the stream must always return `nil` when called.

Streams can be combined with other streams or values to create new streams.

The API is divided into three groups: sources, combinators and sinks:

A source has the prefix `fr_` and creates a stream from the given values.
A combinators combines streams and values to create new streams.
A sink has the prefix `to_` and consumes a stream, producing results, until it
terminates.

- Sources
    - `fr_range(a,b)`: generates a stream of numbers from `a` to `b`
    - `fr_table(t)`: generates a stream from a table `t`
    - `fr_vector(v)`: generates a stream from a vector `v`
    - `fr_value(value)`: generates a stream with a constant value `value`
    - `fr_callable(value)`: generates a stream from a value with `__call` metametodo

- Combinators
    - `map(s,f)`: applies a function `f` to each element of the stream `s`
    - `filter(s,f)`: filters the elements of the stream `s` based on the function `f`
    - `take(s, n)`: takes the first `n` elements of the stream `s`
    - `skip(s, n)`: skips the first `n` elements of the stream `s`
    - `distinct(s)`: removes duplicate elements from the stream `s`
    - `flatten(s)`: flattens a stream of streams into a single stream

<!--
- `zip(s1, s2)`: combines two streams `s1` and `s2` into a single stream
- `concat(s1, s2)`: concatenates two streams `s1` and `s2` into a single stream
- `cycle(s)`: repeats the stream `s` infinitely
- `drop_while(s, f)`: drops elements from the stream `s` while the function `f` is true
- `take_while(s, f)`: takes elements from the stream `s` while the function `f` is true
- `partition(s, f)`: partitions the stream `s` into two or more streams based on the function `f`
-->

- Sinks
    - `to_table(s)`: collects the elements of the stream `s` into a table
    - `to_sum(s)`: calculates the sum of the elements of the stream `s`
    - `to_product(s)`: calculates the product of the elements of the stream `s`
    - `to_min(s)`: finds the minimum element of the stream `s`
    - `to_max(s)`: finds the maximum element of the stream `s`
    - `to_sorted(s)`: collects the elements of the stream `s` into a sorted table
    - `to_reduced(s, f)`: reduces the stream `s` to a single value based on the function `f`
    - `to_each(s, f)`: applies the function `f` to each element of the stream `s`
