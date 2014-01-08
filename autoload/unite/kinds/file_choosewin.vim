scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


" original code
" https://github.com/t9md/vim-choosewin/pull/1#issuecomment-31319352
let g:unite#kinds#file_choosewin#user_action = get(g:, "unite#kinds#file_choosewin#user_action", "")


function! unite#kinds#file_choosewin#define()
	return {}
endfunction


function! s:dummy_is_ignore_window(...)
	return 0
endfunction

" let g:Unite#kinds#file_choosewin#is_ignore_window_func = get(g:, "Unite#kinds#file_choosewin#is_ignore_window_func", function("s:dummy_is_ignore_window"))
let g:Unite_kinds_choosewin_is_ignore_window_func = get(g:, "Unite_kinds_choosewin_is_ignore_window_func", function("s:dummy_is_ignore_window"))

let s:default_choosewin_config = { "auto_choose" : 1 }
let g:unite#kinds#file_choosewin#choosewin_config = get(g:, "unite#kinds#file_choosewin#choosewin_config", {})


function! s:get_choosewin_config(...)
	let config = get(a:, 1, {})
	return extend(deepcopy(s:default_choosewin_config), extend(deepcopy(g:unite#kinds#file_choosewin#choosewin_config), config))
endfunction


function! unite#kinds#file_choosewin#start(action, candidate)
	let old = g:choosewin_return_on_single_win
	let g:choosewin_return_on_single_win = 0
	try
		let window = choosewin#start(filter(range(1, winnr('$')), '!g:Unite_kinds_choosewin_is_ignore_window_func(a:action, v:val)'), s:get_choosewin_config())
		if empty(window)
			return
		endif
		call unite#take_action(a:action, a:candidate)
	finally
		let g:choosewin_return_on_single_win = old
	endtry
endfunction


function! unite#kinds#file_choosewin#register_action(action, ...)
	let kind = get(a:, 1, "file")
	let action = {
	\	'is_selectable' : 1,
	\	"choosewin_action" : a:action
	\}

	function! action.func(candidates)
		for candidate in a:candidates
			call unite#kinds#file_choosewin#start(self.choosewin_action, candidate)
		endfor
	endfunction

	call unite#custom_action(kind, 'choosewin/' . a:action, action)
endfunction


call unite#kinds#file_choosewin#register_action("open")
call unite#kinds#file_choosewin#register_action("split")
call unite#kinds#file_choosewin#register_action("vsplit")


" choosewin/user
let s:action = {
\	'is_selectable' : 1
\}

function! s:action.func(candidates)
	if empty(g:unite#kinds#file_choosewin#user_action)
		return
	endif
	for candidate in a:candidates
		call unite#kinds#file_choosewin#start(self.choosewin_action, candidate)
	endfor
endfunction

call unite#custom_action('file', 'choosewin/user', s:action)



let &cpo = s:save_cpo
unlet s:save_cpo
