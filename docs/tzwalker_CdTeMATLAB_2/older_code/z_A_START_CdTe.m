% Initialize -- close all windows, set file path, identify scan of interest

%Deletes/Closes everything that is in the workspace or open in matlab
clear
clc
close all

%File Directory
path  = 'C:\Users\Trumann\Desktop\2_Xray_Spectroscopy\fromMAPS\CdTe\combined\';

scanlist = {'398' '404' '404' '405' '439' '440' '472' '475' '517' '519'};     % these are sector 2; add sector 26 scans %must be a 3digit number
datelist = {'Dec 17' 'Dec 17' 'Dec 17' 'Dec 17' 'Dec 17' 'Dec 17' 'Dec 17' 'Dec 17'  'Dec 17' 'Dec 17'};
%Corresponding names of samples for each scan
samplename={'NREL_TS58A' 'NREL_TS58A' 'NREL_TS58A' 'NREL_TS58A' 'NREL_TS58A' 'NREL_TS58A' 'NREL_NBL3-3' 'NREL_NBL3-3' 'NREL_NBL3-1'  'NREL_NBL3-1'};
electtype= {'XBIC' 'XBIC' 'XBIC' 'XBIC' 'XBIC' 'XBIV'  'XBIV' 'XBIC' 'XBIV' 'XBIC'};

xrf.L_corr = 0.6;                   %L_line quantification correction
%xrf.M_corr = 1e9;                  %guessed value?!
xrf.spotsize = 4.07E-10^2*3.145;    %cm2 2-id-d
%xrf.spotsize = (50E-7)^2*3.1415;   %cm2 26-id-c

MW_Cd = 112.411; %g/mol
MW_Te =  127.6;  %g/mol
MW_Cu = 63.546;  %g/mol
MW_Cl = 35.453;


%%%%%%%%% START FOR LOOP THROUGH ALL SCANS HERE  %%%%%%%%
for N = 1:length(scanlist)
scan = scanlist{1, N}; 
date = datelist{1, N};
scanheader = ['scan' scanlist{1, N}];
WORK.samplename = samplename{1, N};


%FILE PATH

file  = [path 'combined_ASCII_2idd_0' scan '.h5.csv'];

WORK = importXRF(file);
sample = samplename{1, N};

[a, b, c] = CdTe_Absorb_2(sample, date);
 WORK.cd_IIO = a;
 WORK.te_IIO = b;
 WORK.cu_IIO = c;


% Cd Data 
WORK.Cd_L.map_corr = WORK.Cd_L.map/WORK.cd_IIO*xrf.L_corr; %data in ug/cm2 corrected for attenuation
WORK.Cd_L.arr_corr = WORK.Cd_L.raw/WORK.cd_IIO*xrf.L_corr; %data in ug/cm2 corrected for attenuation
WORK.Cd_L.arr_mol  = WORK.Cd_L.arr_corr/MW_Cd*1E-6; %data in mol/cm2 corrected for attenuation
WORK.Cd_L.map_mol  = WORK.Cd_L.map_corr/MW_Cd*1E-6; %data in mol/cm2 corrected for attenuation

% Te Data
WORK.Te_L.map_corr = WORK.Te_L.map/WORK.te_IIO*xrf.L_corr; %data in ug/cm2 corrected for attenuation
WORK.Te_L.arr_corr = WORK.Te_L.raw/WORK.te_IIO*xrf.L_corr;%data in ug/cm2 corrected for attenuation
WORK.Te_L.arr_mol  = WORK.Te_L.arr_corr/MW_Te*1E-6; %data in mol/cm2 corrected for attenuation
WORK.Te_L.map_mol  = WORK.Te_L.map_corr/MW_Te*1E-6; %data in mol/cm2 corrected for attenuation

% Cu Data
WORK.Cu.map_corr = WORK.Cu.map/WORK.cu_IIO; %data in ug/cm2 corrected for attenuation
WORK.Cu.arr_corr = WORK.Cu.raw/WORK.cu_IIO;%data in ug/cm2 corrected for attenuation
WORK.Cu.arr_mol  = WORK.Cu.arr_corr/MW_Cu*1E-6; %data in mol/cm2 corrected for attenuation
WORK.Cu.map_mol  = WORK.Cu.map_corr/MW_Cu*1E-6; %data in mol/cm2 corrected for attenuation

% Cl Data
WORK.Cl.map_corr = WORK.Cl.map; %data in ug/cm2 corrected for attenuation
WORK.Cl.arr_corr = WORK.Cl.raw;%data in ug/cm2 corrected for attenuation
WORK.Cl.arr_mol  = WORK.Cl.arr_corr/MW_Cl*1E-6; %data in mol/cm2 corrected for attenuation
WORK.Cl.map_mol  = WORK.Cl.map_corr/MW_Cl*1E-6; %data in mol/cm2 corrected for attenuation

%Raito Data
WORK.Cdratio.arr = WORK.Cd_L.arr_mol./(WORK.Cd_L.arr_mol+WORK.Te_L.arr_mol);
WORK.Teratio.arr = WORK.Te_L.arr_mol./(WORK.Cd_L.arr_mol+WORK.Te_L.arr_mol);
% % 
% % XBIC Data
% % WORK.XBIC_cts       = WORK.XBIC.raw; %XBIC in cts/s
% % WORK.XBIC_cts_map   = WORK.XBIC.map; %XBIC in cts/s
% % WORK.XBIC_eff       = WORK.XBIC_cts*xrf.XBIC_corr; %XBIC in coll. eff.
% % WORK.XBIC_eff_map   = WORK.XBIC_cts_map*xrf.XBIC_corr; %XBIC in coll. eff
% % WORK.XBIC_norm      =  WORK.XBIC.map./WORK.CdTe_total.map; %XBIC coll. eff. normalized for thickness
% % WORK.XBIC_norm_arr  =  WORK.XBIC_eff./WORK.thick_norm_arr;
% 
%Stepsize used for the scan (X and Y step are always equal)
stepsize = (WORK.xPosition.map(1,1) - WORK.xPosition.map(1,2)); %step size in um;
if stepsize < 0
    WORK.step= stepsize*-1;
else
    WORK.step = stepsize;
end

%SIZE of the scan in um
[a, b] = size(WORK.yPixelNo.map);
WORK.scansize = [a b] * WORK.step;

%SCAN DWELL TIME
WORK.dwell = round(min(WORK.ERT1.raw));


%Useful for plotting data
WORK.rel_X = WORK.xPixelNo.map*WORK.step*1000; %relative X coordinates in um
WORK.rel_Y = WORK.yPixelNo.map*WORK.step*1000; %relative Y coordinates in um


%Put the data back into the structure
xrf.(scanheader)   = WORK;
end

    

