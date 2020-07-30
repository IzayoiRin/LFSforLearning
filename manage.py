import sys
import os

if __name__ == '__main__':
    if os.path.dirname(__file__) not in sys.path:
        sys.path.insert(0, os.path.dirname(__file__))
    print(sys.path)