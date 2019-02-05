<<<<<<< HEAD
import pandas as pd
import xraylib as xl
import numpy as np

path_to_ASCIIs = r'/home/kineticcross/Desktop/XRF-dev'
EOI = ['Sn_L', 'S', 'Cd_L', 'Te_L', 'Cu', 'Zn_L', 'Cl', 'Mo_L']

scan1 = {'Scan #': 439, 'Name': 'TS58A', 'beam_energy': 8.99, 'stanford': 200, 'lockin': 20, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500} 
scan2 = {'Scan #': 475, 'Name': 'NBL3-3', 'beam_energy': 8.99, 'stanford': 200, 'lockin': 20, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500}
scan3 = {'Scan #': 519, 'Name': 'NBL3-1', 'beam_energy': 8.99, 'stanford': 200, 'lockin': 20, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500}
scan4 = {'Scan #': 550, 'Name': 'NBL3-2', 'beam_energy': 8.99, 'stanford': 50000, 'lockin': 100, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500}

           
scan_list = [scan1, scan2, scan3, scan4]

#MAPS saves column headers with whitespace, this function is used to remove that whitespace
def noColNameSpaces(pd_csv_df):
    old_colnames = pd_csv_df.columns.values
    new_colnames = []
    for name in old_colnames:
        new_colnames.append(name.strip())
    pd_csv_df.rename(columns = {i:j for i,j in zip(old_colnames,new_colnames)}, inplace=True)
    return pd_csv_df

def import_small_ASCII(large_ASCII_files):
    smaller_dfs = []
    for scan in large_ASCII_files:
        csvIn = pd.read_csv(path_to_ASCIIs + r'/combined_ASCII_2idd_0{n}.h5.csv'.format(n = scan['Scan #']), skiprows = 1)
        noColNameSpaces(csvIn)                                          #removes whitspaces from column headers, for easy access
        shrink1 = csvIn[['x pixel no', 'y pixel no', 'ds_ic']]          #isolates x,y,and electrical columns
        shrink2 = csvIn[EOI]                                            #isolates element of interest columns
        shrink = pd.concat([shrink1, shrink2], axis=1, sort=False)      #combines these columns into one matrix while maintaining indices
        smaller_dfs.append(shrink)                                      #add smaller matrices to list so they may be iterated over...
    return smaller_dfs

ASCII_dfs = import_small_ASCII(scan_list)                                    #list containing smaller datframes (considering memory purposes)

EOIs = ['Sn', 'S', 'Cd', 'Te', 'Cu', 'Zn', 'Cl', 'Mo']

beam_energy = 8.99                                                  #beamtime keV
beam_theta = 90                                                     #angle of the beam relative to the surface of the sample
beam_geometry = np.sin(beam_theta*np.pi/180)                        #convert to radians
detect_theta = 47                                                   #angle of the detector relative to the beam
detect_gemoetry = np.sin(detect_theta*np.pi/180)                    #convert to radians
dt = 10 * (1*10**-3) * (1*10**-4)                                   #convert 10nm step sizes to cm: 10nm * (1um/1000nm) * (1cm/10000um)

#enter lengths in cm
SNO2 =  {'Element':['Sn','O'],      'MolFrac':[1,2],    'Thick':0.00006,    'LDensity': 6.85, 'Name': 'SnO2',   'capXsect': xl.CS_Total_CP('SnO2', beam_energy)}
CDS =   {'Element':['Cd','S'],      'MolFrac':[1,1],    'Thick':0.000008,   'LDensity': 4.82, 'Name': 'CdS',    'capXsect': xl.CS_Total_CP('CdS', beam_energy)}
CDTE =  {'Element':['Cd','Te'],     'MolFrac':[1,1],    'Thick':0.0005,    'LDensity': 5.85, 'Name': 'CdTe',   'capXsect': xl.CS_Total_CP('CdTe', beam_energy)}
CU =    {'Element':['Cu'],          'MolFrac':[1],      'Thick':0.000001,   'LDensity': 8.96, 'Name': 'Cu',     'capXsect': xl.CS_Total_CP('Cu', beam_energy)}
ZNTE =  {'Element':['Zn','Te'],     'MolFrac':[1,1],    'Thick':0.0000375,  'LDensity': 6.34, 'Name': 'ZnTe',   'capXsect': xl.CS_Total_CP('ZnTe', beam_energy)}
MO =    {'Element':['Mo'],          'MolFrac':[1],      'Thick':0.00005,    'LDensity': 10.2, 'Name': 'Mo',     'capXsect': xl.CS_Total_CP('Mo', beam_energy)}

