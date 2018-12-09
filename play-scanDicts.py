# -*- coding: utf-8 -*-
"""
Created on Thu Aug  2 09:41:22 2018

@author: Trumann
"""

SCANdict = {'398': ['name1','Dec17','XBIC'], '408': ['name2', 'Dec17','XBIV']}

scans = SCANdict.keys()
scaninfo = SCANdict.values()
scandictuple = SCANdict.items()

if 'XBIC' in scaninfo:
  print('true')
else:
  print('false')
  #perform XBIV correction

    


  

  