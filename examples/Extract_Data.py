#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 24 11:26:29 2022

@author: dhulls
"""

import csv
import numpy as np
import matplotlib.pyplot as plt
import json
from scipy import stats

## Import coords

path = '/Users/dhulls/projects/falcon/examples/DFN_MonteCarlo/Coords.csv'

coord1 = []
coord2 = []
coord3 = []
numR = 10

count = 0
with open(path, 'r') as file:
    reader = csv.reader(file)
    for row in reader:
        if count > 0:
            coord1.append(float(row[0]))
            coord2.append(float(row[1]))
            coord3.append(float(row[2]))
        count = count + 1

fig = plt.figure()
ax = fig.add_subplot(projection='3d')
ax.scatter(coord1,coord2,coord3)

## Import JSON outputs
file  = '/Users/dhulls/projects/falcon/examples/DFN_MonteCarlo/Main_out.json'
f = open(file,)
data = json.load(f)
N = 10
outputs = np.zeros(N)

for ii in np.arange(0,N,1):
    outputs[ii] = np.array(data["time_steps"][ii]["Jout_storage"]["Jout:Jout_Constant:Jout_values"])
kde = stats.gaussian_kde(outputs)
x = np.linspace(outputs.min(), outputs.max(), 100)
p = kde(x)

plt.hist(outputs,bins=20,density=True,label='Histogram')
plt.plot(x,p,label='Kernel density')
plt.xlabel('Energy (Joules)')
plt.ylabel('Density')
plt.legend()
