import shutil
import os

local_path = r'C:\Users\Trumann\Desktop'
network_path = r'\\en4093310.ecee.dhcp.asu.edu\BertoniLab\Group and admin\Personal folders\Trumann'

local_names = [r'\1_stage design', r'\2_xray', r'\3_python', r'\4_presentation', r'\5_reporting', r'\6_travel', r'\Literature']

local_paths = []
network_paths = []

def makePaths(local_names):
    for folder_name in local_names:
        local_path_string = local_path + folder_name
        net_path_string = network_path + folder_name
        local_paths.append(local_path_string)
        network_paths.append(net_path_string)

makePaths(local_names)

for path in zip(local_paths, network_paths):
    if os.path.exists(path[1]):
        shutil.rmtree(path[1])
    else:
        shutil.copytree(path[0], path[1])

