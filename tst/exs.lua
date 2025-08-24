local S = require("streams")
require "test"

do
    print("Testing...", "counter 1")
    local my_counter = S.fr_counter()
    local my_capped_counter = S.take(my_counter, 5)
    local my_array = S.to_table(my_capped_counter)
    out(type(my_array))
    for i,v in ipairs(my_array) do
        out(i,v)
    end
    assertx(out(), "table\n1\t1\n2\t2\n3\t3\n4\t4\n5\t5\n")
end

do
    print("Testing...", "counter 2")
    local my_array = S.take(S.fr_counter(), 5)
    for v in my_array do
        out(v)
    end
    assertx(out(), "1\n2\n3\n4\n5\n")
end

do
    print("Testing...", "filter 1")
    local names = {
      "Arya",
      "Beatrice",
      "Caleb",
      "Dennis"
    }
    local names_with_b = S.filter(S.fr_table(names), function(it) return it:find("[Bb]") end)
    local v = S.to_table(names_with_b)
    assert(#v == 2)
    assert(v[1] == "Beatrice")
    assert(v[2] == "Caleb")
end

do
    print("Testing...", "map 1")
    local names = {
      "Arya",
      "Beatrice",
      "Caleb",
      "Dennis"
    }
    local names_with_b = S.filter(S.fr_table(names), function(it) return it:find("[Bb]") end)
    local v = S.to_table(S.map(names_with_b, string.upper))
    assert(#v == 2)
    assert(v[1] == "BEATRICE")
    assert(v[2] == "CALEB")
end

do
    print("Testing...", "each 1")
    local r = S.fr_range(1, 10) -- all the numbers from 1 to 10 (inclusive)
    local e = S.filter(r, function(it) return it%2==0 end) -- take only even numbers
    local t = {}
    S.to_each(e, function (it) t[#t+1]=it end)
    assert(#t==5 and t[1]==2 and t[5]==10)
end

do
    print("Testing...", "map 2")
    local names = {"hellen", "oDYSseuS", "aChIlLeS", "PATROCLUS"}
    local fix_case = function (name)
        return name:sub(1,1):upper() .. name:sub(2):lower()
    end
    local t = S.to_table(S.map(S.fr_table(names), fix_case))
    assert(#t==4 and t[1]=="Hellen" and t[4]=="Patroclus")
end

do return end

do
    print("Testing...", "acc 1")
    local numbers = S.fr_range(10,15)
    local sum = numbers::reduce(\(acc,new){acc+new}, 0)
    print(sum)
end
local out = atm_test(src)
assertx(out, "75\n")

local src = [[
    val f = require "atmos.lang.functional"
    val numbers = @{2, 1, 3, 4, 7, 11, 18, 29}

    val is_even = \{(it % 2) == 0}
    xprint <-- f.filter(numbers, is_even)::to_array()

    xprint <-- f.filter(numbers, \{(it % 2) == 0})::to_array()
]]
print("Testing...", "func 8")
local out = atm_test(src)
assertx(out, "{2, 4, 18}\n{2, 4, 18}\n")

local src = [[
    val f = require "atmos.lang.functional"
    val matrix = @{
      @{1, 2, 3}, ;; first element of matrix
      @{4, 5, 6}, ;; second element of matrix
      @{7, 8, 9}  ;; third element of matrix
    }
    ;; map will iterate through each row, and the lambda
    ;; indexes each to retrieve the first element
    xprint <-- f.map(matrix, \{it[1]})::to_array()
]]
print("Testing...", "func 9")
local out = atm_test(src)
assertx(out, "{1, 4, 7}\n")

