import ctypes
import os

sopath = os.path.abspath(os.path.join(os.path.dirname(__file__), './MemHLS_hash.so'))
print sopath
lib = ctypes.cdll.LoadLibrary(sopath)

def str_hash(s):
    str_buf = ctypes.create_string_buffer(len(s))
    str_buf.value = s
    return lib.str_hash(str_buf, len(s))


if __name__ == '__main__':
    import sys
    print str_hash(sys.argv[1])
