#plot_output.py

import matplotlib.pyplot as plt
import numpy as np
import sys

if len(sys.argv) < 2:
    print "Usage: python plotOutput.py output_file"
    exit()

print "Plotting data from", sys.argv[1]

f = open(sys.argv[1], 'r')

first_line = True
data = []

#read in data as python lists
for line in f:
    if not (first_line):
        if not (line == "" or line == "\n"):
            line = '[' + line + ']'
            data.append(eval(line))
    else:
        first_line = False

print 'Our data matrix is', str(len(data)), 'X', str(len(data[0]))

#transpose, make into numpy arrays
new_data = []
for i in range(len(data[0])):
    tmp = []
    for j in range(len(data)):
        tmp.append(data[j][i])
    new_data.append(np.array(tmp))

plt.figure(111)

for i in new_data:
    plt.plot(range(len(i)), i)

#plt.plot(range(len(new_data[0])), new_data[0])
plt.savefig('figure1.png')
plt.clf()