import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm

#make sure 'r' is included to read '\' and '/' correctly
path = r'C:\Users\Trumann\Desktop\2_xray'  

#scalar conversion at Sector 2, beamline constant (unless otherwise stated)
beamconv = 1*10**5          

#define scans and electrical settings for each scan
scan083 = {'Name': '083', 'stanford': 200, 'lockin': 50}
#scan085 = {'Name': '085', 'stanford': 500, 'lockin': 100}
#scan087 = {'Name': '087', 'stanford': 500, 'lockin': 100}

scan_dict = [scan083, scan085, scan087]

EOI = ['Cd_L', 'Te_L', 'As', 'Cu']


#user-defined function preamble
def stripWhiteSpace(pd_csv_df):
    old_colnames = pd_csv_df.columns.values
    new_colnames = []
    for name in old_colnames:
        new_colnames.append(name.strip())
    pd_csv_df.rename(columns = {i:j for i,j in zip(old_colnames,new_colnames)}, inplace=True)
    return pd_csv_df

#list containing dataframes of columns of interest: x, y, corrected XBIC, and elements of interest


def correctXBIC(scandict):
    arrays_corrXBIC = []
    for scan in scan_dict:
        csvIn = pd.read_csv(path + r'\combined_ASCII_2idd_0{scanNum}.h5.csv'.format(scanNum=scan['Name']), skiprows = 1)
        stripWhiteSpace(csvIn)
        df_simp1 = csvIn[['x pixel no', 'y pixel no', 'ds_ic']]
        df_simp2 = csvIn[EOI]
        df_simp = pd.concat([df_simp1, df_simp2], axis=1, sort=False)
        df_simp["ds_ic"] = df_simp["ds_ic"].astype(float)
        correction = ((scan['stanford']*(1*10**-9)) / (beamconv * scan['lockin'])) * (1*10**9)
        correct_dsic = df_simp.loc[:,'ds_ic'] * correction  # 'access dataframe ds_ic column, multiply all values in column by correction'   
        df_simp['ds_ic'] = correct_dsic #'rewrite dc_ic column in df_simp'
      #list_for_corrXBICcols.append(correct_dsic)
        arrays_corrXBIC.append(df_simp)
    return arrays_corrXBIC

simplified_dataframes = correctXBIC(scan_dict)


def mapShape(dataframe_list):
    plotList = []
    for df in dataframe_list:
        df = df.pivot(index = 'y pixel no', columns = 'x pixel no', values = 'ds_ic')
        plotList.append(df)
    return plotList

shaped_dataframes = mapShape(simplified_dataframes)

import seaborn as sns

def plotXBIC(scans, shaped_dataframes):
    for scan, df in zip(scans, shaped_dataframes):
        plt.figure()
        plt.title('XBIC for Scan' + scan['Name'])
        ax = sns.heatmap(df, xticklabels = 50, yticklabels = 50, annot= None, vmax = 25, square = True, cbar_kws={'label': 'nA'}).invert_yaxis()
        plt.xlabel('X (um)')
        plt.xticks(rotation = 0)
        plt.ylabel('Y (um)')
        plt.yticks(rotation = 0)
    return ax

plotXBIC(scan_dict, shaped_dataframes)

########################################
    # Miscellaneous Notes, previous 'work'




# =============================================================================
# def plotXBIC(scan, corrected_df_list):
# 
#         plot_list.append(reshape)
#         
#         
#         plt.xlabel('X position (um)')
#         plt.ylabel('Y position (um)')
#         
#     return 
# 
# for scan in scan_dict:
#     
#     plotXBIC(scan, list_for_df_simp_w_corrXBICcols)
# =============================================================================
# =============================================================================
#     nrows, ncols = 601, 201
#     grid = XBIC.reshape((nrows, ncols))
#     plt.imshow(grid, extent=(x.min(), x.max(), y.max(), y.min()), interpolation='nearest', cmap=cm.gist_rainbow)
#     plt.show()
# =============================================================================
    
    
    
#XBIC_df = {'x' : csvIn[['x pixel no']], 'y': csvIn[['y pixel no']], 'XBIC' : csvIn[['ds_ic']]}



#d = df[[p, p.team, p.passing_att, p.passer_rating()]] for p in game.players.passing()


    #correction = []
    #for point in XBIC_df:
      #correction = point * (scan['stanford'] / (beamconv * scan['lockin']))
    #print(XBIC_df)


#print(type(XBIC_df[2]))
#XBIV scan091_electsettings = {'stanford': 0???, 'lockin': 50}