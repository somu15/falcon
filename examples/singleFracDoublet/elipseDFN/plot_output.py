#!/usr/bin/env python3
#* This file is part of the MOOSE framework
#* https://www.mooseframework.org
#*
#* All rights reserved, see COPYRIGHT for full restrictions
#* https://github.com/idaholab/moose/blob/master/COPYRIGHT
#*
#* Licensed under LGPL 2.1, please see LICENSE for details
#* https://www.gnu.org/licenses/lgpl-2.1.html
import pandas as pd
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import math

#-------------------------------------------------------------------------------
df = pd.read_csv('matFrac_2fluid_out.csv')
print('fracture dataframe description: ',df.columns.values)
# time
# kg_per_s
# var_out/mfHot_out:massFracCold[0]
# var_out/mfHot_out:massFracHot[0]
# var_out/mfCold_test:massFracCold[0]
# var_out/mfCold_test:massFracHot[0]

Tmin_limit=df.at[0,'inject_T']
Tmax_limit=df.loc[:,'var_out/T_out:frac_T[0]'].max()
time_max_limit=df.loc[:,'time'].max()/3600/24
print('tmax=',Tmax_limit,'   tmin=',Tmin_limit)
#-------------------------------------------------------------------------------
fig1=plt.figure()
plt.plot(df['time'],df['var_out/tracer_out:tracer[0]'],'*b',label='tracer')
# plt.ylim([50, 100])
# plt.xlim([0, 10])
plt.ylabel("tracer mass fraction")
plt.xlabel("Time")
plt.grid()
plt.legend()

fig2=plt.figure()
plt.plot(df['time'],df['var_out/T_out:frac_T[0]'],'*r',label='Tout')
plt.ylim([Tmin_limit,Tmax_limit ])
# plt.xlim([0, 5e6])
plt.ylabel("T out")
plt.xlabel("Time")
plt.grid()
plt.legend()





#-------------------------------------------------------------------------------

fig3 = plt.figure(figsize=(7, 4))
ax3 = fig3.add_subplot(1,1,1)
ax3.title.set_text('Production Temperature and Mass Fraction')

color = 'tab:red'
ax3.plot(df['time']/3600/24,df['var_out/tracer_out:tracer[0]'],marker='o', linestyle='dashed',color=color)
ax3.set_ylabel('Tracer Mass Fraction',color=color)
ax3.set_xlabel('time (days)')
ax3.tick_params(axis='y',labelcolor=color)
ax3.set_xlim([0,time_max_limit])

ax33=ax3.twinx()
color='tab:blue'
ax33.set_ylabel('Production Temperature',color=color)
ax33.plot(df['time']/3600/24,df['var_out/T_out:frac_T[0]'],marker='o', linestyle='dashed',color=color)
ax33.tick_params(axis='y',labelcolor=color)
ax33.set_ylim([340,370])

#-------------------------------------------------------------------------------q

plt.show()
