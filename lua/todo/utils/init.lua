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
            task_incomplete = '^ +%- *%[ %] *',
            task_complete = '^ +%- *%[x%] *',
            task_in_progress = '^ +%- *%[%-%] *',
            task_cancelled = '^ +%- *%[_%] *',
            task_urgent = '^ +%- *%[%!%] *',
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

Utils.format_todo_title = function (todo, width)
    local todo_lhs = Utils.concat_spaced(
        todo.type, todo.name,
        string.len(todo.name) + setup.max_type_length + 2
    )
    return Utils.concat_spaced(todo_lhs, todo.date, width)
end

Utils.read_todos = function ()
    local filename =
        setup.config.dir .. '/' ..
        setup.config.todo_filename ..
        Utils.file_extensions[setup.config.todo_file_type]
    local header_match = Utils.matches[setup.config.todo_file_type].header
    local project_match = Utils.matches[setup.config.todo_file_type].project
    local detail_match = Utils.matches[setup.config.todo_file_type].detail
    local task_incomplete_match = Utils.matches[setup.config.todo_file_type].task_incomplete
    local task_complete_match = Utils.matches[setup.config.todo_file_type].task_complete
    local task_in_progress_match = Utils.matches[setup.config.todo_file_type].task_in_progress
    local task_cancelled_match = Utils.matches[setup.config.todo_file_type].task_cancelled
    local task_urgent_match = Utils.matches[setup.config.todo_file_type].task_urgent
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
        elseif line:find(project_match) ~= nil and current_todo.type ~= '' then
            current_todo.project = line:
                gsub(project_match, '')
        elseif line:find(task_incomplete_match) ~= nil and current_todo.type ~= '' then
            local task = line:gsub(task_incomplete_match, '')
            table.insert(current_todo.tasks, {
                name = task,
                status = 'INCOMPLETE'
            })
        elseif line:find(task_complete_match) ~= nil and current_todo.type ~= '' then
            local task = line:gsub(task_complete_match, '')
            table.insert(current_todo.tasks, {
                name = task,
                status = 'COMPLETE'
            })
        elseif line:find(task_in_progress_match) ~= nil and current_todo.type ~= '' then
            local task = line:gsub(task_in_progress_match, '')
            table.insert(current_todo.tasks, {
                name = task,
                status = 'IN_PROGRESS'
            })
        elseif line:find(task_cancelled_match) ~= nil and current_todo.type ~= '' then
            local task = line:gsub(task_cancelled_match, '')
            table.insert(current_todo.tasks, {
                name = task,
                status = 'CANCELLED'
            })
        elseif line:find(task_urgent_match) ~= nil and current_todo.type ~= '' then
            local task = line:gsub(task_urgent_match, '')
            table.insert(current_todo.tasks, {
                name = task,
                status = 'URGENT'
            })
        elseif line:find(detail_match) ~= nil and current_todo.type ~= '' then
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
        local task = '  ['
        if v.status == 'INCOMPLETE' then
            task = task .. ' '
        elseif v.status == 'COMPLETE' then
            task = task .. 'x'
        elseif v.status == 'IN_PROGRESS' then
            task = task .. '-'
        elseif v.status == 'CANCELLED' then
            task = task .. '_'
        elseif v.status == 'URGENT' then
            task = task .. '!'
        end
        task = task .. '] ' .. v.name
        table.insert(lines, task)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

return Utils
