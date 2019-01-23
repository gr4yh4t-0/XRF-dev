import pandas as pd
import numpy as np

scans = [397]
elements = ['Cd_L', 'Te_L', 'Cu']
#stack info defined here


def stripWhiteSpace(pd_csv_df):
    old_colnames = pd_csv_df.columns.values
    new_colnames = []
    for name in old_colnames:
        new_colnames.append(name.strip())
    pd_csv_df.rename(columns = {i:j for i,j in zip(old_colnames,new_colnames)}, inplace=True)
    return pd_csv_df

def absorbCorrect(dataframe):
    #take stack info
    #calculate iio
    #apply iio to all values of element selected
    return corrected_dataframe


#absorbCorrect(scanList, elements) #---> returns a ASCII file with corrected fluorescence values for the channels in [elements]
for scan in scans:
    csvIn = pd.read_csv(r'/home/kineticcross/Desktop/XRF-dev/combined_ASCII_2idd_0{scanNum}.h5.csv'.format(scanNum=str(scan)), skiprows = 1)
    stripWhiteSpace(csvIn)
    EOI_df = csvIn[elements]
    print(EOI_df)
    #XBIC_position_df = csvIn[['x pixel no', 'y pixel no', 'ds_ic']]
    absorbCorrect(EOI_df)
    