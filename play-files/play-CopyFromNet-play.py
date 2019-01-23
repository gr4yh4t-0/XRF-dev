# -*- coding: utf-8 -*-
"""
Created on Mon Jul 30 09:18:57 2018

@author: Trumann

This script imports the raw mda, H5, and flyXRF APS Sector 2 data
from a network server directory to a local directory. 

  Make sure read/write permissions are enabled for network and local directories.
  
  Network directories must have full network path, not the 'mapped' drive 
  letter Windows or the native OS assigns to the network drive; 
  e.g. \\server\server
    
Note: When entering scans and points, match indices of scan number in "scans" 
with number of points "points" list; i.e. for a given scan, enter corrosponding
 number of points"""

import shutil

#directories and local folder name (should not already exist)
network_path = r'\\en4093310.ecee.dhcp.asu.edu\BertoniLab\Lab\Synchrotron Data'
network_folders = [r'\mda', r'\img.dat', r'\flyXRF']
local_path = r'C:\Users\Trumann\Desktop'
local_folder_name = r'\test folder'

#enter run = "<year>_<month>_<sector ID>" ; example of sector ID: "2IDD"
run = r'\2018_07_2IDD'

#enter scans you want and corrosponding points in the scan IN SAME ORDER
scans = ['083','085','087','091']
points = [601,601,601,601]

src_paths = []
dest_paths = []
def makePathStrings():
    for fldr in network_folders:
        src_string = network_path + run + fldr
        src_paths.append(src_string)
        dest_string = local_path + local_folder_name + fldr
        dest_paths.append(dest_string)
        for scan in scans:
            findMDA = r"\2idd_0" + scan + ".mda"
            findH5 = r"\2idd_0" + scan + ".h5"

makePathStrings()


    print(network_folders.index(scan) + findMDA, network_folders.index(scan) + findMDA)
    #shutil.copyfile(src_paths[scan] + findMDA, dest_paths[scan] + findMDA)
    #shutil.copyfile(src_paths[scan] + findH5, dest_paths[scan] + findH5)

# =============================================================================
# for scan, point in zip(scans, points):
#     for p in range(point):
#         findfly = r"\2idd_0{a}_2iddXMAP__{b}.nc".format(a=scan, b=p)
#         shutil.copyfile(flysource + findfly, flydest + findfly)
# =============================================================================
