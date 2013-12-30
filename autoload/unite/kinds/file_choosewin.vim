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


function! unite#kinds#file_choosewin#start(action, candidate)
	let old = g:choosewin_return_on_single_win
	let g:choosewin_return_on_single_win = 0
	try
		let window = choosewin#start(filter(range(1, winnr('$')), '!g:Unite_kinds_choosewin_is_ignore_window_func(a:action, v:val)'), 1)
		if empty(window)
			return
		endif
		call unite#take_action(a:action, a:candidate)
	finally
		let g:choosewin_return_on_single_win = old
	endtry
endfunction


function! unite#kinds#file_choosewin#regist_action(action, ...)
	let kind = get(a:, 1, "file")
	let action = {
	\	'is_selectable' : 0,
	\	"choosewin_action" : a:action
	\}

	function! action.func(candidate)
		call unite#kinds#file_choosewin#start(self.choosewin_action, a:candidate)
	endfunction

	call unite#custom_action(kind, 'choosewin/' . a:action, action)
endfunction


call unite#kinds#file_choosewin#regist_action("open")
call unite#kinds#file_choosewin#regist_action("split")
call unite#kinds#file_choosewin#regist_action("vsplit")


" choosewin/user
let s:action = {
\	'is_selectable' : 0
\}

function! s:action.func(candidate)
	if empty(g:unite#kinds#file_choosewin#user_action)
		return
	endif
	call unite#kinds#file_choosewin#start(g:unite#kinds#file_choosewin#user_action, a:candidate)
endfunction

call unite#custom_action('file', 'choosewin/user', s:action)



let &cpo = s:save_cpo
unlet s:save_cpo
