-- alex-laycalvert
-- https://github.com/alex-laycalvert/yaam.nvim

local Commands = {}

local has_telescope, _ = pcall(require, 'telescope')
if not has_telescope then
    error('This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim')
end

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
    require('yaam.commands.' .. command).run()
end

return Commands