#COMBINE THE LAYERS FROM ABOVE INTO A LIST (UPTREAM LAYER FIRST, DOWNSTREAM LAYER LAST)
STACK = [MO, ZNTE, CU, CDTE, CDS, SNO2]


###let's try the absorber first... Cd, Te, Cu

#attenuation of beam intensity through each layer
    #done. check test file


###
#the following functions compress xraylib functions to make the code more readable
def ele_dens(atomicNumber):
    D = xl.ElementDensity(atomicNumber)
    return D

def ele_weight(atomicNumber):
    W = xl.AtomicWeight(atomicNumber)
    return W

def symToNum(sym):
    S = xl.SymbolToAtomicNumber(str(sym))
    return S

def capXsect(element, energy):
    C = xl.CS_Total(symToNum(element), energy)
    return C
###

def XRF_line(Element,Beam_Energy):
    Z = xl.SymbolToAtomicNumber(str(Element))       #converts element string to element atomic number
    F = xl.LineEnergy(Z,xl.KA1_LINE)                #initialize energy of fluorescence photon as highest energy K-line transition for the element
    if xl.EdgeEnergy(Z,xl.K_SHELL) > Beam_Energy:       #if beam energy is less than K ABSORPTION energy,
            F = xl.LineEnergy(Z,xl.LA1_LINE)            #energy of fluorescence photon equals highest energy L-line transition for the element
            if xl.EdgeEnergy(Z,xl.L1_SHELL) > Beam_Energy:      #if beam energy is less than L1 ABSORPTION energy, and so on...
                    F = xl.LineEnergy(Z,xl.LB1_LINE)
                    if xl.EdgeEnergy(Z,xl.L2_SHELL) > Beam_Energy:
                            F = xl.LineEnergy(Z,xl.LB1_LINE)
                            if xl.EdgeEnergy(Z,xl.L3_SHELL) > Beam_Energy:
                                    F = xl.LineEnergy(Z,xl.LG1_LINE)
                                    if xl.EdgeEnergy(Z,xl.M1_SHELL) > Beam_Energy:
                                            F = xl.LineEnergy(Z,xl.MA1_LINE)
    return F

#calculate total attenuataion w/ coherent scattering (cm2/g) at beam energy for element in layer
def MatMu(energy, layer):
    layer_elements = layer['Element']                           #get element list from layer                                            
    layer_molFrac = layer['MolFrac']                            #get element molar fraction list from layer
    layer_ele_index = range(len(layer_elements))                #initialize counter for index of element in list of elements inside the LAYER DICTIONARY
    layer_element_mol = 0                                       #initialize amount of element in layer
    for ele in layer_ele_index:
        layer_element_mol += ele_weight(symToNum(layer_elements[ele])) * layer_molFrac[ele]    #
    layer_ele_mu = 0
    for ele in layer_ele_index:
        layer_ele_mu += capXsect(layer_elements[ele], beam_energy) * ele_weight(symToNum(layer_elements[ele])) * layer_molFrac[ele] / layer_element_mol
    return layer_ele_mu

def getSublayers(layer):
    dt = 10 * (1*10**-3) * (1*10**-4)                           #convert 10nm step to cm: 10nm * (1um/1000nm) * (1cm/10000um)
    T = layer['Thick']                                          #layer thickness in cm
    sublayers = T/dt                                            #number of 10nm sublayers in the layer
    sublayers = round(sublayers)
    sublayers = int(sublayers)
    key = 'numSublayers'                                        #add key to layer dictionary (for convenience)
    layer.setdefault(key, sublayers)                            #connect key to number of sublayers calculated
    return sublayers


