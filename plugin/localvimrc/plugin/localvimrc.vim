vim9script noclear

var cwd = ''
g:localvimrcdebug = false

def LocalVimrcDebug(msg: string)
    if !g:localvimrcdebug
        return
    endif

    writefile([ strftime("%x %T") .. " | " .. msg ], '/tmp/localvimrc.log', 'a')
enddef

export def g:LocalVimrcRun()
	LocalVimrcDebug("LocalVimrcRunning")
	if cwd == getcwd(winnr('$'))
		LocalVimrcDebug("Localvimrc already loaded '" .. cwd .. "'")
		return
	endif

	var directory = fnameescape(expand("%:p:h"))
	var rcfiles = []
	for rcfile in findfile('.localvimrc', directory, -1)
		if filereadable(rcfile)
			LocalVimrcDebug("Localvimrc successful loaded '" .. rcfile .. "'")
			exec 'source' rcfile
		endif
	endfor

	cwd = getcwd(winnr('$'))
enddef

defcompile

augroup LocalVimRC
	autocmd BufWinEnter * call LocalVimrcRun()
augroup END
