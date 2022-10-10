if exists('b:current_syntax')
    finish
endif

syntax match TodoTaskIncomplete '\v\[ \]'
syntax match TodoTaskComplete '\v\[x\]'
syntax match TodoTaskInProgress '\v\[\-\]'
syntax match TodoTaskCancelled '\v\[_\]'
syntax match TodoTaskUrgent '\v\[\!\]'
syntax match TodoDate '\v\d\d:\d\d:\d\d \d\d:\d\d'

let b:current_syntax = 'todo'

highlight TodoTaskIncomplete guifg=Red
highlight TodoTaskComplete guifg=Green
highlight TodoTaskInProgress guifg=Magenta
highlight TodoTaskCancelled guifg=Gray
highlight TodoTaskUrgent guifg=Yellow guibg=Red
