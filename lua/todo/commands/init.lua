-- alex-laycalvert
-- https://github.com/alex-laycalvert/todo.nvim

local Commands = {}

Commands.commands = {
    'list',
    'add',
    'edit',
    'delete',
    'calendar',
    'projects',
    'help',
}

Commands.run = function (command)
    require('todo.commands.' .. command).run()
end

return Commands
