# f-streams

[
    [`v0.1`](https://github.com/lua-atmos/f-streams/tree/v0.1)
]

`f-streams` is a pull-based streams library for Lua:

- A stream is simply a function or any other value with a `__call` metamethod.
- A stream produces a new value each time is called.
  When a stream returns `nil`, it indicates its termination.
  Then, all subsequent calls to the stream must also return `nil`.
- A stream can be combined with other streams or values to create new streams.
- A stream can be iterated over using Lua's generic [for][lua-for] loop.
- A stream can represent infinite lazy lists.

The example that follows prints the first three odd numbers multiplied by `2`:

```
_ = S.from(1)                                       -- 1, 2, 3, ...
    >> S.filter ^ (function(x) return x%2 == 1 end) -- 1, 3, 5, ...
    >> S.map ^ (function(x) return x * 2 end)       -- 2, 6, 10, ...
    >> S.take ^ 3                                   -- 2, 6, 10
    >> S.to_each ^ (function (v)
        print(v)                                    -- 2 / 6 / 10
    end)
```

The API is divided into three groups: *sources*, *combinators* and *sinks*.

A source has the prefix `fr_` and creates a stream from the given values.
A combinator combines streams and values to create new streams.
A sink has the prefix `to_` and consumes a stream, producing results, until it
terminates.

[lua-for]: https://www.lua.org/manual/5.4/manual.html#3.3.5

- Sources
    - `fr_const(v)`:    stream of constant `v`
    - `fr_counter(a)`:  stream of numbers from `a` to infinity
    - `fr_range(a,b)`:  stream of numbers from `a` to `b`
    - `fr_table(t)`:    stream of values from `t`
    - `from(v)`:        calls the appropriate `fr_*` for `v`

<!--
    - `fr_value(v)`:    stream of a single value `v`
-->

- Combinators
    - `map(f,s)`:       applies `f` to each value of `s`
    - `filter(f,s)`:    filters `s` based on `f`
    - `take(n,s)`:      takes the first `n` values of `s`
    - `skip(n,s)`:      skips the first `n` values of `s`
    - `distinct(s)`:    removes duplicate values of `s`
    - `flatten(ss)`:    flattens a stream of streams into a single stream

<!--
- merge
- `zip(...)`: combines two streams `s1` and `s2` into a single stream
- `concat(...)`: concatenates two streams `s1` and `s2` into a single stream
- `cycle(s)`: repeats the stream `s` infinitely
- `drop_while(s, f)`: drops values from the stream `s` while the function `f` is true
- `take_while(s, f)`: takes values from the stream `s` while the function `f` is true
- `partition(s, f)`: partitions the stream `s` into two or more streams based on the function `f`
-->

- Sinks
    - `to_table(s)`:        appends to a table all values of `s`
    - `to_each(f,s)`:       applies `f` to each value of `s`
    - `to_acc(f,acc,s)`:    accumulates all values `v` in `s` based on `acc=f(acc,v)`
        - `to_sum(s)`:      sum all values of `s`
        - `to_mul(s)`:      multiply all values of `s`
        - `to_min(s)`:      minimum value of `s`
        - `to_max(s)`:      maximum value of `s`

<!--
    - only if sorts as it goes...
    - `to_sorted(s)`: collects the values of the stream `s` into a sorted table
    - to_last
    - to_first
    - to_n
-->

- Embedded operators language:
    - `language()`: enables the operators `>>` and `^` to work with streams
    - `s >> f`:     equivalent to `f(s)`
    - `s >> f^v`:   equivalent to `f(v, s)`

As a fundamental limitation, `f-streams` does not support a [merge][rx-merge]
combinator to read from multiple streams concurrently.
However, this limitation is addressed by [`lua-atmos`](lua-atmos), which
extends `f-streams` with a merge combinator.

[rx-merge]: https://rxmarbles.com/#merge

# Install & Run

```
sudo luarocks install f-streams --lua-version=5.4
lua5.4 <example.lua>
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
local cnt = S.fr_counter()  -- 1, 2, 3, 4, 5, ...
local vs3 = S.take(cnt, 3)  -- 1, 2, 3
local vec = S.to_table(vs3) -- {1, 2, 3}
for i,v in ipairs(vec) do
    print(i,v)              -- 1,1 / 2,2 / 3,3
end
```

From a table with names, prints all that start with `J`:

```
local ns = S.fr_table { "Joao", "Jose", "Maria" }
local js = S.filter(ns, function(n) return n:find("^J") end)
for n in js do
    print(n)    -- Joao / Jose
end
```

Print each value from `1` to `10`:

```
local vs = S.fr_range(1, 10)
S.to_each(vs, print)
```
