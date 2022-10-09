-- alex-laycalvert
-- https://github.com/alex-laycalvert/todo.nvim

local home = os.getenv('HOME')

local Setup = {
    config = {},
    defaults = {
        dir = home,
        todo_filename = 'TODOS',
        todo_file_type = 'markdown',
        todo_types = {
            'TODO',
            'QUIZ',
            'TEST',
            'HOMEWORK',
            'PROJECT',
            'MEETING',
        }
    },
}

Setup.setup = function (config)
    Setup.config = vim.tbl_deep_extend('force', {}, Setup.defaults, config or {})
end

return Setup
