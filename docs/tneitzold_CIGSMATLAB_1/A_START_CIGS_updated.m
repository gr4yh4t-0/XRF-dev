% Initialize -- close all windows, set file path, identify scan of interest

% %Deletes/Closes everything that is in the workspace or open in matlab
clear
clc
close all

%File Directory
path = 'C:\Users\Trumann\Desktop\2_xray\2_matlab\tneitzold_CIGSMATLAB_1\'
samplename='G23-16';
[scanlist,datelist,electtype, lockin,stanford,filt,flux,energy] = sample_database(samplename);

%Corresponding names of samples for each scan
% samplename1 = {'Large Miasole' 'Large Miasole' 'Large Miasole' 'Large Miasole''Large Miasole' 'Large Miasole' 'Large Miasole' 'Large Miasole' 'Large Miasole' 'Large Miasole' 'Large Miasole' 'Large Miasole' 'Large Miasole' 'Large Miasole' 'Large Miasole'};
% samplename2 = {'Small Miasole' 'Small Miasole' 'Small Miasole' 'Small Miasole' 'Small Miasole'};
% samplename3 = {'Miasole17' 'Miasole17' 'Miasole17'};
% samplename4 = {'AIST' 'AIST' 'AIST' 'AIST' 'AIST' 'AIST' 'AIST' 'AIST' 'AIST' };

xrf.L_corr = 0.6;      %L_line quantification correction
xrf.spotsize = (150E-7)^2*3.1415; %cm2 

MW_Cu = 63.54;  %g/mol
MW_In = 114.818; %g/mol
MW_Ga =  69.723;  %g/mol
MW_Se =  78.971;  %g/mol
MW_Fe = 55.845;    
MW_Cr = 51.996;
MW_Ag= 107.8682;
MW_K= 39.0983;
MW_Cd = 112.411;
MW_S = 32.065;

%%%%%%%%% START FOR LOOP THROUGH ALL SCANS HERE  %%%%%%%%
for N = 1:length(scanlist)
scan = scanlist{N}; 
rundate = datelist{N};
sample = samplename;
type=electtype{N};
scanheader = ['scan' scanlist{N}];
ampsetting=lockin(N);
currentcorr=stanford(N);
filterthickness=filt(N);
WORK.samplename = samplename;


%FILE PATH
file  = [path 'combined_ASCII_2idd_0' scan '.h5.csv'];

WORK = importXRF(file);

[a, b, c, d] = Absorb_CIGS_2(sample,rundate);
WORK.cu_IIO = a;
WORK.in_IIO = b;
WORK.ga_IIO = c;
WORK.se_IIO = d;   
WORK.ag_IIO = 1;           %needs to be added later; have Ag grading info even and can do this
WORK.k_IIO = 1;            %needs to be added later; have Ag grading info even and can do this 

%Junction data
WORK.Cd_L.arr_mol= WORK.Cd_L.raw/MW_Cd*1E-6;
WORK.S.arr_mol= WORK.S.raw/MW_S*1E-6;
WORK.CdS.arr_mol=WORK.Cd_L.arr_mol+WORK.S.arr_mol;

%Substrate Data

%Fe Data in umol/cm2
WORK.Fe.arr_mol=WORK.Fe.raw/MW_Fe*1E-6;            
WORK.Fe.map_mol=WORK.Fe.map/MW_Fe*1E-6;
%Cr Data in umol/cm2
WORK.Cr.arr_mol=WORK.Cr.raw./MW_Cr*1E-6;
WORK.Cr.map_mol=WORK.Cr.map/MW_Cr*1E-6;

%Correct Fe and Cr for thickness
WORK.sub.map_mol=WORK.Fe.map_mol+WORK.Cr.map_mol;
WORK.sub.arr_mol=WORK.Fe.arr_mol+WORK.Cr.arr_mol;

WORK.Fe.ratio.map=WORK.Fe.map_mol./WORK.sub.map_mol;     %in at%
WORK.Fe.ratio.arr=WORK.Fe.arr_mol./WORK.sub.arr_mol;

WORK.Cr.ratio.map=WORK.Cr.map_mol./WORK.sub.map_mol;
WORK.Cr.ratio.arr=WORK.Cr.arr_mol./WORK.sub.arr_mol;

WORK.FetoCr.ratio.map=WORK.Fe.map_mol./WORK.Cr.map_mol;
WORK.FetoCr.ratio.arr=WORK.Fe.arr_mol./WORK.Cr.arr_mol;


