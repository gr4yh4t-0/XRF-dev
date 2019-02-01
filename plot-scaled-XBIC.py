import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

#user-defined functions
def stripWhiteSpace(pd_csv_df):
    old_colnames = pd_csv_df.columns.values
    new_colnames = []
    for name in old_colnames:
        new_colnames.append(name.strip())
    pd_csv_df.rename(columns = {i:j for i,j in zip(old_colnames,new_colnames)}, inplace=True)
    return pd_csv_df

def correctXBIC(scandict):
    arrays_corrXBIC = []
    for scan in scan_dict:
        csvIn = pd.read_csv(path + r'\combined_ASCII_2idd_0{scanNum}.h5.csv'.format(scanNum=scan['Scan #']), skiprows = 1)
        stripWhiteSpace(csvIn)
        df_simp = csvIn[['x pixel no', 'y pixel no', 'ds_ic']]
        df_simp["ds_ic"] = df_simp["ds_ic"].astype(float)
        correction = ((scan['stanford']*(1*10**-9)) / (beamconv * scan['lockin'])) * (1*10**9)
        correct_dsic = df_simp.loc[:,'ds_ic'] * correction  # 'access dataframe ds_ic column, multiply all values in column by correction'   
        df_simp['ds_ic'] = correct_dsic #'rewrite dc_ic column in df_simp'
      #list_for_corrXBICcols.append(correct_dsic)
        arrays_corrXBIC.append(df_simp)
    return arrays_corrXBIC

def mapShape(dataframe_list):
    plotList = []
    for df in dataframe_list:
        df = df.pivot(index = 'y pixel no', columns = 'x pixel no', values = 'ds_ic')
        plotList.append(df)
    return plotList

def plotXBIC(scans, shaped_dataframes):
    for scan, df in zip(scans, shaped_dataframes):
        plt.figure()
        plt.title(scan['Name'])
        ax = sns.heatmap(df, xticklabels = 50, yticklabels = 50, annot= None, vmax = 25, square = True, cbar_kws={'label': 'nA'}).invert_yaxis()
        plt.xlabel('X (um/20)')
        plt.xticks(rotation = 0)
        plt.ylabel('Y (um/20)')
        plt.yticks(rotation = 0)
    return ax


#make sure 'r' is included to read '\' and '/' correctly
path = r'C:\Users\Trumann\Desktop\XRF-dev'  

#scalar conversion at Sector 2, beamline constant (unless otherwise stated)
beamconv = 1*10**5          

#define scan and corrosponding electrical hardware settings, Name key will define the title of plot
scan1 = {'Scan #': '083', 'Name': 'FS Scan 1', 'stanford': 200, 'lockin': 50}
scan2 = {'Scan #': '085', 'Name': 'FS Scan 2', 'stanford': 500, 'lockin': 100}
scan3 = {'Scan #': '087', 'Name': 'FS Scan 3', 'stanford': 500, 'lockin': 100}

#enter scan dictionary into list
scan_dict = [scan083, scan085, scan087]

simplified_dataframes = correctXBIC(scan_dict)
shaped_dataframes = mapShape(simplified_dataframes)
plotXBIC(scan_dict, shaped_dataframes)