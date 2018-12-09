import pandas as pd
import numpy as np

scans = [397]

def stripWhiteSpace(pd_csv_df):
    old_colnames = pd_csv_df.columns.values
    new_colnames = []
    for name in old_colnames:
        new_colnames.append(name.strip())
    pd_csv_df.rename(columns = {i:j for i,j in zip(old_colnames,new_colnames)}, inplace=True)
    return pd_csv_df

def XBIC_correct(dataframe):
    lock_in = int(input('Enter Lock In Scale: '))
    stanford = int(input('Enter Stanford Setting (nA/V): '))
    correction = something,something
    dataframe.multiply(correction)
    return

for scan in scans:
    csvIn = pd.read_csv(r'/home/kineticcross/Desktop/XRF-dev/combined_ASCII_2idd_0{scanNum}.h5.csv'.format(scanNum=str(scan)), skiprows = 1)
    stripWhiteSpace(csvIn)
    XBIC_df = csvIn['ds_ic']
    XBIC_correct(XBIC_df)
    print(XBIC_df)
    