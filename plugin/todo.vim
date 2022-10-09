" alex-laycalvert
" https://github.com/alex-laycalvert/todo.nvim

if exists('g:loaded_todo_plugin')
    finish
endif
let g:loaded_todo_plugin = 1

function s:todo_complete(args, line, pos)
    let l:candidates = luaeval('require("todo").get_commands()')
    return join(l:candidates, "\n")
endfunction

command! -nargs=? -complete=custom,s:todo_complete Todo lua require('todo').run_command(<f-args>)
