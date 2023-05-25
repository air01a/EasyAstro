import configparser
import platform 

plt = platform.system()

LINUX = 0
WINDOWS = 1
PLATFORM=-1

if plt == "Windows":   
    PLATFORM=WINDOWS
else:
    PLATFORM=LINUX

CONFIG = configparser.ConfigParser()
if PLATFORM==LINUX:
    CONFIG.read('/etc/easyastro.conf')
else:
    CONFIG.read('.\easyastro.conf')
print(PLATFORM)