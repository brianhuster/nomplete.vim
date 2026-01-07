VIM_PATH ?= vim

ifeq ($(OS),Windows_NT)
  NUL := NUL
else
  NUL := /dev/null
endif

.PHONY: vader.vim test

vader:
	git clone --depth=1 https://github.com/junegunn/vader.vim.git || true

test: vader
	$(VIM_PATH) -Nu test/vimrc -c 'silent Vader! test/*' > $(NUL)