%Cu Data 
WORK.Cu.map_corr = WORK.Cu.map/WORK.cu_IIO; %data in ug/cm2 corrected for attenuation
WORK.Cu.arr_corr = WORK.Cu.raw/WORK.cu_IIO; %data in ug/cm2 corrected for attenuation
WORK.Cu.arr_mol  = WORK.Cu.arr_corr/MW_Cu*1E-6; %data in mol/cm2 corrected for attenuation
WORK.Cu.map_mol  = WORK.Cu.map_corr/MW_Cu*1E-6; %data in mol/cm2 corrected for attenuation
cu=WORK.Cu.arr_corr*1E-6; %value in g/cm2 for XBIC correction calculation

%In Data
WORK.In_L.map_corr = WORK.In_L.map/WORK.in_IIO*xrf.L_corr; %data in ug/cm2 corrected for attenuation
WORK.In_L.arr_corr = WORK.In_L.raw/WORK.in_IIO*xrf.L_corr;%data in ug/cm2 corrected for attenuation
WORK.In_L.arr_mol  = WORK.In_L.arr_corr/MW_In*1E-6; %data in mol/cm2 corrected for attenuation
WORK.In_L.map_mol  = WORK.In_L.map_corr/MW_In*1E-6; %data in mol/cm2 corrected for attenuation
in=WORK.In_L.arr_corr*1E-6; %value in g/cm2 for XBIC correction calculation

switch rundate
    case {'Dec 18 Ga', 'Jul 16'}
        %Ga Data
        WORK.Ga.map_corr = WORK.Ga.map/WORK.ga_IIO; %data in ug/cm2 corrected for attenuation
        WORK.Ga.arr_corr = WORK.Ga.raw/WORK.ga_IIO;%data in ug/cm2 corrected for attenuation
        WORK.Ga.arr_mol  = WORK.Ga.arr_corr/MW_Ga*1E-6; %data in mol/cm2 corrected for attenuation
        WORK.Ga.map_mol  = WORK.Ga.map_corr/MW_Ga*1E-6; %data in mol/cm2 corrected for attenuation
        ga=WORK.Ga.arr_corr*1E-6; %value in g/cm2 for XBIC correction calculation
        
        %CIGS Data
        WORK.CIGS_total.map_mol = WORK.Cu.map_mol + WORK.In_L.map_mol + WORK.Ga.map_mol; %+ WORK.Se.map_mol; 
        WORK.CIGS_total.arr_mol = WORK.Cu.arr_mol + WORK.In_L.arr_mol + WORK.Ga.arr_mol; %+ WORK.Se.arr_mol; 
        % WORK.thick_norm.map = WORK.CIGS_total.map/median(median(WORK.CIGS_total.map));
        % WORK.thick_norm.arr = WORK.CIGS_total.arr/median(WORK.CIGS_total.arr);

        %Ratio Data
        WORK.Curatio.map = WORK.Cu.map_mol./(WORK.CIGS_total.map_mol);
        WORK.Inratio.map = WORK.In_L.map_mol./(WORK.CIGS_total.map_mol);
        WORK.Garatio.map = WORK.Ga.map_mol./(WORK.CIGS_total.map_mol);
        
        WORK.cigs.map= WORK.Cu.map_mol + WORK.Ga.map_mol;
        WORK.Cupartialratio.map = WORK.Cu.map_mol./(WORK.Cu.map_mol + WORK.Ga.map_mol);
        WORK.Gapartialratio.map = WORK.Ga.map_mol./(WORK.Cu.map_mol + WORK.Ga.map_mol);

        WORK.Curatio.arr = WORK.Cu.arr_mol./(WORK.CIGS_total.arr_mol);
        WORK.Inratio.arr = WORK.In_L.arr_mol./(WORK.CIGS_total.arr_mol);
        
        % CGI and GGI (map)
        WORK.denom.map_mol= WORK.Ga.map_mol+WORK.In_L.map_mol;
        WORK.GGI.map = WORK.Ga.map_mol./WORK.denom.map_mol;
        WORK.CGI.map = WORK.Cu.map_mol./WORK.denom.map_mol;
        
        % CGI and GGI (raw data)
        WORK.denom.arr_mol= WORK.Ga.arr_mol+WORK.In_L.arr_mol;
        WORK.GGI.arr = WORK.Ga.arr_mol./WORK.denom.arr_mol;
        WORK.CGI.arr = WORK.Cu.arr_mol./WORK.denom.arr_mol;

    case {'Dec 18 Se'}
        %Ga Data
        WORK.Ga.map_corr = WORK.Ga.map/WORK.ga_IIO; %data in ug/cm2 corrected for attenuation
        WORK.Ga.arr_corr = WORK.Ga.raw/WORK.ga_IIO;%data in ug/cm2 corrected for attenuation
        WORK.Ga.arr_mol  = WORK.Ga.arr_corr/MW_Ga*1E-6; %data in mol/cm2 corrected for attenuation
        WORK.Ga.map_mol  = WORK.Ga.map_corr/MW_Ga*1E-6; %data in mol/cm2 corrected for attenuation
        
        %Se Data
