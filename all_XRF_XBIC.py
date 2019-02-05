import pandas as pd
import xraylib as xl
import numpy as np

path_to_ASCIIs = r'C:\Users\Trumann\Desktop\XRF-dev'

#enter energy in keV, stanford amplifcations in nanoamps, and elements of interest (EOI)
scan1 = {"sector": 2, 'Scan #': 439, 'Name': 'TS58A', 'beam_energy': 8.99, 'stanford': 200, 'lockin': 20, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500, "absorber_Eg": 1.45, 'E_abs': 4359, "EOI": ['Sn_L', 'S', 'Cd_L', 'Te_L', 'Cu', 'Zn_L', 'Cl', 'Mo_L']} 
scan2 = {"sector": 2, 'Scan #': 475, 'Name': 'NBL3-3', 'beam_energy': 8.99, 'stanford': 200, 'lockin': 20, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500, "absorber_Eg": 1.45, 'E_abs': 5680,  "EOI": ['Sn_L', 'S', 'Cd_L', 'Te_L', 'Cu', 'Zn_L', 'Cl', 'Mo_L']}
scan3 = {"sector": 2, 'Scan #': 519, 'Name': 'NBL3-1', 'beam_energy': 8.99, 'stanford': 200, 'lockin': 20, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500, "absorber_Eg": 1.45, 'E_abs': 4787, "EOI": ['Sn_L', 'S', 'Cd_L', 'Te_L', 'Cu', 'Zn_L', 'Cl', 'Mo_L']}
scan4 = {"sector": 2, 'Scan #': 550, 'Name': 'NBL3-2', 'beam_energy': 8.99, 'stanford': 50000, 'lockin': 100, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500, "absorber_Eg": 1.45, 'E_abs': 5907, "EOI": ['Sn_L', 'S', 'Cd_L', 'Te_L', 'Cu', 'Zn_L', 'Cl', 'Mo_L']}

           
scan_list = [scan1, scan2, scan3, scan4]

#MAPS saves column headers with whitespace, this function is used to remove that whitespace
def noColNameSpaces(pd_csv_df):
    old_colnames = pd_csv_df.columns.values
    new_colnames = []
    for name in old_colnames:
        new_colnames.append(name.strip())
    pd_csv_df.rename(columns = {i:j for i,j in zip(old_colnames,new_colnames)}, inplace=True)
    return pd_csv_df

def shrinkASCII(large_ASCII_files):
    smaller_dfs = []
    for scan in large_ASCII_files:
        if scan["sector"] == 2:
            file_name = r'\combined_ASCII_2idd_0{n}.h5.csv'.format(n = scan['Scan #'])
        else:
            file_name = r'\combined_ASCII_26idbSOFT_0{n}.h5.csv'.format(n = scan['Scan #'])
        csvIn = pd.read_csv(path_to_ASCIIs + file_name, skiprows = 1)
        noColNameSpaces(csvIn)                                          #removes whitspaces from column headers, for easy access
        shrink1 = csvIn[['x pixel no', 'y pixel no', 'ds_ic']]          #isolates x,y,and electrical columns
        shrink2 = csvIn[scan["EOI"]]                                          #isolates element of interest columns
        shrink = pd.concat([shrink1, shrink2], axis=1, sort=False)      #combines these columns into one matrix while maintaining indices
        smaller_dfs.append(shrink)                                      #add smaller matrices to list so they may be iterated over...
    return smaller_dfs

smaller_dfs = shrinkASCII(scan_list)

def generate_scalar_factor(scan_list):
    beamconversion_factor = 100000
    for scan in scan_list:
        correction = ((scan['stanford']*(1*10**-9)) / (beamconversion_factor * scan['lockin'])) #calculate correction factor for chosen scan
        key = 'scale factor'                                    #define key for scan dictionary
        scan.setdefault(key, correction)                        #add key and correction factor to scan
        #print(correction)
    return

generate_scalar_factor(scan_list)

def collect_XBIC(list_of_smaller_dfs):
    eh_per_coulomb = 1/(1.60217634*10**-19)                                  #most recent accepted value for electrons per coulomb
    for df, scan in zip(list_of_smaller_dfs, scan_list):
        df["ds_ic"] = df["ds_ic"].astype(float)                             #reformat column for floating arithmetic operations
        scaled_dsic = df.loc[:,'ds_ic'] * scan['scale factor']              #apply amplifaction settings  (converts counts to amps)
        collected_dsic = scaled_dsic * eh_per_coulomb                       #convert amps to e-h pairs
        df['ds_ic'] = collected_dsic
        df.rename(columns = {'ds_ic': 'eh_pairs'}, inplace = True)                        
    return 

collect_XBIC(smaller_dfs)

