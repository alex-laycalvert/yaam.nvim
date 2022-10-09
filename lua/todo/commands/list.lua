-- alex-laycalvert
-- https://github.com/alex-laycalvert/todo.nvim

local List = {}

local setup = require('todo.setup')
local windows = require('todo.windows')
local utils = require('todo.utils')

List.run = function ()
    local filename =
        setup.config.dir .. '/' ..
        setup.config.todo_filename ..
        utils.file_extensions[setup.config.todo_file_type]
    local todos = utils.read_todos(filename)
    local win, buf = windows.open(10, 10)
end

return List
