-- alex-laycalvert
-- https://github.com/alex-laycalvert/yaam.nvim

local Windows = {}

local utils = require('yaam.utils')

Windows.open_buffer = function ()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    return buf
end

Windows.open = function (height, width)
    local gwidth = vim.api.nvim_list_uis()[1].width
    local gheight = vim.api.nvim_list_uis()[1].height
    local win_opts = {
        relative = 'editor',
        style = 'minimal',
        border = 'single',
        height = height,
        width = width,
        row = (gheight - height) * 0.5,
        col = (gwidth - width) * 0.5
    }
    local buf = Windows.open_buffer()
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    return win, buf
end

Windows.close = function (win)
    vim.api.nvim_win_close(win, true)
end

Windows.write = function (win, buf, text, row, col, center)
    if buf <= 0 or win <= 0 then return end
    local width = vim.api.nvim_win_get_width(win)
    if center then
        text = utils.center_line(text, width)
    else
        text = utils.pad_left(text, string.len(text) + col)
    end
    vim.api.nvim_buf_set_lines(buf, row, -1, false, {
        text
    })
end

Windows.write_lines = function (win, buf, lines, row, col, spacing, center)
    if buf <= 0 or win <= 0 then return end
    if spacing == nil then spacing = 0 end
    local width = vim.api.nvim_win_get_width(win)
    local lines_to_write = {}
    for k, line in pairs(lines) do
        local text = line
        if center then
            text = utils.center_line(line, width)
        else
            text = utils.pad_left(text, string.len(text) + col)
        end
        table.insert(lines_to_write, text)
        for i = 1, spacing do
            table.insert(lines_to_write, '')
        end
    end
    vim.api.nvim_buf_set_lines(buf, row, -1, false, lines_to_write)
end

Windows.cursorline = function (win, on)
    if on == nil then on = true end
    vim.api.nvim_win_set_option(win, 'cursorline', on)
end

return Windows