def interpolate_diode_calibration(scans):
    lower_ASU_PIN_energy = 8.08                                         #keV
    upper_ASU_PIN_energy = 12.8                                         #keV
    flux_at_8keV = 3071                                                 #ph/(s*pA) ; from 2018_07 beam run (8.08keV)
    flux_at_12keV = 2728                                                #ph/(s*pA) ; from 2018_07 beam run (12.8keV)
    for scan in scans:
        flux_of_interest = flux_at_8keV + (scan['beam_energy'] - lower_ASU_PIN_energy) * ((flux_at_12keV - flux_at_8keV)/(upper_ASU_PIN_energy-lower_ASU_PIN_energy)) #interpolate at the energy the scan was taken
        rounded_calib = round(flux_of_interest, 1)                      #keep an integer
        key = 'ph/(s*pA)'                                               #store fluxx in sample dictionary for easy retrieval
        scan.setdefault(key, rounded_calib)                             #assign key:value pair
    return 

interpolate_diode_calibration(scan_list)

def get_flux(scans):
    beamconversion = 100000     
    for scan in scans:
        PIN_current = ((scan['PIN beam_on'] - scan['PIN beam_off'])  /  beamconversion) * (scan["PIN stanford"] *10**-9)
        flux = PIN_current * scan['ph/(s*pA)'] * (1*10**12)
        rounded_flux = round(flux)
        key = 'flux'
        scan.setdefault(key, rounded_flux)
    return

get_flux(scan_list)


#wanted a function that retrieves the % energy transmitted by any given compound at the given energy
    #E_abs = 1-%transmitted
    #absorber_bandgap in scan dictionary (in case you want to parse through different materials)
    #could include ifelse statements that allow user to set energy conversion factor alpha = 3 or alpha = [refs in JMR paper]
    #need a database for compound bandgaps and compound xray transmissions as functions of thickness/density 
# =============================================================================
# def get_thickness_factor(E_abs, bandgap, alpha_Econvrsn_factor):
#     alpha = 3
#     E_abs = scan["]
#     C = E_abs / (bandgap * alpha)               
#     return C
# =============================================================================


def calc_XCE(smaller_dfs, scans):
    alpha = 3
    for df, scan in zip(smaller_dfs, scans):
        C = scan["E_abs"] / (scan['absorber_Eg'] * alpha)           #calculate correction factor, function of energy absorbed, bandgap, and energy conversion, ideally, get_thickness_factor(energy, absorber_compound, absorber_thickness, abosrber_density) would go here
        XCE = df['eh_pairs'] / (C * scan['flux']) * 100             #calculate collection efficiency
        df['eh_pairs'] = XCE                                        #replace df column for ease of use
        df.rename(columns = {'eh_pairs': 'XCE'}, inplace = True)    #rename to XCE column
    return

calc_XCE(smaller_dfs, scan_list)








