function [fCd, fTe, fCu] = CdTe_Absorb(sample, rundate)

%select the approriate beam setup for given rundate
switch rundate
%     case 'July 13'
%         beamenergy = 10.4; %keV
%         beamtheta = 90;     %beam angle fom sample surface in degrees
%         detectortheta = 25;  %detector angle from sample surface in degrees
%     case 'Oct 13'
%         beamenergy = 12.8; %keV
%         beamtheta = 90; %beam angle fom sample surface in degrees
%         detectortheta = 25;
%     case 'Jan 14'
%         beamenergy = 12.8; %keV
%         beamtheta = 90; %beam angle fom sample surface in degrees
%         detectortheta = 21;
%     case 'May 14'
%         beamenergy = 9.0; %keV
%         beamtheta = 90; %beam angle fom sample surface in degrees
%     case 'June 14'
%         beamenergy = 10.4; %keV
%         beamtheta = 70;
%         detectortheta = 20;
%     case 'July 14'
%         beamenergy = 12.8; %keV
%         beamtheta = 70;
%         detectortheta = 20;
%     case 'Oct 14'
%         beamenergy = 10.5; %keV;
%         beamtheta = 60;
%         detectortheta = 30;
%     case 'Dec 14'
%         beamenergy = 12.8; %keV
%         beamtheta = 75;
%         detectortheta = 62;
%     case 'April 15'
%         beamenergy = 8.0; %keV
%         beamtheta = 90;
%         detectortheta = 33;
%     case 'Jan 15'
%         beamenergy = 9; %keV
%         beamtheta = 60;  
%         detectortheta = 30;
    case 'Dec 17'
        beamenergy = 8.99; %keV
        beamtheta = 90;  
        detectortheta = 47;
end


    x_ITO = 0;  %cm
    x_ZnO = 0;%cm
    x_CdTe = 5.0E-4;  %cm


%set CIGS layer increments and gradings
dt = 0.000001; %1nm thick layers
M = x_CdTe/dt;
M = round(M); %rounds to nearest integer for total number of layers
depth = 0:dt:x_CdTe; %1nm increments


%ENERGIES OF INTEREST
%S Ka1  = 2.3 keV
%Cu Ka1 = 8.0 keV
%Ga Ka1 = 9.3 keV
%Se Ka1 = 11.2 keV
%In La1 = 3.3 keV
%Sn La1 = 3.4 keV

%set layer densities
calc_p_CIGS = @(x) -0.15.*x + 5.75; %Formula to Calculate CIGS density Cu(In(1-x),Ga(x))Se2
p_ITO = 7.14;    %g/cm3
p_ZnO = 0.05;    %g/cm3
p_CdS = 4.826;   %g/cm3
p_SiN = 3.44;    %g/cm3
p_SnS = 5.22;    %g/cm3
p_CdTe = 6.2;    %g/cm3

%Set SiN info
mu_SiN_CuK = 4.19E1; %cm2/g
mu_SiN_InL = 4.97E2; %cm2/g
mu_SiN_GaK = 2.71E1; %cm2/g
mu_SiN_SeK = 1.57E1; %cm2/g

%Set ITO info
mu_ITO_CuK = 2.09E2; %cm2/g
mu_ITO_InL = 4.278E2; %cm2/g
mu_ITO_GaK = 1.442E2; %cm2/g
mu_ITO_SeK = 8.599E1; %cm2/g
mu_ITO_SK  = 9.976E2; %cm2/g
mu_ITO_SnL = 3.664E2; %cm2/g

%Set ZnO info
mu_ZnO_CuK = 4.868E1; %cm2/g
mu_ZnO_InL = 5.562E2; %cm2/g
mu_ZnO_GaK = 3.315E1; %cm2/g
mu_ZnO_SeK = 1.412E2; %cm2/g
mu_ZnO_SK  = 1.409E3; %cm2/g
mu_ZnO_SnL = 4.909E2; %cm2/g

%Set CdS info
mu_CdS_CuK = 1.933E2; %cm2/g
mu_CdS_InL = 5.713E2; %cm2/g
mu_CdS_GaK = 1.329E2; %cm2/g
mu_CdS_SeK = 7.891E1; %cm2/g

%Set CdTe info
mu_CdTe_CdL  = 5.555E2; %cm2/g
mu_CdTe_TeL  = 8.372E2; %cm2/g
mu_CdTe_CuK  = 2.454E2; %cm2/g

if     beamenergy == 8.0
    mu_ITO_Beam = 1.997E2; %cm2/g
    mu_ZnO_Beam = 4.900E1;   %cm2/g
    mu_SnS_Beam = 9.776E2; %cm2/g
