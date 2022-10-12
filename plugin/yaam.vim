" alex-laycalvert
" https://github.com/alex-laycalvert/todo.nvim

if exists('g:loaded_yaam_plugin')
    finish
endif
let g:loaded_todo_plugin = 1

function s:yaam_complete(args, line, pos)
    let l:candidates = luaeval('require("yaam").get_commands()')
    return join(l:candidates, "\n")
endfunction

command! -nargs=? -complete=custom,s:yaam_complete Yaam lua require('yaam').run_command(<f-args>)
