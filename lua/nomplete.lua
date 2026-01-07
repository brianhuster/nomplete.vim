local M = {}

local ffi = require("ffi")

if vim.fn.has("win32") == 1 then
	local Normaliz = ffi.load("Normaliz")
	local NormalizationC = 1 -- NFC

	ffi.cdef [[
	int NormalizeString(
		int NormForm,
		const wchar_t *src,
		int src_len,
		wchar_t *dst,
		int dst_len
	);
	]]

	function M.utf8_normalize(str)
		if str == "" then
			return ""
		end

		local u16 = vim.uv.wtf8_to_utf16(str)

		-- Convert Lua UTF-16 string → wchar_t[]
		local wlen = #u16 / 2
		local wbuf = ffi.new("wchar_t[?]", wlen)
		ffi.copy(wbuf, u16, #u16)

		-- Query normalized length
		local nlen = Normaliz.NormalizeString(
			NormalizationC,
			wbuf,
			wlen,
			nil,
			0
		)
		if nlen <= 0 then return nil end

		local nbuf = ffi.new("wchar_t[?]", nlen)

		local ok = Normaliz.NormalizeString(
			NormalizationC,
			wbuf,
			wlen,
			nbuf,
			nlen
		)
		if ok <= 0 then return nil end

		local u16norm = ffi.string(ffi.cast("char*", nbuf), ok * 2)

		return vim.uv.utf16_to_wtf8(u16norm)
	end
else
	ffi.cdef[[
	typedef int utf8proc_ssize_t;

	typedef enum {
		UTF8PROC_COMPOSE = (1<<3),
		UTF8PROC_IGNORE = (1<<5)
	} utf8proc_option_t;

	typedef unsigned char utf8proc_uint8_t;

	utf8proc_ssize_t utf8proc_map(
		const utf8proc_uint8_t *str, utf8proc_ssize_t strlen, utf8proc_uint8_t **dstptr, utf8proc_option_t options
	);

	void free(void *ptr);
	]]

	local c = ffi.C

	local flags = c.UTF8PROC_COMPOSE + c.UTF8PROC_IGNORE

	function M.utf8_normalize(str)
		local out = ffi.new("utf8proc_uint8_t*[1]")

		local rc = c.utf8proc_map(
			ffi.cast("const utf8proc_uint8_t*", str),
			#str, out, flags
		)

		if rc < 0 then
			return nil, rc
		end

		local res = ffi.string(out[0], rc)
		c.free(out[0])
		return res
	end
end

return M
