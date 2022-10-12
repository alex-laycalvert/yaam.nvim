-- alex-laycalvert
-- https://github.com/alex-laycalvert/yaam.nvim

local Utils = {
    file_extensions = {
        markdown = '.md',
    },
    file_headers = {
        markdown = '# TODOS',
    },
    matches = {
        markdown = {
            header = '^%- %[.%] *',
            header_incomplete = '^%- %[ %] *',
            header_complete = '^%- %[x%] *',
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

local setup = require('yaam.setup')

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

Utils.format_todo_title = function (todo, with_equal_spacing, with_date)
    if with_date == nil then with_date = true end
    if with_equal_spacing == nil then with_equal_spacing = false end
    local title = todo.date
    if not with_date then
        title = todo.date:gsub(' .*', '')
    end
    title = title .. '  ' .. todo.type
    if with_equal_spacing then
        title =
            title .. string.rep(
                ' ',
                setup.max_type_length - string.len(todo.type)
            )
    else
    end
    return title .. '  ' .. todo.name
end

Utils.read_todos = function ()
    local filename =
        setup.config.dir .. '/' ..
        setup.config.agenda_filename ..
        Utils.file_extensions[setup.config.agenda_file_type]
    local header_match = Utils.matches[setup.config.agenda_file_type].header
    local header_incomplete_match = Utils.matches[setup.config.agenda_file_type].header
    local header_complete_match = Utils.matches[setup.config.agenda_file_type].header
    local project_match = Utils.matches[setup.config.agenda_file_type].project
    local detail_match = Utils.matches[setup.config.agenda_file_type].detail
    local task_incomplete_match = Utils.matches[setup.config.agenda_file_type].task_incomplete
    local task_complete_match = Utils.matches[setup.config.agenda_file_type].task_complete
    local task_in_progress_match = Utils.matches[setup.config.agenda_file_type].task_in_progress
    local task_cancelled_match = Utils.matches[setup.config.agenda_file_type].task_cancelled
    local task_urgent_match = Utils.matches[setup.config.agenda_file_type].task_urgent
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
                    status = '',
                    type = '',
                    name = '',
                    date = '',
                    project = '',
                    details = {},
                    tasks = {},
                }
            end
            if line:find(header_incomplete_match) ~= nil then
                current_todo.status = 'INCOMPLETE'
            else
                current_todo.status = 'COMPLETE'
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

Utils.item_height = function (todo)
    local height = 1
    local details_len = #todo.details
    local tasks_len = #todo.tasks
    if details_len > 0 then
        height = height + 1 + details_len
    end
    if tasks_len > 0 then
        height = height + 2 + tasks_len
    end
    return height
end

Utils.max_item_length = function (todo)
    local title = Utils.format_todo_title(todo)
    local max = string.len(title)
    for _, v in pairs(todo.details) do
        local len = string.len(v)
        if len > max then max = len end
    end
    for _, v in pairs(todo.tasks) do
        local len = string.len(v.name) + 6
        if len > max then max = len end
    end
    return max
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
