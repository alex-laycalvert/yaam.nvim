-- alex-laycalvert
-- https://github.com/alex-laycalvert/todo.nvim

local home = os.getenv('HOME')

local Setup = {
    config = {},
    max_type_length = 0,
    defaults = {
        dir = home,
        todo_filename = 'TODOS',
        todo_file_type = 'markdown',
        todo_types = {
            'OVERDUE',
            'TODO',
            'QUIZ',
            'TEST',
            'HOMEWORK',
            'PROJECT',
            'MEETING',
            'COMPLETE',
        },
    },
}

Setup.setup = function (config)
    Setup.config = vim.tbl_deep_extend('force', {}, Setup.defaults, config or {})
    local max = 0
    for _, v in pairs(Setup.config.todo_types) do
            local len = string.len(v)
            if len > max then
                max = len
            end
    end
    vim.g.todo_task_types = Setup.config.todo_types
    Setup.max_type_length = max
end

Setup.configure_task_highlights = function ()
    for _, type in pairs(Setup.config.todo_types) do
        vim.cmd('syntax keyword TodoTaskType ' .. type)
    end
end

return Setup
