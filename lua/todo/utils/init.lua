-- alex-laycalvert
-- https://github.com/alex-laycalvert/todo.nvim

local Utils = {}

local TODO_HEADER = '^%- %[ %] *'
local TODO_PROJECT = '^ +%- *Project: *'
local TODO_DETAILS = '^ +%- *'
local TODO_TASK = '^ +%- *%[ %] *'

Utils.split = function (input_string, delim)
    if delim == nil then delim = '%s' end
    local t = {}
    for str in string.gmatch(input_string, '([^' .. delim .. ']+)') do
        table.insert(t, str)
    end
    return t
end

Utils.read_lines = function (filename)
    local lines = {}
    local file = io.open(filename, 'r')
    if file == nil then return lines end
    file:close()
    for line in io.lines(filename) do
        table.insert(lines, line)
    end
    return lines
end

Utils.read_todos = function (filename)
    local contents = Utils.read_lines(filename)
    local todos = {}
    local current_todo = {
        type = '',
        name = '',
        date = '',
        project = '',
        details = {},
        tasks = {},
    }
    local num_spaces = 0
    local current_level = 0
    for _, line in pairs(contents) do
        if line:find(TODO_HEADER) ~= nil then
            if current_todo.type ~= '' then
                table.insert(todos, current_todo)
                current_todo = {
                    type = '',
                    name = '',
                    date = '',
                    project = '',
                    details = {},
                    tasks = {},
                }
            end
            current_todo.type = line:
                gsub(TODO_HEADER, ''):
                gsub(' *:.*', '')
            current_todo.name = line:
                gsub(TODO_HEADER, ''):
                gsub(current_todo.type .. ': *', ''):
                gsub('<.*>', '')
            current_todo.date = line:
                gsub(TODO_HEADER, ''):
                gsub(current_todo.type .. ': *', ''):
                gsub(current_todo.name .. ' *', ''):
                gsub('[<>]', '')
        elseif line:find(TODO_PROJECT) ~= nil then
            current_todo.project = line:
                gsub(TODO_PROJECT, '')
        elseif line:find(TODO_TASK) ~= nil then
            local task = line:gsub(TODO_TASK, '')
            table.insert(current_todo.tasks, task)
        elseif line:find(TODO_DETAILS) ~= nil then
            local detail = line:gsub(TODO_DETAILS, '')
            table.insert(current_todo.details, detail)
        end
    end
    if current_todo.type ~= nil then
        table.insert(todos, current_todo)
    end
    return todos
end

return Utils