elseif beamenergy == 9.0
    % NEED TO ENTER 9KEV BEAM ATTENUATION IN CIGS LAYER
    mu_ITO_Beam = 1.55E2; %cm2/g
    mu_ZnO_Beam = 3.576E1; %cm2/g
    mu_CdS_Beam = 1.431E2; %cm2/g
    mu_SiN_Beam = 2.98E1; %cm2/g
    mu_CdTe_Beam= 1.824E2; %cm2/g
elseif beamenergy == 10.4
    mu_ITO_Beam = 1.06E2; %cm2/g
    mu_ZnO_Beam = 1.71E2; %cm2/g
    mu_CdS_Beam = 9.70E1; %cm2/g
    mu_SiN_Beam = 1.95E1; %cm2/g
    calc_mu_Beam =  @(ga) 20.619.*ga + 95.876; % true within CIGS layer
elseif beamenergy == 10.5
    mu_CdTe_Beam = 1.211E2; %cm2/g
elseif beamenergy == 12.8
    mu_ITO_Beam = 6.033E1; %cm2/g
    mu_ZnO_Beam = 1.002E2; %cm2/g
    mu_CdS_Beam = 5.519E1; %cm2/g
    mu_SiN_Beam = 1.07E1;  %cm2/g
    calc_mu_Beam =  @(ga) 22.257.*ga + 116.9; %calculates beam attenuation at a given gallium ratio in the CIGS layer
elseif beamenergy == 8.99
    % NEED TO ENTER 9KEV BEAM ATTENUATION IN CIGS LAYER
    mu_ITO_Beam = 1.55E2; %cm2/g
    mu_ZnO_Beam = 3.576E1; %cm2/g
    mu_CdS_Beam = 1.431E2; %cm2/g
    mu_SiN_Beam = 2.98E1; %cm2/g
    mu_CdTe_Beam= 1.824E2; %cm2/g
else
    msgbox(['The beam energy for the run on ' rundate 'and for sample ', ...
        sample ' has not be entered yet. Please input the run information.']);
end

b1 = exp(-mu_CdTe_Beam*p_CdTe*x_CdTe/sin(beamtheta*pi/180));
b5 = b1;

%Cadmium
i_io_cd = zeros(M,1);
%s1 = exp(-mu_CdTe_CdL*p_CdTe*x_CdTe/sin(detectortheta*pi/180)); %CdTe attn
%Total S_K fluorescence attenuation including incident beam attn
%s5 = s1*b5;
for N = 1:M
    for i = 1:N
        beam_in = -p_CdTe*mu_CdTe_Beam*depth(i)/sin(beamtheta*pi/180);
        beam_out = -p_CdTe*mu_CdTe_CdL*depth(i)/sin(detectortheta*pi/180);
        i_io_cd(N) = exp(sum(beam_in+beam_out));
    end
end
fCd = sum(i_io_cd)/M;

%Tellurium 
i_io_cu = zeros(M,1);
%sn1 = exp(-mu_ITO_SnL*p_ITO*x_ITO/sin(detectortheta*pi/180)); %ITO attn
%sn2 = exp(-mu_ZnO_SnL*p_ZnO*x_ZnO/sin(detectortheta*pi/180)); %ZnO attn
%Total SnL fluorescence attenuation including incident beam attn
%sn5 = sn1*sn2*b5;

for N = 1:M
    for i = 1:N
        beam_in = -p_CdTe*mu_CdTe_Beam*depth(i)/sin(beamtheta*pi/180);
        beam_out = -p_CdTe*mu_CdTe_TeL*depth(i)/sin(detectortheta*pi/180);
        i_io_cu(N) = exp(sum(beam_in+beam_out));
    end
end
fTe = sum(i_io_cu)/M;

%Copper 
i_io_cu = zeros(M,1);
%sn1 = exp(-mu_ITO_SnL*p_ITO*x_ITO/sin(detectortheta*pi/180)); %ITO attn
%sn2 = exp(-mu_ZnO_SnL*p_ZnO*x_ZnO/sin(detectortheta*pi/180)); %ZnO attn
%Total SnL fluorescence attenuation including incident beam attn
%sn5 = sn1*sn2*b5;

for N = 1:M
    for i = 1:N
        beam_in = -p_CdTe*mu_CdTe_Beam*depth(i)/sin(beamtheta*pi/180);
        beam_out = -p_CdTe*mu_CdTe_CuK*depth(i)/sin(detectortheta*pi/180);
        i_io_cu(N) = exp(sum(beam_in+beam_out));
    end
end
fCu = sum(i_io_cu)/M;
end

