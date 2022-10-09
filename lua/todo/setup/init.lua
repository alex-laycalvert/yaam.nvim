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
    local max = 0
    for _, v in pairs(Setup.config.todo_types) do
        local len = string.len(v)
        if len > max then
            max = len
        end
    end
    Setup.max_type_length = max
end

return Setup
