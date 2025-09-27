local S = require("streams")

print "- MAP / FILTER -"
do
    local s = S.fr_const(42)
    local mapped = S.map(s, function(x) return x * 2 end)
    assert(mapped() == 84)
    assert(mapped() == 84)
    assert(mapped() == 84)

    local s = S.from(1, 10)
    s = S.filter(s, function(x) return x % 2 == 0 end)
    s = S.map(s, function(x) return x * 2 end)
    local values = S.table(s):to()
    assert(#values==5 and values[1]==4 and values[5]==20)

    s = S.fr_range(1, 10)
    s = S.take(s, 5)
    s = S.map(s, function(x) return x * 2 end)
    values = S.table(s):to()
    assert(#values==5 and values[1]==2 and values[5]==10)

    s = S.fr_range(1, 10)
    s = S.skip(s, 5)
    s = S.filter(s, function(x) return x % 2==0 end)
    values = S.table(s):to()
    assert(#values==3 and values[1]==6 and values[3]==10)

    s = S.fr_range(1, 10)
    s = S.map(s, function(x) return x * 2 end)
    s = S.take(s, 5)
    values = S.table(s):to()
    assert(#values==5 and values[1]==2 and values[5]==10)

    s = S.fr_range(1, 10)
    s = S.map(s, function(x) return x * 2 end)
    s = S.filter(s, function(x) return x % 4 == 0 end)
    values = S.table(s):to()
    assert(#values==5 and values[1]==4 and values[5]==20)

    local s = setmetatable({}, {
        __call = function()
            return 5
        end
    })
    s = S.take(S.map(s, function(x) return x * 2 end), 2)

    local s1 = S.fr_range(1,3)
    local s2 = S.fr_range(4,6)
    s = S.seq(s1, s2)
    s = S.filter(s, function(x) return x % 2 == 0 end)
    s = S.map(s, function(x) return x * 2 end)
    local values = S.table(s):to()
    assert(#values==3 and values[1]==4 and values[2]==8 and values[3]==12)
end

print '- ZIP -'

do
    local s1 = S.fr_range(1,3)
    local s2 = S.fr_range(4,6)
    local s = S.zip(s1, s2)
    s = S.map(s, function(xy) return xy[1] + xy[2] end)
    local values = S.table(s):to()
    assert(#values==3 and values[1]==5 and values[2]==7 and values[3]==9)

    local s1 = S.fr_range(1,2)
    local s2 = S.fr_range(3,4)
    local s3 = S.fr_range(5,6)
    local s = S.zip(S.seq(s1,s2), s3)
    local vs = s:table():to()
    assert(#vs == 2)
    assert(#vs[1]==2 and #vs[2]==2)
    assert(vs[1][1]==1 and vs[1][2]==5 and vs[2][1]==2 and vs[2][2]==6)

    local s1 = S.from(1, 5)
    local s2 = S.from(6, 8)
    local zipped = S.zip(s1, s2)
    local result = {}
    zipped:tap(function(xy) table.insert(result, xy) end):to()
    assert(#result == 3)
    assert(result[1][1]==1 and result[1][2]==6)
    assert(result[2][1]==2 and result[2][2]==7)
    assert(result[3][1]==3 and result[3][2]==8)

    local s1 = S.fr_const(nil)
    local s2 = S.from(6, 10)
    local zipped = S.zip(s1, s2)
    local result = {}
    zipped:tap(function(x,y) table.insert(result, {x,y}) end):to()
    assert(#result == 0)
end

print "--- TO_FIRST ---"
do
    do
        local function my_stream()
            local i = 0
            return function()
                i = i + 1
                if i <= 3 then
                    return i
                end
            end
        end
        local mapped_stream = S.map(my_stream(), function(x) return x * 2 end)
        local first_value = S.to_first(mapped_stream)
        assert(first_value == 2)
    end

    do
        local function my_stream()
            return function()
                return nil
            end
        end
        local first_value = S.to_first(my_stream())
        assert(first_value == nil)
    end
end

print "- XSEQ -"

do
    local s = S.fr_range(1, 3)
    s = S.map(s, function(x) return S.fr_range(x, x + 1) end)
    s = s:xseq()
    local values = S.table(s):to()
    assert(#values==6 and values[1]==1 and values[2]==2 and values[3]==2 and values[4]==3 and values[5]==3 and values[6]==4)

    print("Testing...", "test 10: concat map")
    local s1 = S.from({1, 2, 3})
    local s2 = S.from({4, 5, 6})
    local s_concat = S.from{s1, s2}:xseq()
    local s_mapped = S.map(s_concat, function(x) return x * 2 end)
    local t = S.table(s_mapped):to()
    assert(#t == 6)
    for i = 1, 6 do
        assert(t[i] == i * 2)
    end

    print("Testing...", "test 11: map concat")
    local s1 = S.from({1, 2, 3})
    local s2 = S.from({4, 5, 6})
    local s1_mapped = S.map(s1, function(x) return x * 2 end)
    local s2_mapped = S.map(s2, function(x) return x*2 + 1 end)
    local s_concat = S.from{s1_mapped, s2_mapped}:xseq()
    local t = S.table(s_concat):to()
    assert(#t == 6)
    for i = 1, 3 do
        assert(t[i] == i*2)
    end
    for i = 4, 6 do
        assert(t[i] == i*2 + 1)
    end

    print("Testing...", "test 12: concat filter")
    local s1 = S.from({1, 2, 3, 4})
    local s2 = S.from({5, 6, 7, 8})
    local s_concat = S.from{s1, s2}:xseq()
    local s_filtered = S.filter(s_concat, function(x) return x % 2 == 0 end)
    local t = S.table(s_filtered):to()
    assert(#t == 4)
    assert(t[1] == 2)
    assert(t[2] == 4)
    assert(t[3] == 6)
    assert(t[4] == 8)
end

print '--- TO / TAP ---'

do
    local s = S.fr_range(1, 5)
    local tapped = {}
    s:tap(function(x) table.insert(tapped, x) end):to()
    assert(#tapped == 5)
    assert(tapped[1] == 1)
    assert(tapped[2] == 2)
    assert(tapped[3] == 3)
    assert(tapped[4] == 4)
    assert(tapped[5] == 5)

    local s = S.fr_range(1, 5)
    local tapped = {}
    s:map(function(x) return x * 2 end):tap(function(x) table.insert(tapped, x) end):to()
    assert(#tapped == 5)
    assert(tapped[1] == 2)
    assert(tapped[2] == 4)
    assert(tapped[3] == 6)
    assert(tapped[4] == 8)
    assert(tapped[5] == 10)
end

print '--- TEE ---'

do
    print("Testing...", "tee 01: filter")
    local s = S.from({1, 2, 3, 4, 5})
    local s1, s2 = S.tee(s)
    local s1_filtrado = s1:filter(function(x) return x % 2 == 0 end)
    local s2_filtrado = s2:filter(function(x) return x % 2 ~= 0 end)
    local resultado1 = S.table(s1_filtrado):to()
    local resultado2 = S.table(s2_filtrado):to()
    assert(#resultado1 == 2 and #resultado2 == 3)
    assert(resultado1[1] == 2 and resultado1[2] == 4)
    assert(resultado2[1] == 1 and resultado2[2] == 3 and resultado2[3] == 5)

    print("Testing...", "tee 02: map")
    local s = S.from({1, 2, 3, 4, 5})
    local s1, s2 = S.tee(s)
    local s1_mapeado = s1:map(function(x) return x * 2 end)
    local s2_mapeado = s2:map(function(x) return x + 1 end)
    local resultado1 = S.table(s1_mapeado):to()
    local resultado2 = S.table(s2_mapeado):to()
    assert(#resultado1 == 5 and #resultado2 == 5)
    for i = 1, 5 do
        assert(resultado1[i] == i * 2 and resultado2[i] == i + 1)
    end

    print("Testing...", "tee 03: filter/map")
    local s = S.from({1, 2, 3, 4, 5})
    local s1, s2 = S.tee(s)
    local s1_filtrado = s1:filter(function(x) return x % 2 == 0 end):map(function(x) return x * 2 end)
    local s2_filtrado = s2:filter(function(x) return x % 2 ~= 0 end):map(function(x) return x + 1 end)
    local resultado1 = S.table(s1_filtrado):to()
    local resultado2 = S.table(s2_filtrado):to()
    assert(#resultado1 == 2 and #resultado2 == 3)
    assert(resultado1[1] == 4 and resultado1[2] == 8)
    assert(resultado2[1] == 2 and resultado2[2] == 4 and resultado2[3] == 6)
end

-- TODO

--[===[
s = S.fr_range(1, 10)
s = S.distinct(s)
s = S.map(s, function(x) return x * 2 end)
values = S.table(s):to()
assert(#values == 10 and values[1] == 2 and values[10] == 20)

print "--- LOOP ---"
do
    do
        local function my_stream()
            local i = 0
            return function()
                i = i + 1
                if i <= 3 then
                    return i
                end
            end
        end

        local loop_stream = S.loop(my_stream)
        local take_stream = S.take(loop_stream, 10)
        local values = {}
        for value in take_stream do
            table.insert(values, value)
        end
        assert(#values == 10)
        assert(values[1] == 1)
        assert(values[2] == 2)
        assert(values[3] == 3)
        assert(values[4] == 1)
        assert(values[5] == 2)
        assert(values[6] == 3)
        assert(values[7] == 1)
        assert(values[8] == 2)
        assert(values[9] == 3)
        assert(values[10] == 1)
    end
    do
        local function my_stream()
            return function()
                return nil
            end
        end

        local loop_stream = S.loop(my_stream)
        local value = loop_stream()
        assert(value == nil)
    end
end

print '--- SORT ---'

do
    -- Teste 5: Combinação com S.take
    local t = S.from({3, 1, 2, 4, 5})
        :table()
        :sort(function(a, b) return a < b end)
        :take(3)
        :to()
    assert(t[1] == 1)
    assert(t[2] == 2)
    assert(t[3] == 3)

    -- Teste 6: Combinação com S.map
    local t = S.from({3, 1, 2, 4})
        :map(function(x) return x * 2 end)
        :table()
        :sort(function(a, b) return a < b end)
        :to()
    assert(t[1] == 2)
    assert(t[2] == 4)
    assert(t[3] == 6)
    assert(t[4] == 8)
end
]===]
