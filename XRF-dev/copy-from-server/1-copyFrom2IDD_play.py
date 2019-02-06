import shutil

#enter scans you want and corrosponding points in the scan IN SAME ORDER
scans = ['586','620','626']
points = [601,601,601,601]

def copyFrom2IDD():
    mda_src_path = input("Paste full mda network path here: ")
    mda_dst_path = input("Paste mda destination path here: ")
    h5_src_path = input("Paste full H5 network path: ")
    h5_dst_path = input("Paste H5 destination path here: ")
# =============================================================================
#     fly_src_path = input("Paste full flyXRF network path here: ")
#     fly_sdst_path = input("Paste flyXRF destination path here: ")
# =============================================================================
    for scan in scans:
        mdaFilename = r"\2idd_0" +scan + ".mda"
        h5Filename = r"\2idd_0" + scan + ".h5"
        shutil.copy(mda_src_path + mdaFilename, mda_dst_path)
        shutil.copy(h5_src_path + h5Filename, h5_dst_path)
# =============================================================================
#     for scan, point in zip(scans, points):  
#       for p in range(point):
#         findfly = r"\2idd_0{a}_2iddXMAP__{b}.nc".format(a=scan, b=p)
#         shutil.copy(fly_src_path + findfly, fly_sdst_path)
# 
# =============================================================================
copyFrom2IDD()