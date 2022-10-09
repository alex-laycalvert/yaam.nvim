-- alex-laycalvert
-- https://github.com/alex-laycalvert/todo.nvim

local Todo = {}

local commands = require('todo.commands')

Todo.setup = function ()
end

Todo.get_commands = function ()
    return commands.commands
end

Todo.run_command = function (args)
    if args == nil then
        args = 'help'
    end
    commands.run(args)
end

return Todo
