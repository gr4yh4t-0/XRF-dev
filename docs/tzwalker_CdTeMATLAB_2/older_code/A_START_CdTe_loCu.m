
clear
clc
close all

%File Directory
path  = 'C:\Users\Trumann\Desktop\NBL3_TS58A\';
scanlist = {'519'};     % these are sector 2; add sector 26 scans %must be a 3digit number
datelist = {'Dec 17'};
%Corresponding names of samples for each scan
samplename={'NREL_NBL3-1'};
electtype= {'XBIC'};

xrf.L_corr = 0.6;                   %L_line quantification correction
%xrf.M_corr = 1e9;                  %guessed value?!
xrf.spotsize = 4.07E-10^2*3.145;    %cm2 2-id-d
%xrf.spotsize = (50E-7)^2*3.1415;   %cm2 26-id-c

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

[a, b, c] = CdTe_Absorb_loCu(sample, date);
WORK.ele_IIO = [a b c];

%Enter elements to map (number of elements here should equal the number of
%elements corrected for in Absorb)
ele_line = {'Cd_L', 'Te_L', 'Cu'};

%Enter element MW (in same position)
ele_MW = [122.411 127.6 63.546];

for i = 1:length(WORK.ele_IIO)
    WORK.(ele_line{i}).map_corr = WORK.(ele_line{i}).map/ WORK.ele_IIO(i) * xrf.L_corr; %data in ug/cm2 corrected for attenuation
    WORK.(ele_line{i}).arr_corr = WORK.(ele_line{i}).raw/ WORK.ele_IIO(i) * xrf.L_corr; %data in ug/cm2 corrected for attenuation
    WORK.(ele_line{i}).map_mol = WORK.(ele_line{i}).map_corr/ ele_MW(i) * 1E-6;         %data in mol/cm2 corrected for attenuation
    WORK.(ele_line{i}).arr_mol = WORK.(ele_line{i}).arr_corr/ ele_MW(i) * 1E-6;         %data in mol/cm2 corrected for attenuation
end

%Ratio Data
WORK.Cdratio.arr = WORK.Cd_L.arr_mol./(WORK.Cd_L.arr_mol+WORK.Te_L.arr_mol);
WORK.Teratio.arr = WORK.Te_L.arr_mol./(WORK.Cd_L.arr_mol+WORK.Te_L.arr_mol);

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

    

