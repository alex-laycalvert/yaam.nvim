-- alex-laycalvert
-- https://github.com/alex-laycalvert/todo.nvim

local Utils = {
    file_extensions = {
        markdown = '.md',
    },
    file_headers = {
        markdown = '# TODOS',
    },
    matches = {
        markdown = {
            header = '^%- %[ %] *',
            project = '^ +%- *Project: *',
            detail = '^ +%- *',
            task = '^ +%- *%[ %] *',
        },
    },
}

local setup = require('todo.setup')

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
    local header_match = Utils.matches[setup.config.todo_file_type].header
    local project_match = Utils.matches[setup.config.todo_file_type].project
    local detail_match = Utils.matches[setup.config.todo_file_type].detail
    local task_match = Utils.matches[setup.config.todo_file_type].task
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
        if line:find(header_match) ~= nil then
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
                gsub(header_match, ''):
                gsub(' *:.*', '')
            current_todo.name = line:
                gsub(header_match, ''):
                gsub(current_todo.type .. ': *', ''):
                gsub('<.*>', '')
            current_todo.date = line:
                gsub(header_match, ''):
                gsub(current_todo.type .. ': *', ''):
                gsub(current_todo.name .. ' *', ''):
                gsub('[<>]', '')
        elseif line:find(project_match) ~= nil then
            current_todo.project = line:
                gsub(project_match, '')
        elseif line:find(task_match) ~= nil then
            local task = line:gsub(task_match, '')
            table.insert(current_todo.tasks, task)
        elseif line:find(detail_match) ~= nil then
            local detail = line:gsub(detail_match, '')
            table.insert(current_todo.details, detail)
        end
    end
    if current_todo.type ~= nil then
        table.insert(todos, current_todo)
    end
    return todos
end

return Utils