# =============================================================================
# 
# 
# EOIs = ['Sn', 'S', 'Cd', 'Te', 'Cu', 'Zn', 'Cl', 'Mo']
# 
# beam_energy = 8.99                                                  #beamtime keV
# beam_theta = 90                                                     #angle of the beam relative to the surface of the sample
# beam_geometry = np.sin(beam_theta*np.pi/180)                        #convert to radians
# detect_theta = 47                                                   #angle of the detector relative to the beam
# detect_gemoetry = np.sin(detect_theta*np.pi/180)                    #convert to radians
# dt = 10 * (1*10**-3) * (1*10**-4)                                   #convert 10nm step sizes to cm: 10nm * (1um/1000nm) * (1cm/10000um)
# 
# 
# SNO2 =  {'Element':['Sn','O'],      'MolFrac':[1,2],    'Thick':0.6,    'LDensity': 6.85, 'Name': 'SnO2', 'LayerCapXSect': xl.CS_Total_CP('SnO2', beam_energy)}
# CDS =   {'Element':['Cd','S'],      'MolFrac':[1,1],    'Thick':0.08,   'LDensity': 4.82, 'Name': 'CdS', 'LayerCapXSect': xl.CS_Total_CP('CdS', beam_energy)}
# CDTE =  {'Element':['Cd','Te'],     'MolFrac':[1,1],    'Thick':5.0,    'LDensity': 5.85, 'Name': 'CdTe', 'LayerCapXSect': xl.CS_Total_CP('CdTe', beam_energy)}
# CU =    {'Element':['Cu'],          'MolFrac':[1],      'Thick':0.01,   'LDensity': 8.96, 'Name': 'Cu', 'LayerCapXSect': xl.CS_Total_CP('Cu', beam_energy)}
# ZNTE =  {'Element':['Zn','Te'],     'MolFrac':[1,1],    'Thick':0.375,  'LDensity': 6.34, 'Name': 'ZnTe', 'LayerCapXSect': xl.CS_Total_CP('ZnTe', beam_energy)}
# MO =    {'Element':['Mo'],          'MolFrac':[1],      'Thick':0.5,    'LDensity': 10.2, 'Name': 'Mo', 'LayerCapXSect': xl.CS_Total_CP('Mo', beam_energy)}
# 
# #COMBINE THE LAYERS FROM ABOVE INTO A LIST (TOP LAYER FIRST, BOTTOM LAYER LAST)
# layers = [MO, ZNTE, CU, CDTE, CDS, SNO2]
# ###
# #the following functions compress xraylib functions to make the code more readable
# def ele_dens(atomicNumber):
#     D = xl.ElementDensity(atomicNumber)
#     return D
# 
# def ele_weight(atomicNumber):
#     W = xl.AtomicWeight(atomicNumber)
#     return W
# 
# def symToNum(sym):
#     S = xl.SymbolToAtomicNumber(str(sym))
#     return S
# 
# def capXsect(element, energy):
#     C = xl.CS_Total(symToNum(element), energy)
#     return C
# ###
# 
# def XRF_line(Element,Beam_Energy):
#     Z = xl.SymbolToAtomicNumber(str(Element))       #converts element string to element atomic number
#     F = xl.LineEnergy(Z,xl.KA1_LINE)                #initialize energy of fluorescence photon as highest energy K-line transition for the element
#     if xl.EdgeEnergy(Z,xl.K_SHELL) > Beam_Energy:       #if beam energy is less than K ABSORPTION energy,
#             F = xl.LineEnergy(Z,xl.LA1_LINE)            #energy of fluorescence photon equals highest energy L-line transition for the element
#             if xl.EdgeEnergy(Z,xl.L1_SHELL) > Beam_Energy:      #if beam energy is less than L1 ABSORPTION energy, and so on...
#                     F = xl.LineEnergy(Z,xl.LB1_LINE)
#                     if xl.EdgeEnergy(Z,xl.L2_SHELL) > Beam_Energy:
#                             F = xl.LineEnergy(Z,xl.LB1_LINE)
#                             if xl.EdgeEnergy(Z,xl.L3_SHELL) > Beam_Energy:
#                                     F = xl.LineEnergy(Z,xl.LG1_LINE)
#                                     if xl.EdgeEnergy(Z,xl.M1_SHELL) > Beam_Energy:
#                                             F = xl.LineEnergy(Z,xl.MA1_LINE)
#     return F
# 
# #calculate total attenuataion w/ coherent scattering (cm2/g) at beam energy for element in layer
# def MatMu(energy, layer):
#     layer_elements = layer['Element']                           #get element list from layer                                            
#     layer_molFrac = layer['MolFrac']                            #get element molar fraction list from layer
#     layer_ele_index = range(len(layer_elements))                #initialize counter for index of element in list of elements inside the LAYER DICTIONARY
#     layer_element_mol = 0                                       #initialize amount of element in layer
#     for ele in layer_ele_index:
#         layer_element_mol += ele_weight(symToNum(layer_elements[ele])) * layer_molFrac[ele]    #
#     layer_ele_mu = 0
#     for ele in layer_ele_index:
#         layer_ele_mu += capXsect(layer_elements[ele], beam_energy) * ele_weight(symToNum(layer_elements[ele])) * layer_molFrac[ele] / layer_element_mol
#     return layer_ele_mu
# 
# def getSublayers(layer):
#     dt = 10 * (1*10**-3) * (1*10**-4)                           #convert 10nm step to cm: 10nm * (1um/1000nm) * (1cm/10000um)
#     T = layer['Thick'] * (1/10000)                              #layer thickness in cm (1cm/10000um)
#     sublayers = int(T/dt)                                       #number of 10nm sublayers in the layer
#     key = 'numSublayers'                                        #add key to layer dictionary (for convenience)
#     layer.setdefault(key, sublayers)                            #connect key to number of sublayers calculated
#     return
# 
# def absorbCorrect(layers, elements):
#     IIO_dict = {}
#     iio = 1
#     for layer in layers:
#         #print()
#         for EOI in elements:
#             if EOI in layer['Element']:
#                 getSublayers(layer)                                 
#                 integral = [None]*layer['numSublayers']
#                 path_in = np.zeros((layer['numSublayers'],1))
#                 path_out = np.zeros((layer['numSublayers'],1))
#                 for sublayer in range(layer['numSublayers']):
#                     for dx in range(sublayer+1):
#                         path_in[dx] = -layer['LDensity'] * MatMu(beam_energy,layer) * dt / beam_geometry
#                         path_out[dx] = -layer['LDensity'] * MatMu(XRF_line(EOI,beam_energy), layer) * dt / detect_gemoetry
#                     integral[sublayer] = np.exp(np.sum(path_in+path_out))
#                 iio = iio * np.sum(integral)/layer['numSublayers']
#                 iio = round(iio, 5)
#                 key = EOI + '_' + layer['Name']
#                 IIO_dict.setdefault(key, iio)
#     return IIO_dict
# 
# IIOs = absorbCorrect(layers, EOIs)
# 
# # =============================================================================
# # for df in smaller_dfs:
# #     corrected_Cu = df['Cu'] / IIOs['Cu_Cu']
# #     df["Cu"] = corrected_Cu
# #     corrected_Cd = df['Cd_L'] / IIOs['Cd_CdTe']
# #     df["Cd_L"] = corrected_Cd
# #     corrected_Te = df['Te_L'] / IIOs['Te_CdTe']
# #     df["Te_L"] = corrected_Te
# # =============================================================================
# 
# =============================================================================
