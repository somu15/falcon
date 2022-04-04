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
from scipy.stats import uniform
from scipy.stats import norm

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

## Import time series from CSV (Monte Carlo)

Out1 = np.zeros(887)
for ii in np.arange(0,100,1):
    if ii < 10:
        path = '/Users/dhulls/projects/falcon/examples/DFN_Complex_MC/Main_Box_MC_out_sub0'+str(ii)+'.csv'
    else:
        path = '/Users/dhulls/projects/falcon/examples/DFN_Complex_MC/Main_Box_MC_out_sub'+str(ii)+'.csv'
    Time = []
    Out = []
    count = 0
    with open(path, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            if count > 0:
                Time.append(float(row[0]))
                Out.append(float(row[20]))
            count = count + 1
    Out1 = Out1 + np.array(Out)
    plt.plot(np.array(Time)/(60*60*24), np.array(Out), color = 'tab:blue', linewidth = 1.0)
plt.plot(np.array(Time)/(60*60*24), Out1/100, color = 'tab:red', linewidth = 3.0)
plt.xlabel('Time (Days)')
plt.ylabel('Tracer output')

## Import coordinates from JSON (Monte Carlo)

nodex = []
nodey = []
nodez = []
out = []
for ii in np.arange(0,20,1):
    if ii < 10:
        file  = '/Users/dhulls/projects/falcon/examples/DFN_Complex_MC/Main_Box_MC_out_0'+str(ii)+'.json'
    else:
        file  = '/Users/dhulls/projects/falcon/examples/DFN_Complex_MC/Main_Box_MC_out_'+str(ii)+'.json'
    f = open(file,)
    data = json.load(f)
    tmp = np.array(data["time_steps"][0]['Node_x']['Node_x:prod_node:node_x']).reshape(5)
    nodex = np.concatenate((nodex, tmp))
    tmp = np.array(data["time_steps"][0]['Node_y']['Node_y:prod_node:node_y']).reshape(5)
    nodey = np.concatenate((nodey, tmp))
    tmp = np.array(data["time_steps"][0]['Node_z']['Node_z:prod_node:node_z']).reshape(5)
    nodez = np.concatenate((nodez, tmp))
    tmp = np.array(data["time_steps"][0]['Tracerout_storage']['Tracerout:tracer_out:tracer']).reshape(5)
    out = np.concatenate((out, tmp))
    
data_req = np.zeros((100,4))
data_req[:,0] = nodex
data_req[:,1] = nodey
data_req[:,2] = nodez
data_req[:,3] = out

np.savetxt("/Users/dhulls/Desktop/data_req.csv", data_req, delimiter=",")

## Import coordinates from JSON (Sequential Monte Carlo)

N = 1000
nodex = np.zeros(N)
nodey = np.zeros(N)
nodez = np.zeros(N)
file  = '/Users/dhulls/projects/falcon/examples/DFN_Complex_MC/Main_Sphere_MC_out.json'
f = open(file,)
data = json.load(f)
for ii in np.arange(0,N,1):
    nodex[ii] = np.array(data["time_steps"][ii]['Node_x']['Node_x:prod_node:node_x']).reshape(1)
    nodey[ii] = np.array(data["time_steps"][ii]['Node_y']['Node_y:prod_node:node_y']).reshape(1)
    nodez[ii] = np.array(data["time_steps"][ii]['Node_z']['Node_z:prod_node:node_z']).reshape(1)

data_req = np.zeros((N,3))
data_req[:,0] = nodex
data_req[:,1] = nodey
data_req[:,2] = nodez

np.savetxt("/Users/dhulls/Desktop/data_req.csv", data_req, delimiter=",")

## Sampling within a sphere

M = 1000
R = 200
coords = np.zeros((M, 3))
for ii in np.arange(0, M, 1):
    r = 1e8
    while r > R:
        X1 = uniform(-R, 2*R).rvs(1)
        X2 = uniform(-R, 2*R).rvs(1)
        X3 = uniform(-R, 2*R).rvs(1)
        r = np.sqrt(X1**2 + X2**2 + X3**2)
    coords[ii,0] = X1
    coords[ii,1] = X2
    coords[ii,2] = X3
    
fig = plt.figure()
ax = fig.add_subplot(projection='3d')
ax.scatter(coords[:,0]-300.0,coords[:,1],coords[:,2]-300.0)
