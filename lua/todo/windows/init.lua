-- alex-laycalvert
-- https://github.com/alex-laycalvert/todo.nvim

local Windows = {}

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
    return { buf, win }
end

Windows.close = function (win) 
    vim.api.nvim_win_close(win, true)
end

return Windows
