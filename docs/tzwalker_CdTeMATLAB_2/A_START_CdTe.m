clear
%clc
close all

%File Directory
path  = 'C:\Users\Trumann\Desktop\refit_NBL3\output\';
scanlist = {'439' '475' '519' '550'};               %sector 26 scans must be a 3 digit number
samplename={'TS58A' 'NBL3-3' 'NBL3-1' 'NBL3-2'};    %Corresponding names of samples for each scan
electtype= {'XBIC' 'XBIC' 'XBIC' 'XBIC'};
datelist = {'Dec 17' 'Dec 17' 'Dec 17' 'Jul 18'};

beam_energy = 8.99;                             %keV

stanford = {200, 200, 200, 5000};               %stanford setting (convert to nA/V) for each scan
lock_in = {20, 20, 20, 100};                    %lock in amplification for each scan
flux = {3.37E9 3.37E9 3.37E9 3.37E9};           %see PIN diode Excel calc
E_abs = {8091 8091 8091 8091};                  %fom online (eV)

xrf.L_corr = 0.6;                   %L_line quantification correction       -->this section is from the original code you sent for CIGS
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

[a, b, c] = CdTe_Absorb(sample, date);              
WORK.ele_IIO = [a b c];



%%%SPLIT CD_L AND TE_L CHANNELS ACCORDING TO THE LAYER THICKNESSES
%%%APPLY REPSECTIVE IIO TO EACH ONE



%Enter elements to map (number of elements here should equal the number of
%elements corrected for in Absorb)
ele_line = {'Cd_L', 'Te_L', 'Cu'};

%Enter element MW (in same position)
ele_MW = [122.411 127.6 63.546]; %Cl:35.453

for i = 1:length(WORK.ele_IIO)
    WORK.(ele_line{i}).map_corr = WORK.(ele_line{i}).map/ (1-WORK.ele_IIO(i)) * xrf.L_corr; %data in ug/cm2 corrected for attenuation
    WORK.(ele_line{i}).arr_corr = WORK.(ele_line{i}).raw/ (1-WORK.ele_IIO(i)) * xrf.L_corr; %data in ug/cm2 corrected for attenuation
    WORK.(ele_line{i}).map_mol = WORK.(ele_line{i}).map_corr/ ele_MW(i) * 1E-6;         %data in mol/cm2 corrected for attenuation
    WORK.(ele_line{i}).arr_mol = WORK.(ele_line{i}).arr_corr/ ele_MW(i) * 1E-6;         %data in mol/cm2 corrected for attenuation
end

%%% For plotting
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




%%% XBIC Correction
%Step 1: convert from counts to nanoamperes
beamconversion = 100000;                                                        %cts/ V @ Sector 2
XBIC_scale_factor = ((stanford{N} * 1E-9)  /  (beamconversion * lock_in{N}));   %generate scan electrical scale factor

WORK.XBIC_scale.raw = WORK.ds_ic.raw * XBIC_scale_factor;                       %in amps
WORK.XBIC_scale.map = WORK.ds_ic.map * XBIC_scale_factor;                       %in amps

%Step 2: divide amps by the attenuation of the absorber layer
    %cd.raw = WORK.Cd_L.raw/1E6;    %g/cm
    %te.raw = WORK.Te_L.raw/1E6;
    
    %cd.map = WORK.Cd_L.map/1E6;    %g/cm
    %te.map = WORK.Te_L.map/1E6;
    
    %muCd = 165.1;   %cm2/g
    %muTe = 198.7;   %cm2/g
    %CdTe_iio.raw = 1 - exp(-cd.raw .*muCd - te.raw .*muTe);
    %CdTe_iio.map = 1 - exp(-cd.map .*muCd - te.map .*muTe);
    
    %WORK.XBIC_scale_attn.raw = WORK.XBIC_scale.raw ./ CdTe_iio.raw;
    %WORK.XBIC_scale_attn.map = WORK.XBIC_scale.map ./ CdTe_iio.map;
    
    %%%%%extra
    %use if filter 1 in
    %filteratten = 22.71;            %filter attenuation in cm2/g for Al at 10.5 keV
    %p_Al= 2.70;                          %g/cm3
    %I_I0_filt= exp(-filteratten*filterthickness*p_Al);
    %cu = WORK.Cu.map_corr/1E6;
    %muCu_899 = 276.8;   %cm2/g
    %muCdTe = 180.0;
    %CdTe_iio = 1 - exp(-cd.*muCdTe - te.*muCdTe);
    
%Step 3: convert to e-h pairs generated when considering attenuation
eh_per_coulomb = 6.2E18;
WORK.XBIC_collected.raw = WORK.XBIC_scale.raw .* eh_per_coulomb;                %in number of e-h
WORK.XBIC_collected.map = WORK.XBIC_scale.map .* eh_per_coulomb;                %in number of e-h
    
%Step 4: calculate XBIC/C (correction factor = Eabs/alpha*Eph)
    E_g = 1.45;                         %CdTe absorber (eV)
    alpha = 3;                          %conversion efficiency for CdTe, see Fig. 6 in JMR
    C = E_abs{N} / (alpha * E_g);       %correction; energy conversion (alpha), bandgap, and energy absorbed by layer of a given thickness (Fig. 5 in JMR)
    
    
    WORK.XCE.raw = WORK.XBIC_collected.raw ./ (C * flux{N}) * 100;      %as percent
    WORK.XCE.map_corr = WORK.XBIC_collected.map ./ (C * flux{N}) * 100; %as percent
    
    WORK.XCE.raw(WORK.XCE.raw == 0) = nan;              %remove zeros from arrays (to maintain proper plotting scales)
    WORK.XCE.map_corr(WORK.XCE.map_corr == 0) = nan;    %remove zeros from arrays
    
    
    %WORK.Cu_XBIC.raw = 

%Put the data back into the structure
xrf.(scanheader) = WORK;

end

    

