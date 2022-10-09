-- alex-laycalvert
-- https://github.com/alex-laycalvert/todo.nvim

local List = {}

local setup = require('todo.setup')
local utils = require('todo.utils')

List.run = function ()
    local filename =
        setup.config.dir .. '/' ..
        setup.config.todo_filename ..
        utils.file_extensions[setup.config.todo_file_type]
    for _, todo in pairs(utils.read_todos(filename)) do
        print('--------------------------------')
        print('Type:', todo.type)
        print('Name:', todo.name)
        print('Date:', todo.date)
        print('Project:', todo.project)
        print('Details:')
        for _, detail in pairs(todo.details) do
            print('  -', detail)
        end
        print('Tasks:')
        for _, task in pairs(todo.tasks) do
            print('  -', task)
        end
        print('--------------------------------')
    end
end

return List
