# nomplete.vim

Plugin Vim hỗ trợ hoàn tất chữ Nôm (Hán-Nôm) từ âm Hán Việt.

## Giới thiệu

`nomplete.vim` là một plugin Vim giúp bạn dễ dàng nhập chữ Nôm (Hán-Nôm) bằng cách gõ âm Hán Việt tương ứng. Plugin cung cấp danh sách các ký tự Nôm phù hợp để bạn chọn lựa.

## Cài đặt

### Sử dụng vim-plug

Thêm dòng sau vào file cấu hình Vim của bạn (`.vimrc` hoặc `init.vim`):

```vim
Plug 'brianhuster/nomplete.vim'
```

Sau đó chạy lệnh:

```vim
:PlugInstall
```

### Sử dụng packer.nvim (dành cho Neovim)

```lua
use 'brianhuster/nomplete.vim'
```

### Cài đặt thủ công

Clone repository này vào thư mục plugin của Vim:

```bash
git clone https://github.com/brianhuster/nomplete.vim ~/.vim/pack/plugins/start/nomplete.vim
```

Hoặc đối với Neovim:

```bash
git clone https://github.com/brianhuster/nomplete.vim ~/.local/share/nvim/site/pack/plugins/start/nomplete.vim
```
## Đóng góp

Mọi đóng góp đều được hoan nghênh! Vui lòng tạo issue hoặc pull request trên GitHub.