#attenuation of beam intensity through each layer
Bo_previous = 1
for layer in STACK:
    Bo = Bo_previous * np.exp(- layer['capXsect'] * layer['LDensity'] * layer['Thick']) #cm2/g * g/cm3 * cm
    rounded_Bo = round(Bo, 7)
    Bo_previous = Bo
    #begin correction internal to each layer
    sublayers = getSublayers(layer)
    path_in = np.zeros(layer['numSublayers'])
    path_out = np.zeros(layer['numSublayers'])
    for sublayer in range(sublayers):
        path_in[sublayer] = -layer['LDensity'] * layer['capXsect'] * dt / beam_geometry
        path_out[sublayer] = -layer['LDensity'] * layer['capXsect'] * dt / detect_gemoetry        
    #print(path_in, path_out)



def absorbCorrect(layers, elements):
    IIO_dict = {}
    iio = 1
    for layer in layers:
        #print()
        for EOI in elements:
            if EOI in layer['Element']:
                getSublayers(layer)                                 
                integral = [None]*layer['numSublayers']
                path_in = np.zeros((layer['numSublayers'],1))
                path_out = np.zeros((layer['numSublayers'],1))
                for sublayer in range(layer['numSublayers']):
                    for dx in range(sublayer+1):
                        path_in[dx] = -layer['LDensity'] * MatMu(beam_energy,layer) * dt / beam_geometry
                        path_out[dx] = -layer['LDensity'] * MatMu(XRF_line(EOI,beam_energy), layer) * dt / detect_gemoetry
                    integral[sublayer] = np.exp(np.sum(path_in+path_out))
                iio = iio * np.sum(integral)/layer['numSublayers']
                iio = round(iio, 5)
                key = EOI + '_' + layer['Name']
                IIO_dict.setdefault(key, iio)
    return IIO_dict

IIOs = absorbCorrect(layers, EOIs)

# =============================================================================
# for df in smaller_dfs:
#     corrected_Cu = df['Cu'] / IIOs['Cu_Cu']
#     df["Cu"] = corrected_Cu
#     corrected_Cd = df['Cd_L'] / IIOs['Cd_CdTe']
#     df["Cd_L"] = corrected_Cd
#     corrected_Te = df['Te_L'] / IIOs['Te_CdTe']
#     df["Te_L"] = corrected_Te
# =============================================================================


=======
import pandas as pd
import xraylib as xl
import numpy as np

path_to_ASCIIs = r'/home/kineticcross/Desktop/XRF-dev'
EOI = ['Sn_L', 'S', 'Cd_L', 'Te_L', 'Cu', 'Zn_L', 'Cl', 'Mo_L']

scan1 = {'Scan #': 439, 'Name': 'TS58A', 'beam_energy': 8.99, 'stanford': 200, 'lockin': 20, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500} 
scan2 = {'Scan #': 475, 'Name': 'NBL3-3', 'beam_energy': 8.99, 'stanford': 200, 'lockin': 20, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500}
scan3 = {'Scan #': 519, 'Name': 'NBL3-1', 'beam_energy': 8.99, 'stanford': 200, 'lockin': 20, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500}
scan4 = {'Scan #': 550, 'Name': 'NBL3-2', 'beam_energy': 8.99, 'stanford': 50000, 'lockin': 100, 'PIN beam_on': 225100, 'PIN beam_off': 624, 'PIN stanford': 500}

           
scan_list = [scan1, scan2, scan3, scan4]

#MAPS saves column headers with whitespace, this function is used to remove that whitespace
def noColNameSpaces(pd_csv_df):
    old_colnames = pd_csv_df.columns.values
    new_colnames = []
    for name in old_colnames:
        new_colnames.append(name.strip())
    pd_csv_df.rename(columns = {i:j for i,j in zip(old_colnames,new_colnames)}, inplace=True)
    return pd_csv_df

def import_small_ASCII(large_ASCII_files):
    smaller_dfs = []
    for scan in large_ASCII_files:
        csvIn = pd.read_csv(path_to_ASCIIs + r'/combined_ASCII_2idd_0{n}.h5.csv'.format(n = scan['Scan #']), skiprows = 1)
        noColNameSpaces(csvIn)                                          #removes whitspaces from column headers, for easy access
        shrink1 = csvIn[['x pixel no', 'y pixel no', 'ds_ic']]          #isolates x,y,and electrical columns
        shrink2 = csvIn[EOI]                                            #isolates element of interest columns
        shrink = pd.concat([shrink1, shrink2], axis=1, sort=False)      #combines these columns into one matrix while maintaining indices
        smaller_dfs.append(shrink)                                      #add smaller matrices to list so they may be iterated over...
    return smaller_dfs

