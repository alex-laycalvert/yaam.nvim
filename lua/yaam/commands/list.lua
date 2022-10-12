-- alex-laycalvert
-- https://github.com/alex-laycalvert/yaam.nvim

local List = {}

local setup = require('yaam.setup')
local utils = require('yaam.utils')
local pickers = require('yaam.pickers')
local windows = require('yaam.windows')

List.run = function ()
    local todos, num_todos = utils.read_todos()
    if num_todos <= 0 then return end
    pickers.todo_picker(todos, function (todo)
        windows.open_complete_window(todo)
    end)
end

return List
