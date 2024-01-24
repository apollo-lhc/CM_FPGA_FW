'''
Converts a simulation output file `TF_L1L2.txt` with lines of 5 columns, column 5 is 464 bit numbers which are in hex.
A 48 bit constant (0xADD300000000)is added to the high order bits to make a 512 bit number and 
written to the output file `TF_L1L2.coe`
'''
import argparse

parser = argparse.ArgumentParser(description='You can select which file to run over, and set the bit widths')
parser.add_argument('--input',   '-i', default='TF_L1L2.txt',    help = 'Input file to process')
parser.add_argument('--skip',    '-s', default='0',              help = 'Number of events to skip')
parser.add_argument('--events',  '-n', default='1',              help = 'Number of events to write')
args = parser.parse_args()

indata = args.input
nskip   = int(args.skip)
nevents = int(args.events)
outdata = indata.replace('txt', 'coe')
inlines = []
outlines = []
tmp = []
with open(indata) as fin:
    inlines = fin.readlines()
count = 0
for line in inlines:
    tmp.append(line.split()[2].strip())
lastbxnum = 'xx'
for bxnum in tmp[1:-1]:
    if bxnum not in lastbxnum: count = count + 1
    lastbxnum = bxnum
print('event count =', count)
if nevents > count:
    raise Exception('Please specify a number of events below {}!'.format(count))
outlines.append('memory_initialization_radix=16;\n') # BX means new event
outlines.append('memory_initialization_vector=')
tmp = []
nevt = 1
lastbxnum = inlines[1].split()[2].strip()
for line in inlines[1:]: # Read a line, skip the first
    bxnum = line.split()[2].strip()
    if bxnum not in lastbxnum:
        nevt = nevt + 1
#    print(line.split()[0]," bxnum = ",bxnum," nevt = ",nevt)
    if nevt > nskip: #Start Processing
        if bxnum not in lastbxnum:
            if nevt == nskip + nevents + 1: break # Wrote as many as requested
        outlines.append('ADD300000000'+line.split()[-1].strip()[2:]+',')
    lastbxnum = bxnum
if ',' in outlines[-1][-1]:
    outlines[-1] = outlines[-1][0:-1]
outlines[-1] = outlines[-1] + ';'
with open(outdata, 'w') as fout:
    fout.write(''.join(outlines))
