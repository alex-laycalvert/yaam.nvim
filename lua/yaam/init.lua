-- alex-laycalvert
-- https://github.com/alex-laycalvert/yaam.nvim

local Yaam = {}

local commands = require('yaam.commands')
local setup = require('yaam.setup')
local utils = require('yaam.utils')

local is_setup_complete = false

Yaam.setup = function (config)
    if not is_setup_complete then
        setup.setup(config)
    end
    is_setup_complete = true
    local filename =
        setup.config.dir .. '/' ..
        setup.config.agenda_filename ..
        utils.file_extensions[setup.config.agenda_file_type]
    local file = io.open(filename, 'r')
    if file ~= nil then
        file:close()
        return
    end
    local code = os.execute('touch ' .. filename)
    if code ~= 0 then
        print('Error: failed to create todo file ' .. filename)
        print('Exit Code: ' .. code)
        return
    end
    file = io.open(filename, 'w')
    if file == nil then
        print('Error: failed to create todo file for writing ' .. filename)
        return
    end
    io.output(file)
    io.write(utils.file_headers[setup.config.agenda_file_type])
    file:close()
end

Yaam.get_commands = function ()
    return commands.commands
end

Yaam.run_command = function (args)
    if not is_setup_complete then
        Yaam.setup({})
    end
    if args == nil then
        args = 'help'
    end
    commands.run(args)
end

return Yaam
