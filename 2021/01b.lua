#!lua
-- cat 01.test.txt | ./01b.lua | grep increase | wc -l

local window = { nil, nil, nil }
local last_sum = nil

local function fill_window(datum)
    window[3] = window[2]
    window[2] = window[1]
    window[1] = datum
end

local function is_window_filled()
    return window[1] and window[2] and window[3]
end

local function get_window_sum()
    return (window[1] or 0) + (window[2] or 0) + (window[3] or 0)
end

for line in io.lines() do
    local datum = tonumber(line)
    fill_window(datum)

    if is_window_filled() then            
        local new_sum = get_window_sum()
        local change = 'none'
        if last_sum ~= nil then
            if new_sum > last_sum then
                change = 'increase'
            elseif new_sum < last_sum then
                change = 'decrease'
            end
        end
        print(new_sum, change)
        last_sum = new_sum
    end
end
