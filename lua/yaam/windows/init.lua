-- alex-laycalvert
-- https://github.com/alex-laycalvert/yaam.nvim

local Windows = {
    win = -1,
    buf = -1,
}

local utils = require('yaam.utils')
local setup = require('yaam.setup')
local telescope_preview_utils = require('telescope.previewers.utils')

Windows.open_buffer = function ()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    return buf
end

Windows.open_floating_window = function (height, width, border)
    if Windows.buf <= 0 then
        Windows.buf = Windows.open_buffer()
    end
    local gwidth = vim.api.nvim_list_uis()[1].width
    local gheight = vim.api.nvim_list_uis()[1].height
    local win_opts = {
        relative = 'editor',
        style = 'minimal',
        height = height,
        width = width,
        row = (gheight - height) * 0.5,
        col = (gwidth - width) * 0.5
    }
    win_opts.border = border
    local win = vim.api.nvim_open_win(Windows.buf, true, win_opts)
    return win
end

Windows.open_side_window = function (width)
    if Windows.buf <= 0 then
        Windows.buf = Windows.open_buffer()
    end
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, Windows.buf)
    vim.api.nvim_win_set_width(win, width)
    vim.api.nvim_win_set_option(win, 'number', false)
    return win
end

Windows.open_todo = function (todo)
    if setup.config.todo_window_type == 'floating' then
        Windows.open_floating_todo(todo)
    elseif setup.config.todo_window_type == 'side' then
        Windows.open_side_todo(todo)
    end
end

Windows.open_floating_todo = function (todo, padding)
    if padding == nil then padding = 1 end
    local title = utils.format_todo_title(todo)
    local height = utils.item_height(todo) + 2 * padding
    local width = utils.max_item_length(todo) + 2 * padding
    Windows.win = Windows.open_floating_window(height, width)
    telescope_preview_utils.regex_highlighter(Windows.buf, 'yaam')
    utils.buf_write_todo(Windows.buf, todo, title)
end

Windows.open_side_todo = function (todo, padding)
    if padding == nil then padding = 1 end
    local title = utils.format_todo_title(todo)
    local width = utils.max_item_length(todo) + 2 * padding
    Windows.win = Windows.open_side_window(width)
    telescope_preview_utils.regex_highlighter(Windows.buf, 'yaam')
    utils.buf_write_todo(Windows.buf, todo, title)
end

Windows.open_complete_window = function (todo)
    local prompt = 'Complete ' .. todo.type .. ' ' .. todo.name .. '? (y/N) '
    Windows.win = Windows.open_floating_window(1, string.len(prompt), 'single')
    vim.api.nvim_buf_set_lines(Windows.buf, 0, -1, false, {
        prompt
    })
    vim.api.nvim_buf_set_option(Windows.buf, 'modifiable', false)
end

Windows.close = function ()
    if Windows.win > 0 and setup.config.todo_window_type == 'floating' then
        vim.api.nvim_win_close(Windows.win, true)
    end
    Windows.buf = -1
    Windows.win = -1
end

return Windows
