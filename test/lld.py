"""
Calculates the great circle distance between two points.

Usage: python lld.py lat1 lon1 lat2 lon2
"""

import subprocess, sys
from decimal import Decimal
from pyproj import Geod

if (len(sys.argv) != 5):
    raise Exception("Usage: python lld.py lat1 lon1 lat2 lon2")

def scaleInput(x):
    return x / (10 ** 18)

lat1 = scaleInput(Decimal(sys.argv[1]))
lon1 = scaleInput(Decimal(sys.argv[2]))
lat2 = scaleInput(Decimal(sys.argv[3]))
lon2 = scaleInput(Decimal(sys.argv[4]))

# following the example pyproj put on this page
# https://pyproj4.github.io/pyproj/stable/api/geod.html
g = Geod(ellps='clrk66')
_, _, dist = g.inv(lon1, lat1, lon2, lat2)

# Convert back to an integer scaled by 1e18, then ABI encode the result
y = int(dist * 10 ** 18)
subprocess.run(["cast", "abi-encode", "f(int256)", str(y)])
