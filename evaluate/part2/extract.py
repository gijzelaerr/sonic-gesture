import sys
from numpy import *


def distance(str1, str2):
    l1 = len(str1)
    l2 = len(str2)
    d = zeros((l1, l2))
    d[:,0] = arange(0, l1)
    d[0,:] = arange(0, l2)

    for i in range(l1):
        for j in range(l2):
            cost = int(str1[i] != str2[j])
            d[i, j] = min(
                d[i-1, j  ] + 1,     # deletion
                d[i  , j-1] + 1,     # insertion
                d[i-1, j-1] + cost   # substitution
            )

            if(i > 0 and j > 0 and str1[i] == str2[j-1] and str1[i-1] == str2[j]):
                d[i, j] = min(
                    d[i, j],
                    d[i-2, j-2] + cost   #transposition
                 )
    return d[l1-1, l2-1]


if len(sys.argv) != 2:
    print("usage: extract.py <framelabelfile>")
    sys.exit()

labelfile = sys.argv[1]

fh = open(labelfile, 'r')


classified = []
previous = '-1'
for line in fh.readlines():
    try:
        frame, label = line.split()
    except ValueError:
        break
    if label != previous and label != '-1':
        previous = label
        classified.append(previous)


groundtruth = [str(x) for x in range(0, 28)]

name =  labelfile.split('.')[0].split('/')[1]
print name, distance(classified, groundtruth)

