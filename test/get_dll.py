# This script is for Windows only.
import sys
from os.path import join, exists

dll_path = join(sys.exec_prefix, f"python{sys.version_info.major}{sys.version_info.minor}.dll")
if exists(dll_path):
    print(dll_path)
else:
    print("DLL not found at expected location:", dll_path)
