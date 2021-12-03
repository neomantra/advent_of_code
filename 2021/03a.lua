#!luajit
-- cat 03.test.txt | ./03a.lua

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


local codes, columns = read_diagnostic_codes_from_stdin()
if columns == nil then
    error("bad columns")
end


-- go over each bit column, extracting gamma/epsilon digits
local gamma_str, epsilon_str = "", ""
for i = 1, columns do
    -- sum the 1's
    local one_count = 0
    for _, code in ipairs(codes) do
        if code:sub(i,i) == "1" then
            one_count = one_count + 1
        end
    end
    -- build out the gamma string
    if one_count > (#codes / 2) then  -- is ones most common?
        gamma_str = gamma_str .. "1"
        epsilon_str = epsilon_str .. "0"
    else
        gamma_str = gamma_str .. "0"
        epsilon_str = epsilon_str .. "1"
    end
end

local gamma_rate = binary_str_to_num(gamma_str)
local epsilon_rate = binary_str_to_num(epsilon_str)

local power_consumption = gamma_rate * epsilon_rate

print("num_codes:", #codes, "columns:", columns, "gamma:", gamma_rate, "epsilon:", epsilon_rate, "consumption:", power_consumption)