ASCII_dfs = import_small_ASCII(scan_list)                                    #list containing smaller datframes (considering memory purposes)

EOIs = ['Sn', 'S', 'Cd', 'Te', 'Cu', 'Zn', 'Cl', 'Mo']

beam_energy = 8.99                                                  #beamtime keV
beam_theta = 90                                                     #angle of the beam relative to the surface of the sample
beam_geometry = np.sin(beam_theta*np.pi/180)                        #convert to radians
detect_theta = 47                                                   #angle of the detector relative to the beam
detect_gemoetry = np.sin(detect_theta*np.pi/180)                    #convert to radians
dt = 10 * (1*10**-3) * (1*10**-4)                                   #convert 10nm step sizes to cm: 10nm * (1um/1000nm) * (1cm/10000um)

#enter lengths in cm
SNO2 =  {'Element':['Sn','O'],      'MolFrac':[1,2],    'Thick':0.00006,    'LDensity': 6.85, 'Name': 'SnO2',   'capXsect': xl.CS_Total_CP('SnO2', beam_energy)}
CDS =   {'Element':['Cd','S'],      'MolFrac':[1,1],    'Thick':0.000008,   'LDensity': 4.82, 'Name': 'CdS',    'capXsect': xl.CS_Total_CP('CdS', beam_energy)}
CDTE =  {'Element':['Cd','Te'],     'MolFrac':[1,1],    'Thick':0.0005,    'LDensity': 5.85, 'Name': 'CdTe',   'capXsect': xl.CS_Total_CP('CdTe', beam_energy)}
CU =    {'Element':['Cu'],          'MolFrac':[1],      'Thick':0.000001,   'LDensity': 8.96, 'Name': 'Cu',     'capXsect': xl.CS_Total_CP('Cu', beam_energy)}
ZNTE =  {'Element':['Zn','Te'],     'MolFrac':[1,1],    'Thick':0.0000375,  'LDensity': 6.34, 'Name': 'ZnTe',   'capXsect': xl.CS_Total_CP('ZnTe', beam_energy)}
MO =    {'Element':['Mo'],          'MolFrac':[1],      'Thick':0.00005,    'LDensity': 10.2, 'Name': 'Mo',     'capXsect': xl.CS_Total_CP('Mo', beam_energy)}

#COMBINE THE LAYERS FROM ABOVE INTO A LIST (UPTREAM LAYER FIRST, DOWNSTREAM LAYER LAST)
STACK = [MO, ZNTE, CU, CDTE, CDS, SNO2]


###let's try the absorber first... Cd, Te, Cu

#attenuation of beam intensity through each layer
    #done. check test file


###
#the following functions compress xraylib functions to make the code more readable
def ele_dens(atomicNumber):
    D = xl.ElementDensity(atomicNumber)
    return D

def ele_weight(atomicNumber):
    W = xl.AtomicWeight(atomicNumber)
    return W

def symToNum(sym):
    S = xl.SymbolToAtomicNumber(str(sym))
    return S

def capXsect(element, energy):
    C = xl.CS_Total(symToNum(element), energy)
    return C
###

def XRF_line(Element,Beam_Energy):
    Z = xl.SymbolToAtomicNumber(str(Element))       #converts element string to element atomic number
    F = xl.LineEnergy(Z,xl.KA1_LINE)                #initialize energy of fluorescence photon as highest energy K-line transition for the element
    if xl.EdgeEnergy(Z,xl.K_SHELL) > Beam_Energy:       #if beam energy is less than K ABSORPTION energy,
            F = xl.LineEnergy(Z,xl.LA1_LINE)            #energy of fluorescence photon equals highest energy L-line transition for the element
            if xl.EdgeEnergy(Z,xl.L1_SHELL) > Beam_Energy:      #if beam energy is less than L1 ABSORPTION energy, and so on...
                    F = xl.LineEnergy(Z,xl.LB1_LINE)
                    if xl.EdgeEnergy(Z,xl.L2_SHELL) > Beam_Energy:
                            F = xl.LineEnergy(Z,xl.LB1_LINE)
                            if xl.EdgeEnergy(Z,xl.L3_SHELL) > Beam_Energy:
                                    F = xl.LineEnergy(Z,xl.LG1_LINE)
                                    if xl.EdgeEnergy(Z,xl.M1_SHELL) > Beam_Energy:
                                            F = xl.LineEnergy(Z,xl.MA1_LINE)
    return F

