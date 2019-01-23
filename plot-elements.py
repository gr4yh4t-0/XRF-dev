#DO NOT USE THIS CODE UNLESS YOU KNOW WHAT YOUR DOING, still need to work out the kinks in plot title generation...

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

#make sure 'r' is included to read '\' and '/' correctly
path = r'C:\Users\Trumann\Desktop\2_xray\1_MAPS_fitted\FS_cross sect csvs'  

EOI = ['Cd_L', 'Te_L', 'Cu', 'As', 'Se', 'Zn']
EOInames = ['Cd', 'Te', 'Cu', 'As', 'Se', 'Zn']

scan083 = {'Scan #': '083', 'Name': 'First Solar Scan 1'}
scan085 = {'Scan #': '085', 'Name': 'First Solar Scan 2'}
scan087 = {'Scan #': '087', 'Name': 'First Solar Scan 3'}

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
        csvIn = pd.read_csv(path + r'/combined_ASCII_2idd_0{scanNum}.h5.csv'.format(scanNum=scan['Scan #']), skiprows = 1)
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

def mapShape(dataframe_as_array):
    plotList = []
    for df in dataframe_as_array:
        for ele in EOI:
            df1 = df.pivot(index = 'y pixel no', columns = 'x pixel no', values = ele)
            plotList.append(df1)
    return plotList

shaped_dataframes = mapShape(simplified_dataframes)

def plotEle(shaped_dataframes):
    scanNum = [1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3]
    strList = []
    elements = EOInames + EOInames + EOInames
    for num in scanNum:
        strList.append(str(num))
    for df, num, ele in zip(shaped_dataframes, strList, elements):
        fig = plt.figure(figsize = (3,4))
        plt.title(ele + ' for FS Scan ' + num)
        ax = sns.heatmap(df, xticklabels = 50, yticklabels = 50, annot= None, square = True, cbar_kws={'label': 'ug/cm^2'}).invert_yaxis()
        plt.xlabel('X (um/20)')
        plt.xticks(rotation = 0)
        plt.ylabel('Y (um/20)')
        plt.yticks(rotation = 0)
        fig.get_figure()
        fig.savefig(r"C:\Users\Trumann\Desktop\2_xray\plots\{e} plot {num}.png".format(e = ele, num = num))
        #ax.savefig(r"C:\Users\Trumann\Desktop\2_xray\plots\{e} plot {num}.png".format(e = ele, num = num))
    return ax

plotEle(shaped_dataframes)

def Cd_vs_Te(scans, element_dfs):
    for scan, df in zip(scans, element_dfs):
        fig = plt.figure()
        plt.scatter(df['Cd_L'], df['Te_L'])
        #df.plot(x='Cd_L', y='Te_L', style='x')
        plt.title('Cd vs. Te Concentration for ' + scan['Name'])
        plt.xlabel('Cd (ug/cm^2)')
        plt.ylabel('Te (ug/cm^2)')
    return fig

#Cd_vs_Te(scan_dict, simplified_dataframes)
# =============================================================================
# def getMapSection(shaped_dataframes):
#     for df in shaped_dataframes:
#         sectionList = []
#         y_section = df.loc[50:76]
#         sectionList.append(y_section)
#         #plotList = []
#         #for ele in EOI:
#         #shaped_section = y_section.pivot(index = 'y pixel no', columns = 'x pixel no', values = 'Cd_L')
#             #plotList.append(shaped_section)
#     return sectionList #plotList
# 
# section = getMapSection(shaped_dataframes) #.pivot(index = 'y pixel no', columns = 'x pixel no', values = 'Cd_L')
# #shaped_section = section.pivot(index = 'x pixel no', columns = 'y pixel no', values = 'Cd_L')
# 
# print(section)
# =============================================================================
