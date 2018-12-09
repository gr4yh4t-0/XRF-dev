import xraylib 
import numpy as np

def Density(layerdict):
    Material = layerdict['Name']
    if Material == 'SnO2':
            return 6.85 #g/cm3
    elif Material == 'CdS':
            return 4.82 #g/cm3
    elif Material == 'CdTe':
            return 5.85 #g/cm3
    elif Material == 'Cu':
            return 8.96 #g/cm3 
    elif Material == 'ZnTe':
            return 6.34 #g/cm3
    if Material == 'Mo':
            return 10.2 #g/cm3

def GetMaterialMu(E, data):
    Ele = data['Element']
    Mol = data['MolFrac']
    t = 0
    for i in range(len(Ele)):
            t += xraylib.AtomicWeight(xraylib.SymbolToAtomicNumber(Ele[i]))*Mol[i]
    mu=0
    for i in range(len(Ele)):
            mu+= (xraylib.CS_Total(xraylib.SymbolToAtomicNumber(Ele[i]),E) * 
                        xraylib.AtomicWeight(xraylib.SymbolToAtomicNumber(Ele[i]))*Mol[i]/t)
    return mu 

def GetFluorescenceEnergy(Element,Beam):
    Z = xraylib.SymbolToAtomicNumber(Element)
    F = xraylib.LineEnergy(Z,xraylib.KA1_LINE)
    if xraylib.EdgeEnergy(Z,xraylib.K_SHELL) > Beam:
            F = xraylib.LineEnergy(Z,xraylib.LA1_LINE)
            if xraylib.EdgeEnergy(Z,xraylib.L1_SHELL) > Beam:
                    F = xraylib.LineEnergy(Z,xraylib.LB1_LINE)
                    if xraylib.EdgeEnergy(Z,xraylib.L2_SHELL) > Beam:
                            F = xraylib.LineEnergy(Z,xraylib.LB1_LINE)
                            if xraylib.EdgeEnergy(Z,xraylib.L3_SHELL) > Beam:
                                    F = xraylib.LineEnergy(Z,xraylib.LG1_LINE)
                                    if xraylib.EdgeEnergy(Z,xraylib.M1_SHELL) > Beam:
                                            F = xraylib.LineEnergy(Z,xraylib.MA1_LINE)
    return F

SNO2 = {'Element':['Sn','O'],'MolFrac':[1,2],'Thick':0.6,'Name':'SnO2'}
CDS = {'Element':['Cd','S'],'MolFrac':[1,1],'Thick':0.08,'Name':'CdS'}
CDTE = {'Element':['Cd','Te'],'MolFrac':[1,1],'Thick':5.0,'Name':'CdTe'}
CU = {'Element':['Cu'],'MolFrac':[1],'Thick':0.01,'Name':'Cu'}
ZNTE = {'Element':['Zn','TE'],'MolFrac':[1,1],'Thick':0.375,'Name':'ZnTe'}
MO = {'Element':['Mo'],'MolFrac':[1],'Thick':0.5,'Name':'Mo'}

STACK = [MO, ZNTE, CU, CDTE, CDS, SNO2]
Beam_Theta = 90 #degrees
Detector_Theta = 47 #degrees
Beam_Energy = 12.7 #keV

EOI = 'Cd'
iio = 1
um_to_cm = 10**-4
for layer1 in STACK:
    if EOI in layer1['Element']:
        t = layer1['Thick']*um_to_cm
        dt = 0.01*um_to_cm
        steps = int(t/dt);
        first_integral = [None]*steps
        path_in = np.zeros((steps,1))
        path_out = np.zeros((steps,1))
        for N in range(steps):
            for idx in range(N+1):
                path_in[idx] = -Density(layer1)*GetMaterialMu(Beam_Energy,layer1)*dt/np.sin(Beam_Theta*np.pi/180)
                path_out[idx] = -Density(layer1)*GetMaterialMu(GetFluorescenceEnergy(EOI,Beam_Energy),layer1)*dt/np.sin(Detector_Theta*np.pi/180)
            first_integral[N] = np.exp(np.sum(path_in+path_out))
        iio = iio*np.sum(first_integral)/steps
        break
    else:
        t = layer1['Thick']*um_to_cm
        path_in =  -Density(layer1) * GetMaterialMu(Beam_Energy,layer1) * t/np.sin(Beam_Theta*np.pi/180)
        path_out = -Density(layer1) * GetMaterialMu(GetFluorescenceEnergy(EOI,Beam_Energy),layer1) * t/np.sin(Detector_Theta*np.pi/180)
        iio = iio*np.exp(path_in + path_out) 
            
print(iio)