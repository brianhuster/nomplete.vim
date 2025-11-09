if exists('g:loaded_nomit')
	finish
endif
let g:loaded_nomit = 1

let s:data_file = expand("<script>:p:h:h") . '/dict.json'
let s:chunom_dict = {}

function! s:load_data() abort
	if !filereadable(s:data_file)
		echoerr 'Không tìm thấy ' . s:data_file
		return
	endif
	try
		let json_text = join(readfile(s:data_file), "\n")
		let s:chunom_dict = json_decode(json_text)
	catch /^Vim\%((\a\+)\)\=:E/
		echoerr 'Lỗi khi đọc JSON!'
	endtry
endfunction

function! s:get_current_word() abort
	return getline('.')
		\ ->strpart(0, col('.') - 1)
		\ ->matchstr('\v([[:lower:][:upper:]]+)$')
		\ ->tolower()
endfunction

function! s:complete_chunom() abort
	if empty(s:chunom_dict)
		call s:load_data()
	endif
	let word = s:get_current_word()
	if empty(word)
		echo 'Không tìm thấy âm tiết hợp lệ'
		return
	endif

	if !has_key(s:chunom_dict, word)
		echo "Không có chữ Nôm cho '" . word . "'"
		return
	endif

	let chars = s:chunom_dict[word]
	if empty(chars)
		echo "Không có chữ Nôm cho '" . word . "'"
		return
	endif

	let items = []
	for c in chars
		call add(items, #{word: c, abbr: c, menu: ''})
	endfor

	let startcol = col('.') - len(word)
	call complete(startcol, items)
endfunction

inoremap <silent> <Plug>(nomplete) <Cmd>call <SID>complete_chunom()<CR>
