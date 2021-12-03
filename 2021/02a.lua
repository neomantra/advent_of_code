#!lua
-- cat 02.test.txt | ./02a.lua


local function split_string(str, sep)
    local sep, fields = sep or " ", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
 end


local function read_commands_from_stdin()
    local commands = {}
    local line_num = 0
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


local commands = read_commands_from_stdin()

local horiz, depth = 0, 0

for n, command in ipairs(commands) do
    if command.action == "forward" then
        horiz = horiz + command.X
    elseif command.action == "up" then
        depth = depth - command.X  -- up decreases depth
    elseif command.action == "down" then
        depth = depth + command.X  -- down increases depth
    else
        io.stderr:write("malformed command '", tostring(command.action), "' at line #", line_num)
    end
end

print("num_commands:", #commands, "horiz", horiz, "depth", depth, "horiz*depth", horiz*depth)

