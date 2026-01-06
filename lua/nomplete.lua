local M = {}

local ffi = require("ffi")
local os = jit.os

if os == "OSX" then
    ffi.cdef[[
    typedef const void * CFStringRef;
    typedef void * CFMutableStringRef;
    typedef unsigned char UInt8;
    typedef long CFIndex;
    typedef unsigned int CFStringEncoding;

    CFStringRef CFStringCreateWithBytes(
        void *alloc,
        const UInt8 *bytes,
        CFIndex numBytes,
        CFStringEncoding encoding,
        int isExternalRepresentation
    );

    CFMutableStringRef CFStringCreateMutableCopy(
        void *alloc,
        CFIndex maxLength,
        CFStringRef theString
    );

    void CFStringNormalize(CFMutableStringRef theString, int theForm);

    int CFStringGetCString(
        CFStringRef theString,
        char *buffer,
        CFIndex bufferSize,
        CFStringEncoding encoding
    );

    CFIndex CFStringGetLength(CFStringRef theString);
    void CFRelease(const void *);
    ]]

    local cf = ffi.load("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")

    local kCFStringEncodingUTF8   = 0x08000100
    local kCFStringNormalizationFormC = 2

    function M.utf8_normalize(str)
        local cfstr_imm = cf.CFStringCreateWithBytes(
            nil, str, #str, kCFStringEncodingUTF8, 0
        )
        if cfstr_imm == nil then
            return nil
        end

        local cfstr = cf.CFStringCreateMutableCopy(nil, 0, cfstr_imm)
        cf.CFRelease(cfstr_imm)

        if cfstr == nil then
            return nil
        end

        cf.CFStringNormalize(cfstr, kCFStringNormalizationFormC)

        local len = cf.CFStringGetLength(cfstr)
        local buf = ffi.new("char[?]", len * 4 + 1)

        local ok = cf.CFStringGetCString(
            cfstr, buf, ffi.sizeof(buf), kCFStringEncodingUTF8
        )

        cf.CFRelease(cfstr)

        if ok == 0 then
            return nil
        end

        return ffi.string(buf)
    end

elseif os == "Windows" then
    ffi.cdef[[
    int NormalizeString(
        int NormForm,
        const wchar_t *src,
        int src_len,
        wchar_t *dst,
        int dst_len
    );

    int MultiByteToWideChar(
        unsigned int CodePage,
        unsigned long dwFlags,
        const char *lpMultiByteStr,
        int cbMultiByte,
        wchar_t *lpWideCharStr,
        int cchWideChar
    );

    int WideCharToMultiByte(
        unsigned int CodePage,
        unsigned long dwFlags,
        const wchar_t *lpWideCharStr,
        int cchWideChar,
        char *lpMultiByteStr,
        int cbMultiByte,
        const char *lpDefaultChar,
        int *lpUsedDefaultChar
    );
    ]]

    local Normaliz = ffi.load("Normaliz")
    local Kernel32 = ffi.load("Kernel32")

    local NormalizationC = 1
    local CP_UTF8 = 65001

    function M.utf8_normalize(str)
        if #str == 0 then
            return ""
        end

        -- Convert UTF-8 string to UTF-16
        local wlen = Kernel32.MultiByteToWideChar(CP_UTF8, 0, str, #str, nil, 0)
        if wlen == 0 then return nil end

        local wbuf = ffi.new("wchar_t[?]", wlen)
        Kernel32.MultiByteToWideChar(CP_UTF8, 0, str, #str, wbuf, wlen)

        -- Get buffer size for normalized string
        local nlen = Normaliz.NormalizeString(NormalizationC, wbuf, wlen, nil, 0)
        if nlen <= 0 then return nil end

        local nbuf = ffi.new("wchar_t[?]", nlen)

        -- Perform normalization
        local ok = Normaliz.NormalizeString(NormalizationC, wbuf, wlen, nbuf, nlen)
        if ok <= 0 then return nil end

        -- Convert normalized UTF-16 string back to UTF-8, using the *actual* length
        local u8len = Kernel32.WideCharToMultiByte(CP_UTF8, 0, nbuf, ok, nil, 0, nil, nil)
        if u8len == 0 then return nil end

        local resbuf = ffi.new("char[?]", u8len)
        Kernel32.WideCharToMultiByte(CP_UTF8, 0, nbuf, ok, resbuf, u8len, nil, nil)

        return ffi.string(resbuf, u8len)
    end

else
    ffi.cdef[[
    typedef unsigned char utf8proc_uint8_t;
    typedef int utf8proc_ssize_t;

    utf8proc_ssize_t utf8proc_map(
        const utf8proc_uint8_t *str,
        utf8proc_ssize_t strlen,
        utf8proc_uint8_t **dstptr,
        int options
    );

    void free(void *ptr);
    ]]

    local utf8proc = ffi.load("utf8proc")

    local FLAGS = 0x00000020 + 0x00000008

    function M.utf8_normalize(str)
        local out = ffi.new("utf8proc_uint8_t*[1]")

        local rc = utf8proc.utf8proc_map(
            ffi.cast("const utf8proc_uint8_t*", str),
            #str, out, FLAGS
        )

        if rc < 0 then
            return nil, rc
        end

        local res = ffi.string(out[0], rc)
        ffi.C.free(out[0])
        return res
    end
end

return M
