# nomplete.vim

Plugin cho Vim và Neovim cho phép bạn gõ chữ Hán (漢字) và chữ Nôm (𡨸喃) từ chữ quốc ngữ.

## Cài đặt

Bạn có thể cài đặt plugin này bằng bất kỳ trình quản lý plugin nào có hỗ trợ Git. Ví dụ với vim-plug

```vim
Plug 'brianhuster/nomplete.vim'
```

### Cài đặt font chữ Nôm

Để hiển thị chữ Nôm thì bạn cần cài đặt và sử dụng một font chữ có hỗ trợ chữ Nôm.

Hiện nay đã có một số font hỗ trợ chữ Nôm, cả họ không chân (sans-serif) và có
chân (serif), bạn có thể tìm và cài đặt từ các trang web sau:
- [Chunom.org - Fonts](https://chunom.org/pages/fonts/)
- [https://www.hannom-rcv.org/font.html](https://www.hannom-rcv.org/font.html)
- [https://hvdic.thivien.net/fonts.php](https://hvdic.thivien.net/fonts.php)

Tuy nhiên, theo như mình biết thì hiện tại vẫn chưa có font nào thuộc họ
monospace, tuy vậy bạn có thể yêu cầu hệ điều hành fallback về một font chữ Nôm
không chân. Dưới đây là hướng dẫn cho Ubuntu
- Tải xuống một font chữ Nôm không chân, ở đây mình sẽ dùng [Han-Nom
  Gothic](https://drive.google.com/drive/folders/0ByXIvWRASkT9Y0J3Y3E0QTJvZG8?resourcekey=0-PjsVEMQMfBgUOOWwRV1OJQ)
- Copy file `ttf` hoặc `otf` vào thư mục `~/.local/share/fonts/`
- Tạo (hoặc chỉnh sửa) file cấu hình fontconfig `~/.config/fontconfig/fonts.conf` với nội dung sau:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
        <alias>
            <family>monospace</family>
            <prefer>
                <family>Han-Nom Gothic</family>
            </prefer>
        </alias>
    </fontconfig>
```
- Chạy lệnh `fc-cache -fv` để cập nhật cache font
- Khởi động lại terminal và kiểm tra

## Đóng góp

Mọi đóng góp đều được hoan nghênh! Vui lòng tạo issue hoặc pull request trên GitHub.

## Credits

Danh sách chữ Nôm được thu thập và xử lý từ các nguồn mở sau:
- [ph0ngp/hanviet-pinyin-wordlist](https://github.com/ph0ngp/hanviet-pinyin-wordlist)
- [chunom.org - List of Standard Characters](https://chunom.org/pages/standard/)