%         WORK.Se.map_corr = WORK.Se.map/WORK.se_IIO; %data in ug/cm2 corrected for attenuation
%         WORK.Se.arr_corr = WORK.Se.raw/WORK.se_IIO;%data in ug/cm2 corrected for attenuation
%         WORK.Se.arr_mol  = WORK.Se.arr_corr/MW_Se*1E-6; %data in mol/cm2 corrected for attenuation
%         WORK.Se.map_mol  = WORK.Se.map_corr/MW_Se*1E-6; %data in mol/cm2 corrected for attenuation
        WORK.CIGS_total.map_mol = WORK.Cu.map_mol + WORK.In_L.map_mol + WORK.Ga.map_mol + WORK.Se.map_mol; 
        WORK.CIGS_total.arr_mol = WORK.Cu.arr_mol + WORK.In_L.arr_mol + WORK.Ga.arr_mol + WORK.Se.arr_mol;
        
        %Ratio Data
        WORK.Curatio.map = WORK.Cu.map_mol./(WORK.CIGS_total.map_mol);
        WORK.Inratio.map = WORK.In_L.map_mol./(WORK.CIGS_total.map_mol);
        WORK.Garatio.map = WORK.Ga.map_mol./(WORK.CIGS_total.map_mol);
        WORK.Seratio.map = WORK.Se.map_mol./(WORK.CIGS_total.map);
        
        WORK.cigs.map= WORK.Cu.map_mol + WORK.Ga.map_mol;
        WORK.Cupartialratio.map = WORK.Cu.map_mol./(WORK.Cu.map_mol + WORK.Ga.map_mol);
        WORK.Gapartialratio.map = WORK.Ga.map_mol./(WORK.Cu.map_mol + WORK.Ga.map_mol);

        WORK.Curatio.arr = WORK.Cu.arr_mol./(WORK.CIGS_total.arr_mol);
        WORK.Inratio.arr = WORK.In_L.arr_mol./(WORK.CIGS_total.arr_mol);
        
        WORK.Seratio.arr = WORK.Se.arr_mol./(WORK.CIGS_total.arr);
end

% Stepsize used for the scan (X and Y step are always equal)
stepsize = (WORK.xPosition.map(1,1) - WORK.xPosition.map(1,2)); %step size in um;
if stepsize < 0
    WORK.step= stepsize*-1;
else
    WORK.step = stepsize;
end

%SIZE of the scan in um
[a, b] = size(WORK.yPixelNo.map);
WORK.scansize = [a, b] * WORK.step;

%SCAN DWELL TIME
WORK.dwell = round(min(WORK.ERT1.raw));


%Useful for plotting data
WORK.rel_X = WORK.xPixelNo.map*WORK.step*1000; %relative X coordinates in um
WORK.rel_Y = WORK.yPixelNo.map*WORK.step*1000; %relative Y coordinates in um

 
if strcmp(type,'XBIC') == 1
    WORK.XBIC_cts.arr = WORK.ds_ic.raw; %XBIC in cts/s
    WORK.XBIC_cts.map = WORK.ds_ic.map; %XBIC in cts/s
    beamconversion = 1E5;           %cts/V so divide to get Vcts_V = 100000;     %cts/V amplifier conversion