#calculate total attenuataion w/ coherent scattering (cm2/g) at beam energy for element in layer
def MatMu(energy, layer):
    layer_elements = layer['Element']                           #get element list from layer                                            
    layer_molFrac = layer['MolFrac']                            #get element molar fraction list from layer
    layer_ele_index = range(len(layer_elements))                #initialize counter for index of element in list of elements inside the LAYER DICTIONARY
    layer_element_mol = 0                                       #initialize amount of element in layer
    for ele in layer_ele_index:
        layer_element_mol += ele_weight(symToNum(layer_elements[ele])) * layer_molFrac[ele]    #
    layer_ele_mu = 0
    for ele in layer_ele_index:
        layer_ele_mu += capXsect(layer_elements[ele], beam_energy) * ele_weight(symToNum(layer_elements[ele])) * layer_molFrac[ele] / layer_element_mol
    return layer_ele_mu

def getSublayers(layer):
    dt = 10 * (1*10**-3) * (1*10**-4)                           #convert 10nm step to cm: 10nm * (1um/1000nm) * (1cm/10000um)
    T = layer['Thick']                                          #layer thickness in cm
    sublayers = T/dt                                            #number of 10nm sublayers in the layer
    sublayers = round(sublayers)
    sublayers = int(sublayers)
    key = 'numSublayers'                                        #add key to layer dictionary (for convenience)
    layer.setdefault(key, sublayers)                            #connect key to number of sublayers calculated
    return sublayers


#attenuation of beam intensity through each layer
Bo_previous = 1
for layer in STACK:
    Bo = Bo_previous * np.exp(- layer['capXsect'] * layer['LDensity'] * layer['Thick']) #cm2/g * g/cm3 * cm
    rounded_Bo = round(Bo, 7)
    Bo_previous = Bo
    #begin correction internal to each layer
    sublayers = getSublayers(layer)
    path_in = np.zeros(layer['numSublayers'])
    path_out = np.zeros(layer['numSublayers'])
    for sublayer in range(sublayers):
        path_in[sublayer] = -layer['LDensity'] * layer['capXsect'] * dt / beam_geometry
        path_out[sublayer] = -layer['LDensity'] * layer['capXsect'] * dt / detect_gemoetry        
    #print(path_in, path_out)



def absorbCorrect(layers, elements):
    IIO_dict = {}
    iio = 1
    for layer in layers:
        #print()
        for EOI in elements:
            if EOI in layer['Element']:
                getSublayers(layer)                                 
                integral = [None]*layer['numSublayers']
                path_in = np.zeros((layer['numSublayers'],1))
                path_out = np.zeros((layer['numSublayers'],1))
                for sublayer in range(layer['numSublayers']):
                    for dx in range(sublayer+1):
                        path_in[dx] = -layer['LDensity'] * MatMu(beam_energy,layer) * dt / beam_geometry
                        path_out[dx] = -layer['LDensity'] * MatMu(XRF_line(EOI,beam_energy), layer) * dt / detect_gemoetry
                    integral[sublayer] = np.exp(np.sum(path_in+path_out))
                iio = iio * np.sum(integral)/layer['numSublayers']
                iio = round(iio, 5)
                key = EOI + '_' + layer['Name']
                IIO_dict.setdefault(key, iio)
    return IIO_dict

IIOs = absorbCorrect(layers, EOIs)

# =============================================================================
# for df in smaller_dfs:
#     corrected_Cu = df['Cu'] / IIOs['Cu_Cu']
#     df["Cu"] = corrected_Cu
#     corrected_Cd = df['Cd_L'] / IIOs['Cd_CdTe']
#     df["Cd_L"] = corrected_Cd
#     corrected_Te = df['Te_L'] / IIOs['Te_CdTe']
#     df["Te_L"] = corrected_Te
# =============================================================================


>>>>>>> 7e880ffb21cb0ffb93e928b48251607c2da08c77
