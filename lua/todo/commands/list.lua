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
    local todos, num_todos = utils.read_todos(filename)
    if num_todos <= 0 then return end
    local height = num_todos * 2 + 1
    local width = 70
    local win, buf = windows.open(height, width)
    windows.cursorline(win, true)
    local names = utils.map(todos, function (todo)
        local type_name_str = utils.concat_spaced(
            todo.type, todo.name,
            string.len(todo.name) + setup.max_type_length + 2
        )
        return utils.concat_spaced(type_name_str, todo.date, width - 2)
    end)
    windows.write_lines(win, buf, names, 1, 1, 1)
end

return List
