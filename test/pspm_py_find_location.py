import os
import sys
path = os.path.dirname(sys.executable)
version = ".".join(map(str, sys.version_info[0:2]))
lines = [path, version]
with open('test/py_loc.txt', 'w') as f:
  for line in lines:
    f.write(line)
    f.write('\n')