%     filteratten = 22.71;            %filter attenuation in cm2/g for Al at 10.5 keV
%     rhoAl= 2.70;                          %g/cm3
%     I_I0_filt= exp(-filteratten*filterthickness*rhoAl);
    WORK.XBIC.arr = (WORK.XBIC_cts.arr*currentcorr)/(beamconversion*ampsetting)*1E9;   % means corrected for simple multipliers from stanford, lock-in, and channel scaler, as well as if filter attenuation was used
    WORK.XBIC.map = (WORK.XBIC_cts.map.*currentcorr)./(beamconversion*ampsetting)*1E9; %in nA
    
    q = 1.6E-19; %C/e- elemental charge
    c = 3.2; %carriers generated per incident photon based on the bandgap 
    WORK.XBIC_ECE.map = WORK.XBIC.map./(q*c*flux)*100; % represents % ECE; 1/count -- convert xbic raw to coll. eff. 
    WORK.XBIC_ECE.arr = WORK.XBIC.arr/(q*c*flux)*100;

    %run to correct XBIC array
    CIGS_I_I0=XBICcorrect(MW_Cu, MW_Ga, MW_In, MW_Se, cu,in,ga,energy);
    WORK.XBIC_corr.arr = WORK.XBIC.arr./CIGS_I_I0;
    
    %run it again to correct XBIC map
    cu=WORK.Cu.map_corr*1E-6;
    in=WORK.In_L.map_corr*1E-6;
    ga=WORK.Ga.map_corr*1E-6;
    CIGS_I_I0=XBICcorrect(MW_Cu, MW_Ga, MW_In, MW_Se, cu,in,ga,energy);
    WORK.XBIC_corr.map = WORK.XBIC.map./CIGS_I_I0;

    % WORK.XBIC_norm      =  WORK.XBIC.map./WORK.CdTe_total.map; %XBIC coll. eff. normalized for thickness
    % %WORK.XBIC_norm_arr  =  WORK.XBIC_eff./WORK.thick_norm_arr;

else
    WORK.XBIV_cts       = WORK.ds_ic.raw; %XBIC in cts/s
    WORK.XBIV_cts_map   = WORK.ds_ic.map; %XBIC in cts/s
    beamconversion = 1E5;           %cts/V so divide to get Vcts_V = 100000;     %cts/V amplifier conversion
%     filteratten = 22.71;            %filter attenuation in cm2/g for Al at 10.5 keV
%     rhoAl= 2.70;                          %g/cm3
%     I_I0_filt= exp(-filteratten*filterthickness*rhoAl);
    WORK.XBIV.arr = WORK.XBIV_cts/(beamconversion*ampsetting)*1E6;   
    WORK.XBIV.map = WORK.XBIV_cts_map./(beamconversion*ampsetting)*1E6; %in uV

    % %     ampcorrraw = (rawelect/(beamconversion*ampsettings/I_I0_filt));
% %     microelectraw = ampcorrraw;     %V
% %     ampcorrmap = (mapelect/(beamconversion*ampsettings/I_I0_filt));
% %     microelectmap = ampcorrmap;
end

%Put the data back into the structure
xrf.(scanheader)   = WORK;

end

%%
save('Scan 222 Cu molcm2','Cumol','-ascii');
save('Scan 222 Ga molcm2', 'Gamol','-ascii'); 
save('Scan 222 In molcm2','Inmol','-ascii');
save('Scan 222 Se molcm2', 'Semol','-ascii');    

%% Append Data for Statistical Analysis
% CISKFxbic=[xrf.scan350.ds_ic.raw/(10*1E5)*5E-9*1E9; xrf.scan352.ds_ic.raw/(10*1E5)*5E-9*1E9; xrf.scan353.ds_ic.raw/(10*1E5)*5E-9*1E9];
ACISKFxbic=[xrf.scan368.ds_ic.raw/(10*1E5)*5E-9*1E9; xrf.scan369.ds_ic.raw/(10*1E5)*5E-9*1E9; xrf.scan370.ds_ic.raw/(10*1E5)*5E-9*1E9];
% CISKFxbiv=[xrf.scan536.ds_ic.raw/(5E4*1E5)*1E6; xrf.scan537.ds_ic.raw/(5E4*1E5)*1E6; xrf.scan535.ds_ic.raw/(5E4*1E5)*1E6];
% ACISKFxbiv=[xrf.scan400.ds_ic.raw/(5E4*1E5)*1E6; xrf.scan401.ds_ic.raw/(5E4*1E5)*1E6; xrf.scan402.ds_ic.raw/(5E4*1E5)*1E6];
AgforXBIC=[xrf.scan368.AAC.arr; xrf.scan369.AAC.arr; xrf.scan370.AAC.arr];
% AgforXBIV=[xrf.scan400.AAC.arr; xrf.scan401.AAC.arr; xrf.scan402.AAC.arr];
