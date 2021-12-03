#!luajit
-- cat 03.test.txt | ./03b.lua

local bit = require 'bit'

local function binary_str_to_num(str)
    local num = 0
    for c in str:gmatch(".") do
        if c == "0" then
            num = 2 * num
        elseif c == "1" then
            num = 2 * num + 1
        else
            -- bad char
            print("bad char, str:", str)
            return nil
        end
    end    
    return num
end

local function array_copy(t)
    local res = {}
    for _, v in ipairs(t) do
        res[#res + 1] = v
    end
    return res
end

local function read_diagnostic_codes_from_stdin()
    local codes = {}
    local max_len = nil  -- check for consistent length
    local line_num = 0
    for line in io.lines() do
        line_num = line_num + 1
        if max_len ~= nil and #line ~= max_len then
            io.stderr:write("line #", line_num, " has size:", #line, "wanted:", max_len)
        end
        max_len = #line

        local code = line -- binary_str_to_num(line)
        if code == nil then
            io.stderr:write("bad line #", line_num, " ", line)
        else
            codes[#codes + 1] = code
        end
    end
    return codes, max_len
end


local codes, num_columns = read_diagnostic_codes_from_stdin()
if num_columns == nil then
    error("bad columns")
end

------------------------------------------------------------------------------------------

-- returns zero_count, one_count
local function count_bits(codes, column)
    local zero_count, one_count = 0, 0
    for _, code in ipairs(codes) do
        if code:sub(column, column) == "0" then
            zero_count = zero_count + 1
        else
            one_count = one_count + 1
        end
    end
    return zero_count, one_count
end

local function filter_codes(codes, column, critera_fn)
    local res = {}
    for _, code in ipairs(codes) do
        if critera_fn(code, codes, column) then
            res[#res + 1] = code
        end
    end
    return res
end


-- return true to keep
-- To find oxygen generator rating, determine the most common value (0 or 1) in the current bit position,
-- and keep only numbers with that bit in that position.
-- If 0 and 1 are equally common, keep values with a 1 in the position being considered.
local function o2_bit_criteria(code, codes, column)
    local is_one = (code:sub(column, column) == "1")
    local zero_count, one_count = count_bits(codes, column)
    if zero_count > one_count then
        return (not is_one)
    elseif zero_count == one_count then
        return is_one
    else
        return is_one
    end
end

local o2_codes = array_copy(codes)
local o2_col = 1
repeat
    o2_codes = filter_codes(o2_codes, o2_col, o2_bit_criteria)
    o2_col = o2_col + 1
until #o2_codes == 1


-- return true to keep
-- To find CO2 scrubber rating, determine the least common value (0 or 1) in the current bit position,
-- and keep only numbers with that bit in that position.
-- If 0 and 1 are equally common, keep values with a 0 in the position being considered.
local function co2_bit_criteria(code, codes, column)
    local is_one = (code:sub(column, column) == "1")
    local zero_count, one_count = count_bits(codes, column)
    if zero_count < one_count then
        return (not is_one)
    elseif zero_count == one_count then
        return (not is_one)
    else
        return is_one
    end
end

local co2_codes = array_copy(codes)
local co2_col = 1
repeat
    co2_codes = filter_codes(co2_codes, co2_col, co2_bit_criteria)
    co2_col = co2_col + 1
until #co2_codes == 1


local o2_val = binary_str_to_num(o2_codes[1])
local co2_val = binary_str_to_num(co2_codes[1])

local life_support_rating = o2_val * co2_val

print("rows:", #codes, "columns:", num_columns,
    "o2_code:", o2_codes[1], "o2_val:", o2_val,
    "co2_code:", co2_codes[1], "co2_val:", co2_val,
    "rating:", life_support_rating)
