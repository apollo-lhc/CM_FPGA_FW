'''
Converts an input file `Link_DL_2S_1_A_04.dat` with lines of 39 bit numbers
to a Xilink Coeficient '.coe' for memory initialization
'''
import argparse

parser = argparse.ArgumentParser(description='You can select which file to process, and the number of events')
parser.add_argument('--input',   '-i', default='Link_DL_2S_1_A_04.dat',    help = 'Input file to process')
parser.add_argument('--events',  '-n', default='1',                        help = 'Number of events to write')
args = parser.parse_args()

indata = args.input
nevents = int(args.events)
outdata = indata.replace('dat', 'coe')
inlines = []
lines = []
tmp = []
with open(indata) as fin:
    inlines = fin.readlines()
count = 0
for line in inlines:
    if 'Event' in line: count = count + 1
if nevents > count:
    raise Exception('Please specify a number of events below {}!'.format(count))
lines.append('memory_initialization_radix=16;\n') # BX means new event
lines.append('memory_initialization_vector=')
nlines = 0
for line in inlines: # Read a line
    if nlines > nevents: break # Wrote as many as requested
    if 'BX' in line or line is inlines[-1]:
        nlines = nlines + 1
        if len(tmp) > 0:
            if line is inlines[-1]:
                lines.append(','.join(tmp + ['0']*(108 - len(tmp))))
            else:
                lines.append(','.join(tmp + ['0']*(108 - len(tmp)))+',' if line is not inlines[-1] else '')
            tmp = []
    else:
        tmp.append(line.split(' ')[-1].strip()[2:]) #split into columns, take last column, strip spaces, drop '0x'
if ',' in lines[-1][-1]:
    lines[-1] = lines[-1][0:-1]
lines[-1] = lines[-1] + ';'
with open(outdata, 'w') as fout:
    fout.write(''.join(lines))
