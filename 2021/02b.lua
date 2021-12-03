#!lua
-- cat 02.test.txt | ./02b.lua


local function split_string(str, sep)
    local sep, fields = sep or " ", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
 end


local function read_commands_from_stdin()
    local commands = {}
    line_num = 0
    for line in io.lines() do
        line_num = line_num + 1
        local fields = split_string(line,  ' ')
        if #fields ~= 2 then
            io.stderr:write("bad line #", line_num, " ", line)
        else
            commands[#commands + 1] = { action = fields[1], X = tonumber(fields[2]) }
        end
    end
    return commands
end


commands = read_commands_from_stdin()

local horiz, depth, aim = 0, 0, 0

for n, command in ipairs(commands) do
    if command.action == "forward" then
        -- forward X does two things:
        horiz = horiz + command.X         -- It increases your horizontal position by X units.
        depth = depth + (aim * command.X) -- It increases your depth by your aim multiplied by X.
    elseif command.action == "up" then
        aim = aim - command.X  -- up X decreases your aim by X units.
    elseif command.action == "down" then
        aim = aim + command.X  -- down X increases your aim by X units.
    else
        io.stderr:write("malformed command '", tostring(command.action), "' at line #", line_num)
    end
end

print("num_commands:", #commands, "horiz", horiz, "aim", aim, "depth", depth, "horiz*depth", horiz*depth)

