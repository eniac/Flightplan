#!/usr/local/bin/python
# Nik Sultana, UPenn, August 2019

from dateutil.parser import parse
import matplotlib.pyplot as plt
import re
from scipy.ndimage.filters import gaussian_filter1d
import sys

device = ""
x = []
y = []
prev_measure = None

for line in sys.stdin:
  decomposed = line.split('):')
  time_and_device = decomposed[0]
  measure = decomposed[1].strip()
  if (measure == "timeout"):
    #measure = float(-1) # FIXME const
    measure = prev_measure
  elif (measure.startswith("could not find IP address")):
    #measure = float(-2) # FIXME const
    measure = prev_measure
  else:
    measure = int(float(measure))

  m = re.match("^(.+\+..:..) ([^ ]+) ", time_and_device)
  if m:
    time = parse(m.group(1))
    device = m.group(2)
    #print time
    #print device
    #print measure
    if (measure > 6000): # FIXME const
      measure = prev_measure
    x.append(time)
    y.append(measure)
    prev_measure = measure
  else:
    print "Could not parse:"
    print line
    sys.exit(1)

f = plt.figure()
ysmoothed = gaussian_filter1d(y, sigma=2)
plt.plot(x,ysmoothed)
#plt.show()
f.savefig("graph.pdf", bbox_inches='tight')
print "Done for " + device
