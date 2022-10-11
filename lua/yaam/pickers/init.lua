-- alex-laycalvert
-- https://github.com/alex-laycalvert/yaam.nvim

local Pickers = {}

local utils = require('yaam.utils')
local setup = require('yaam.setup')

local telescope_utils = require('telescope.utils')
local defaulter = telescope_utils.make_default_callable
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local preview_utils = require('telescope.previewers.utils')
-- local conf = require('telescope.config').values

Pickers.preview = defaulter(function (opts)
    return previewers.new_buffer_previewer({
        setup = opts.setup or function ()
            return opts.results
        end,
        define_preview = opts.define_preview or function (self, entry)
            preview_utils.regex_highlighter(self.state.bufnr, 'todo')
            utils.buf_write_todo(self.state.bufnr, entry.value, utils.format_todo_title(entry.value, 50))
        end,
        dyn_title = opts.dyn_title or function (_, entry)
            return entry.value.name
        end,
    })
end)

Pickers.todo_picker = function (todos, action)
    local results = {}
    for k, todo in pairs(todos) do
        results[k] = {
            todo = todo,
            title = utils.format_todo_title(todo, 70)
        }
    end

    pickers.new({}, {
        prompt_title = 'TODOs',
        finder = finders.new_table({
            results = results,
            entry_maker = function (entry)
                return {
                    value = entry.todo,
                    display = entry.title,
                    ordinal = entry.title,
                }
            end,
        }),
        previewer = Pickers.preview.new({
            results = results,
        }),
        -- sorter = conf.generic_sorter(opts),
        attach_mappings = function ()
            actions.select_default:replace(function (prompt_bufnr, map)
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection ~= nil then
                    action(selection.value)
                end
            end)
            return true
        end,
    }):find()
end

return Pickers
