import os
import sys
text = os.path.dirname(sys.executable)
with open('py_loc.txt', 'w') as f:
  f.write(text)