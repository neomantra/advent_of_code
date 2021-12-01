#!lua
-- cat 01.test.txt | ./01a.lua | grep increase | wc -l

local last_datum = nil

for line in io.lines() do
    local datum = tonumber(line)
    local change = 'none'
    if last_datum ~= nil then
        if datum > last_datum then
            change = 'increase'
        elseif datum < last_datum then
            change = 'decrease'
        end
    end
    print(datum, change)
    last_datum = datum
end
