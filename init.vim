if get(s:, 'loaded', 0) != 0
	finish
else
	let s:loaded = 1
endif

let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')

command! -nargs=1 LoadScript exec 'so '.s:home.'/'.'<args>'

LoadScript config/basic.vim

LoadScript config/style.vim

LoadScript config/keymap.vim
