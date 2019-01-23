import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

#make sure 'r' is included to read '\' and '/' correctly
path = r'C:\Users\Trumann\Desktop\2_xray\1_MAPS_fitted\FS_cross sect csvs'  

EOI = ['Cd_L', 'Te_L', 'As', 'Cu']

scan083 = {'Scan #': '083', 'Name': 'FS1, 1/3'}
scan085 = {'Scan #': '085', 'Name': 'FS1, 2/3'}
scan087 = {'Scan #': '087', 'Name': 'FS1  3/3'}

scan_dict = [scan083, scan085, scan087]

#user-defined function preamble
def stripWhiteSpace(pd_csv_df):
    old_colnames = pd_csv_df.columns.values
    new_colnames = []
    for name in old_colnames:
        new_colnames.append(name.strip())
    pd_csv_df.rename(columns = {i:j for i,j in zip(old_colnames,new_colnames)}, inplace=True)
    return pd_csv_df

def extract_element_columns(scandict):
    fitted_elements = []
    for scan in scan_dict:
        csvIn = pd.read_csv(path + r'\combined_ASCII_2idd_0{scanNum}.h5.csv'.format(scanNum=scan['Scan #']), skiprows = 1)
        stripWhiteSpace(csvIn)
        xy = csvIn[['x pixel no', 'y pixel no']]
        elements = csvIn[EOI]
        df_simp = pd.concat([xy, elements], axis=1, sort=False)
        #for ele in EOI:
        df_simp[EOI] = df_simp[EOI].astype(float)
        #correction = absorbCorrect(ele)
        fitted_elements.append(df_simp)
    return fitted_elements

simplified_dataframes = extract_element_columns(scan_dict)

def mapShape(dataframe_list):
    plotList = []
    for df in dataframe_list:
        df = df.pivot(index = 'y pixel no', columns = 'x pixel no', values = 'Te_L')
        plotList.append(df)
    return plotList

shaped_dataframes = mapShape(simplified_dataframes)



# =============================================================================
# def plotXBIC(scans, shaped_dataframes):
#     for scan, df in zip(scans, shaped_dataframes):
#         plt.figure()
#         plt.title('XBIC for Scan' + scan['Name'])
#         ax = sns.heatmap(df, xticklabels = 50, yticklabels = 50, annot= None, vmax = 25, square = True, cbar_kws={'label': 'nA'}).invert_yaxis()
#         plt.xlabel('X (um)')
#         plt.xticks(rotation = 0)
#         plt.ylabel('Y (um)')
#         plt.yticks(rotation = 0)
#     return ax
# 
# plotXBIC(scan_dict, shaped_dataframes)
# =============================================================================
