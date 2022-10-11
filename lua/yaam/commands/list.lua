-- alex-laycalvert
-- https://github.com/alex-laycalvert/yaam.nvim

local List = {}

local utils = require('yaam.utils')
local pickers = require('yaam.pickers')

List.run = function ()
    local todos, num_todos = utils.read_todos()
    if num_todos <= 0 then return end
    pickers.todo_picker(todos, function (todo)
        print(todo.name)
    end)
end

return List
