local M = {}

-- SOURCES

function M.fr_counter (i)
    return function()
        local v = i
        i = i + 1
        return v
    end
end

function M.fr_range (a, b)
    local i = a
    return function()
        if i <= b then
            local v = i
            i = i + 1
            return v
        end
    end
end

function M.fr_table (t)
    local i = 1
    return function()
        if i <= #t then
            local v = t[i]
            i = i + 1
            return v
        end
    end
end

function M.fr_vector (v)
    return M.fr_table(v)
end

-- COMBINATORS

function M.map (s, f)
    return function()
        local v = s()
        if v ~= nil then
            return f(v)
        end
    end
end

function M.filter (s, f)
    return function()
        local v
        repeat
            v = s()
        until v == nil or f(v)
        return v
    end
end

function M.take (s, n)
    local i = 0
    return function()
        if i < n then
            i = i + 1
            return s()
        end
    end
end

function M.skip (s, n)
    for _ = 1, n do
        s()
    end
    return s
end

function M.distinct (s)
    local seen = {}
    return function()
        local v
        repeat
            v = s()
        until v == nil or not seen[v]
        if v ~= nil then
            seen[v] = true
        end
        return v
    end
end

function M.flatten (s)
    local current_stream = s()
    return function()
        while current_stream do
            local v = current_stream()
            if v ~= nil then
                return v
            else
                current_stream = s()
            end
        end
    end
end

-- SINKS

function M.to_table (s)
    local t = {}
    local v
    repeat
        v = s()
        if v ~= nil then
            table.insert(t, v)
        end
    until v == nil
    return t
end

function M.to_vector (s)
    return M.to_table(s)
end

function M.to_sum (s)
    local sum = 0
    local v
    repeat
        v = s()
        if v ~= nil then
            sum = sum + v
        end
    until v == nil
    return sum
end

function M.to_product (s)
    local product = 1
    local v
    repeat
        v = s()
        if v ~= nil then
            product = product * v
        end
    until v == nil
    return product
end

function M.to_min (s)
    local min
    local v
    repeat
        v = s()
        if v ~= nil then
            if min == nil or v < min then
                min = v
            end
        end
    until v == nil
    return min
end

function M.to_max (s)
    local max
    local v
    repeat
        v = s()
        if v ~= nil then
            if max == nil or v > max then
                max = v
            end
        end
    until v == nil
    return max
end

function M.to_sorted (s)
    local t = M.to_table(s)
    table.sort(t)
    return M.fr_table(t)
end

function M.to_reduced (s, f)
    local acc
    local v
    repeat
        v = s()
        if v ~= nil then
            if acc == nil then
                acc = v
            else
                acc = f(acc, v)
            end
        end
    until v == nil
    return acc
end

function M.to_each (s, f)
    local v
    repeat
        v = s()
        if v ~= nil then
            f(v)
        end
    until v == nil
end

return M
