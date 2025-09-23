# f-streams

[
    [`v0.1`](https://github.com/lua-atmos/f-streams/tree/v0.1)
]

`f-streams` is a pull-based streams library for Lua:

- A stream produces a new value each time is called.
- A stream terminates when it returns `nil`.
- A stream can use `:` combinators to create stream pipelines.
- A stream can be iterated over using Lua's generic [for][lua-for] loop.
- A stream can represent infinite lazy lists.

A simple example that produces the values `1`, `2`, and `3`:

```
local S = require "streams"
local s = S.from(1,3)
print(s())  -- 1
print(s())  -- 2
print(s())  -- 3
print(s())  -- nil
```

An example that prints the first three odd numbers multiplied by `2`:

```
local S = require "streams"
S.from(1)                                       -- 1, 2, 3, ...
    :filter(function (x) return x%2 == 1 end)   -- 1, 3, 5, ...
    :map(function (x) return x * 2 end)         -- 2, 6, 10, ...
    :take(3)                                    -- 2, 6, 10
    :to_each(function (v)
        print(v)                                -- 2 / 6 / 10
    end)
```

The API is divided into three groups: *sources*, *combinators* and *sinks*.

A source has the prefix `fr_` and creates a stream from the given values.
A combinator combines streams and values to create new streams.
A sink has the prefix `to_` and consumes a stream, producing results, until it
terminates.

[lua-for]: https://www.lua.org/manual/5.4/manual.html#3.3.5

- Sources
    - `fr_consts(v)`:       stream of constants `v`
    - `fr_coroutine(co)`:   stream of values from coroutine `co`
    - `fr_counter(a)`:      stream of numbers from `a` to infinity
    - `fr_function(f)`:     stream of `f()` results
    - `fr_range(a,b)`:      stream of numbers from `a` to `b`
    - `fr_table(t)`:        stream of values from `t`
    - `from(v)`:            calls the appropriate `fr_*` for `v`

- Combinators
    - `acc(s,z,f)`:     accumulates each value of `s` based on `f`:
                        `v1=f(z,s()), v2=f(v1,s()), ...`
    - `empty()`:        an empty stream
    - `filter(s,f)`:    filters `s` based on `f`
    - `map(s,f)`:       applies `f` to each value of `s`:
                        `f(s()), f(s()), ...`
    - `mapi(s,f)`:      applies `f` to each indexed value of `s`
                        `f(1,s()), f(2,s()), ...`
    - `max(s)`:         maximum between each value of `s`
    - `min(s)`:         minimum between each value of `s`
    - `mul(s)`:         multiplies each value of `s`
    - `skip(s,n)`:      skips the first `n` values of `s`
    - `sum(s)`:         sums each value of `s`
    - `table(s)`:       appends each value of `s` to a table:
                        `{s()}, {s(),s()}, ...`
    - `take(s,n)`:      takes the first `n` values of `s`
    - `tap(s,f)`:       applies `f` to each value of `s`
    - `xseq(ss)`:       flattens a stream of streams `ss` into a single stream

- Sinks
    - `to(s)`:          same as `to_last(s)`
    - `to_all(s,f)`:    if all values of `s` conform with `f`
    - `to_any(s,f)`:    if any value of `s` conforms with `f`
    - `to_first(s)`:    first value of `s`
    - `to_last(s)`:     last value of `s`
    - `to_none(s,f)`:   if no values of `s` conform with `f`
    - `to_print(s)`:    prints all values of `s`
    - `to_some(s,f)`:   if multiple values of `s` conform with `f`

<!--
- Sources
    - S.fr_vector
- Combinators
    - tapi
    - `distinct(s)`:    removes duplicate values of `s`
    - `loop(fs)`:       repeats the stream `s=fs()` indefinitely
    - `zip(...)`: combines two streams `s1` and `s2` into a single stream
    - `single(s)`:  `take(s,1)`
    - `drop_while(s, f)`: drops values from the stream `s` while the function `f` is true
    - `take_while(s, f)`: takes values from the stream `s` while the function `f` is true
        - take_while, skip_while
        - take_until, skip_until
    - `partition(s, f)`: partitions the stream `s` into two or more streams based on the function `f`
- Sinks
    - to() que consome geral e retorna algo (resultado do acc?)
    - to_acc_stop, to_acc_until gera o que passa e termina, to_acc_while nao gera o que falha e termina
    - `to_sorted(s)`: collects the values of the stream `s` into a sorted table
        - only if sorts as it goes...
    - to_last
    - to_n
    - S.to_vector
    - S.to_unit
-->

As a fundamental limitation, `f-streams` does not support a [merge][rx-merge]
combinator to read from multiple streams concurrently.
However, this limitation is addressed by [`lua-atmos`](lua-atmos), which
extends `f-streams` with equivalent combinators.

[rx-merge]: https://rxmarbles.com/#merge

# Install & Run

```
sudo luarocks install f-streams
lua <example.lua>
```

You may also copy the file `streams/init.lua` as `streams.lua` into your Lua
path, e.g.:

```
cp streams/init.lua /usr/local/share/lua/5.4/streams.lua
```

# Examples

Counts from `1` to infinity, takes the first 3 values, converts to table, and
print all indexes and values:

```
-- without `:` notation
cnt = S.fr_counter()        -- 1, 2, 3, 4, 5, ...
vs3 = S.take(cnt, 3)        -- 1, 2, 3
vec = S.to_table(vs3)       -- {1, 2, 3}
for i,v in ipairs(vec) do
    print(i,v)              -- 1,1 / 2,2 / 3,3
end
```

From a table with names, prints all starting with `J`:

```
js = S.from { "Joao", "Jose", "Maria" }:filter(function(n) return n:find("^J") end)
for n in js do
    print(n)    -- Joao / Jose
end
```

Prints each value from `1` to `10`:

```
vs = S.fr_range(1, 10)
S.to_each(vs, print)
```
