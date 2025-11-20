if exists('g:loaded_nomplete')
	finish
endif
let g:loaded_nomplete = 1

let s:data_file = expand("<script>:p:h:h") . '/dict.json'
let s:chunom_dict = {}

func! s:load_data() abort
	if !filereadable(s:data_file)
		echoerr 'Không tìm thấy ' . s:data_file
		return
	endif
	let json_text = readfile(s:data_file)->join("\n")
	let s:chunom_dict = json_decode(json_text)
endfunc

func! s:normalize(word) abort
	let word = tolower(a:word)

	let uy_dict = {"úy": "uý", "ùy": "uỳ", "ủy": "uỷ", "ũy": "uỹ", "ụy": "uỵ"}
	let wordlen = strcharlen(word)
	let word_uy_part = strcharpart(word, wordlen - 2, 2)
	if has_key(uy_dict, word_uy_part)
		return strcharpart(word, 0, wordlen - 2) .. uy_dict[word_uy_part]
	else
		return word
	endif
endfunc

func! s:get_current_word() abort
	let line = getline('.')
	let word = line->strpart(0, col('.') - 1)
		\ ->matchstr('\v([[:lower:][:upper:]]+)$')
		\ ->s:normalize()
	if empty(word)
		" get the last character in line
		let word = line->strpart(col('.') - 2, 1)
	endif
	return word
endfunc

func! s:quocNgu2chuNom(word) abort
	let word = s:normalize(a:word)

	if empty(s:chunom_dict)
		call s:load_data()
	endif
	if !has_key(s:chunom_dict, word)
		echo "Không có chữ Nôm cho '" . word . "'"
		return
	endif

	return s:chunom_dict[word]
endfunc

if v:testing
	func! nomplete#normalize(word) abort
		return s:normalize(a:word)
	endfunc

	func! nomplete#quocNgu2chuNom(word) abort
		return s:quocNgu2chuNom(a:word)
	endfunc
endif

func! s:complete_chunom() abort
	let word = s:get_current_word()
	if empty(word)
		echo 'Không tìm thấy âm tiết hợp lệ'
		return
	endif

	let chars = s:quocNgu2chuNom(word)
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
endfunc

inoremap <silent> <Plug>(nomplete) <Cmd>call <SID>complete_chunom()<CR>
