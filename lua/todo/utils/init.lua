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

Utils.map = function (tbl, f)
    local t = {}
    for k, v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

Utils.pad_left = function (str, length, char)
    if char == nil then char = ' ' end
    local new_str = str
    local len = string.len(new_str)
    while len < length do
        new_str = char .. new_str
        len = len + 1
    end
    return new_str
end

Utils.trim_left = function (str, char)
    if char == nil then char = ' ' end
    return str:gsub('^' .. char .. '*', '')
end

Utils.concat_spaced = function (str1, str2, length, char)
    if char == nil then char = ' ' end
    local len1 = string.len(str1)
    local len2 = string.len(str2)
    local new_str = str1
    local total_len = len1 + len2
    while total_len < length do
        new_str = new_str .. char
        total_len = total_len + 1
    end
    return new_str .. str2
end

Utils.center_line = function (str, width)
    local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
    return string.rep(' ', shift) .. str
end

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
    local num_todos = 0
    local todos = {}
    local current_todo = {
        type = '',
        name = '',
        date = '',
        project = '',
        details = {},
        tasks = {},
    }
    for _, line in pairs(contents) do
        if line:find(header_match) ~= nil then
            if current_todo.type ~= '' then
                num_todos = num_todos + 1
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
        num_todos = num_todos + 1
        table.insert(todos, current_todo)
    end
    return todos, num_todos
end

Utils.buf_write_todo = function (buf, todo, title)
    local lines = {
        '',
        ' ' .. title,
        '',
    }
    for _, v in pairs(todo.details) do
        table.insert(lines, ' ' .. v)
    end
    if #todo.tasks > 0 then
        table.insert(lines, '')
        table.insert(lines, ' Tasks:')
    end
    for _, v in pairs(todo.tasks) do
        table.insert(lines, ' - [ ] ' .. v)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

return Utils
