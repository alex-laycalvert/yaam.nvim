-- alex-laycalvert
-- https://github.com/alex-laycalvert/todo.nvim

local List = {}

local setup = require('todo.setup')
local utils = require('todo.utils')
local pickers = require('todo.pickers')

List.run = function ()
    local todos, num_todos = utils.read_todos()
    if num_todos <= 0 then return end
    pickers.todo_picker(todos, function (todo)
        print(todo.name)
    end)
end

return List
