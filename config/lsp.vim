""""if executable('ccls')
""""    au User lsp_setup call lsp#register_server({
""""	\ 'name': 'ccls',
""""	\ 'cmd': {server_info->['ccls']},
""""	\ 'root_uri':{server_info->lsp#utils#path_to_uri(
""""	\	lsp#utils#find_nearest_parent_file_directory(
""""	\		lsp#utils#get_buffer_path(),
""""	\		['.ccls', 'compile_commands.json', '.git/']
""""	\	))},
""""	\ 'initialization_options': {},
""""	\ 'allowlist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
""""	\ })
""""endif
