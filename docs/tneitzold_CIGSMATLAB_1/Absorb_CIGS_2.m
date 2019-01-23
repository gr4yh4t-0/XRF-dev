function [fCu, fIn, fGa, fSe] = Absorb_CIGS_2(sample, rundate)
tstart = tic;
% Updated to include SiN window
% 4/3/15 - corrected calculation: now summing in exponential rather than 
%for all angles 0 degrees is sample surface

%select the approriate beam setup for given rundate
switch rundate
  case 'Jul 16'
        beamenergy = 10.5; %keV
        beamtheta = 90;
        detectortheta = 47;   
    case 'Feb 18l'      % for high energy scans
        beamenergy=9.0; %8.7 -- fit temporarily to 9 for simplicity
        beamtheta=90;
        detectortheta = 43;   
    case 'Feb 18h'      % for low energy scans
        beamenergy=12.8;
        beamtheta=90;
        detectortheta = 43;      
end


%When testing temperature stage we use a SiNx window
if strcmp(rundate, 'Dec 14') == 1
    x_SiN = 0.5E-4; % thickness of silicon nitride window ~ 500 nm
else
    x_SiN = 0;
end


%Set layer thickness for a given sample -- NREL and UDEL samples differ
switch sample
    
    case 'Small Miasole'
        x_ITO = 0;
        x_ZnO = 0.2E-4; % layer thickness in cm ... ~200nm
        x_CdS = 0.04E-4; %layer thickness in cm ... ~50nm  
        x_CIGS = 2.0E-4; %currently an estimation
        x_Mo = 0.1E-4; %currently a guess
        x_Ti= 0.12E-4; 
        x_SS= 2.0E-4; %also currently a guess
    case 'Large Miasole'
        x_ITO = 0;
        x_ZnO = 0.2E-4; % layer thickness in cm ... ~200nm
        x_CdS = 0.04E-4; %layer thickness in cm ... ~50nm    
        x_CIGS= 2.0E-4; %currently an estimation
        x_Mo = 0.1E-4; %currently a guess
        x_Ti = 0.12E-4; 
        x_SS = 2.0E-4;
    otherwise %most delaware samples
        x_ITO = 0.15E-4; %cm
        x_ZnO = 0.05E-4; %cm
        x_CdS = 0.05E-4; %cm
        x_Mo = 0; %currently a guess
        x_Ti= 0; 
        x_SS= 0; 
end



%Determine if it is a full device or film --- needs improvement
if strcmp(rundate,'Dec 14') && strcmp(sample,'Sample 4') == 1
    x_ITO = 0;
    x_ZnO = 0;
    x_CdS = 0;
end

%Determine Sample Grading and thickness from function below
%Returns a structure sampleinfo.thick and sampleinfo.grading
%grading is a function of x (layerdepth) and t(angle of the beam)
sampleinfo = getgrading(sample);
x_CIGS = sampleinfo.thick(1);


%set CIGS layer increments and gradings
dt = 0.000001; %1nm thick layers
M = x_CIGS/dt;
M = round(M); %rounds to nearest integer for total number of layers
depth = 0:dt:x_CIGS; %1nm increments
sam_grad = sampleinfo.profile(depth);


%ENERGIES OF INTEREST
%Cu Ka1 = 8.0 keV
%Ga Ka1 = 9.3 keV
%Se Ka1 = 11.2 keV
%In La1 = 3.3 keV

%set layer densities
calc_p_CIGS = @(x) -0.15.*x + 5.75; %Formula to Calculate CIGS density Cu(In(1-x),Ga(x))Se2
p_ITO = 7.14;    %g/cm3
p_ZnO = 5.6;    %g/cm3
p_CdS = 4.826;   %g/cm3
p_CIGS = calc_p_CIGS(sam_grad);
p_SiN = 3.44;    %g/cm3
p_Mo = 10.2; 
p_Ti = 4.506;
p_SS = 7.8;       %taken from asm.matweb.com   

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

%Set ZnO info
mu_ZnO_CuK = 4.868E1; %cm2/g
mu_ZnO_InL = 5.562E2; %cm2/g
mu_ZnO_GaK = 3.315E1; %cm2/g
mu_ZnO_SeK = 1.412E2; %cm2/g

%Set CdS info
mu_CdS_CuK = 1.933E2; %cm2/g
mu_CdS_InL = 5.713E2; %cm2/g
mu_CdS_GaK = 1.329E2; %cm2/g
mu_CdS_SeK = 7.891E1; %cm2/g

%Set CIGS info
calc_mu_In = @(ga) 90.183.*ga + 679.77; % true within CIGS layer
calc_mu_Cu = @(ga) -58.285.*ga + 128.67; % true within CIGS layer
calc_mu_Ga = @(ga) -33.868.*ga + 130.77; % true within CIGS layer
calc_mu_Se = @(ga)  17.324.*ga + 78.468;

% %Set Ti info
% mu_ZnO_TiK =
% mu_CdS_TiK =
% mu_CIGS_TiK =
% 
% %Set Mo info
% mu_ZnO_MoL =
% mu_CdS_MoL =
% mu_CIGS_MoL =
% mu_TiK_MoL = 
% 
% %Set SS info
% mu_ZnO_FeK = 
% mu_ZnO_CrK = 
% mu_CdS_FeK = 
% mu_CdS_CrK = 
% mu_CIGS_FeK = 
% mu_CIGS_CrK = 
% mu_TiK_FeK = 
% mu_TiK_CrK = 
% mu_MoL_FeK = 
% mu_MoL_CrK = 

if beamenergy == 9.0
    % NEED TO ENTER 9KEV BEAM ATTENUATION IN CIGS LAYER
    mu_ITO_Beam = 1.55E2; %cm2/g
    mu_ZnO_Beam = 3.576E1; %cm2/g
    mu_CdS_Beam = 1.431E2; %cm2/g
    mu_SiN_Beam = 2.98E1; %cm2/g
    mu_Ti_Beam = 0;
    mu_Mo_Beam = 0;
    mu_SS_Beam = 0;
    calc_mu_Beam =  @(ga) 20.619.*ga + 95.876; % NOT FOR 9keV; taken from 10.5
elseif beamenergy == 10.5 %find calculations on pg 124(? of my notebook?)
    mu_ITO_Beam = 1.03E2; %cm2/g (used In2O3)
    mu_ZnO_Beam = 1.76E2; %cm2/g 
    mu_CdS_Beam = 1.007E2; %cm2/g
    mu_SiN_Beam = 0; %cm2/g
    mu_Ti_Beam = 1.02349E2;
    mu_Mo_Beam = 8.605E1;
    mu_SS_Beam = 132.976; %using 89.31% Fe and 17% Cr and remaining values from Miasole
    calc_mu_Beam =  @(ga) 20.619.*ga + 95.876; % true within CIGS layer
elseif beamenergy == 10.8
    mu_ITO_Beam = 8.96E1; %cm2/g
    mu_ZnO_Beam = 1.56E2; %cm2/g
    mu_CdS_Beam = 8.75E1; %cm2/g
    mu_SiN_Beam = 1.75E1; %cm2/g
    calc_mu_Beam =  @(ga) 18.9.*ga + 86.857; % true within CIGS layer
elseif beamenergy == 12.8
    mu_ITO_Beam = 6.033E1; %cm2/g
    mu_ZnO_Beam = 1.002E2; %cm2/g
    mu_CdS_Beam = 5.519E1; %cm2/g
    mu_SiN_Beam = 1.07E1;  %cm2/g
    calc_mu_Beam =  @(ga) 22.257.*ga + 116.9; %calculates beam attenuation at a given gallium ratio in the CIGS layer
    mu_Ti_Beam = 0;
    mu_Mo_Beam = 0;
    mu_SS_Beam = 0;
else
    msgbox(['The beam energy for the run on ' rundate 'and for sample ', ...
        sample ' has not be entered yet. Please input the run information.']);
end

mu_CIGS_beam = calc_mu_Beam(sam_grad);
b1 = exp(-mu_ITO_Beam*p_ITO*x_ITO/sin(beamtheta*pi/180));
b2 = exp(-mu_ZnO_Beam*p_ZnO*x_ZnO/sin(beamtheta*pi/180));
b3 = exp(-mu_CdS_Beam*p_CdS*x_CdS/sin(beamtheta*pi/180));
b4 = exp(-mu_SiN_Beam*p_SiN*x_SiN/sin(beamtheta*pi/180));
b5 = b1*b2*b3*b4;

b6 = exp(-mu_Ti_Beam*p_Ti*x_Ti/sin(beamtheta*pi/180));
b7 = exp(-mu_Mo_Beam*p_Mo*x_Mo/sin(beamtheta*pi/180));
b8 = exp(-mu_SS_Beam*p_SS*x_SS/sin(beamtheta*pi/180));
%exp(-mu_CIGS_beam.*p_CIGS.*depth./sin(beamtheta*pi/180));


% %plots grading and Beam I/Io vs depth
% figure
% plotyy(depth./(sin(beamtheta*pi/180)),b4,depth./(sin(beamtheta*pi/180)),sam_grad)

%Copper
i_io_cu = zeros(M,1);
mu_CIGS_cu = calc_mu_Cu(sam_grad);
c1 = exp(-mu_ITO_CuK*p_ITO*x_ITO/sin(detectortheta*pi/180)); %ITO attn
c2 = exp(-mu_ZnO_CuK*p_ZnO*x_ZnO/sin(detectortheta*pi/180)); %ZnO attn
c3 = exp(-mu_CdS_CuK*p_CdS*x_CdS/sin(detectortheta*pi/180)); %CdS attn
c4 = exp(-mu_SiN_CuK*p_SiN*x_SiN/sin(detectortheta*pi/180)); %SiN attn

%Total CuK fluorescence attenuation including incident beam attn
c5 = c1*c2*c3*c4*b5;

for N = 1:M
    for i = 1:N
        beam_in = -p_CIGS(1:i).*mu_CIGS_beam(1:i)*dt/sin(beamtheta*pi/180);
        beam_out = -p_CIGS(1:i).*mu_CIGS_cu(1:i)*dt/sin(detectortheta*pi/180);
        i_io_cu(N) = c5*exp(sum(beam_in+beam_out));
    end
end
fCu = sum(i_io_cu)/M;
%exp(-mu_CIGS_cu.*p_CIGS.*depth./sin(detectortheta*pi/180));
%fCu = trapz(c5)/length(depth);

% figure
% plotyy(depth./(sin(detectortheta*pi/180)),c4,depth./(sin(detectortheta*pi/180)),sam_grad)


%Gallium
i_io_ga = zeros(M,1);
mu_CIGS_ga = calc_mu_Ga(sam_grad);
g1 = exp(-mu_ITO_GaK*p_ITO*x_ITO/sin(detectortheta*pi/180)); %ITO attn
g2 = exp(-mu_ZnO_GaK*p_ZnO*x_ZnO/sin(detectortheta*pi/180)); %ZnO attn
g3 = exp(-mu_CdS_GaK*p_CdS*x_CdS/sin(detectortheta*pi/180)); %CdS attn
g4 = exp(-mu_SiN_GaK*p_SiN*x_SiN/sin(detectortheta*pi/180)); %SiN attn
%Total GaK fluorescence attenuation including incident beam attn
g5 = g1*g2*g3*g4*b5;
for N = 1:M
    for i = 1:N
        beam_in = -p_CIGS(1:i).*mu_CIGS_beam(1:i)*dt/sin(beamtheta*pi/180);
        beam_out = -p_CIGS(1:i).*mu_CIGS_ga(1:i)*dt/sin(detectortheta*pi/180);
        i_io_ga(N) = g5*exp(sum(beam_in+beam_out));
    end
end
fGa = sum(i_io_ga)/M;

% figure
% plotyy(depth./(sin(detectortheta*pi/180)),g4,depth./(sin(detectortheta*pi/180)),sam_grad)

%Indium
i_io_in = zeros(M,1);
mu_CIGS_in = calc_mu_In(sam_grad);
i1 = exp(-mu_ITO_InL*p_ITO*x_ITO/sin(detectortheta*pi/180)); %ITO attn
i2 = exp(-mu_ZnO_InL*p_ZnO*x_ZnO/sin(detectortheta*pi/180)); %ZnO attn
i3 = exp(-mu_CdS_InL*p_CdS*x_CdS/sin(detectortheta*pi/180)); %CdS attn
i4 = exp(-mu_SiN_InL*p_SiN*x_SiN/sin(detectortheta*pi/180)); %SiN attn
%Total GaK fluorescence attenuation including incident beam attn
i5 = i1*i2*i3*i4*b5;

for N = 1:M
    for i = 1:N
        beam_in = -p_CIGS(1:i).*mu_CIGS_beam(1:i)*dt/sin(beamtheta*pi/180);
        beam_out = -p_CIGS(1:i).*mu_CIGS_in(1:i)*dt/sin(detectortheta*pi/180);
        i_io_in(N) = i5*exp(sum(beam_in+beam_out));
    end
end
fIn = sum(i_io_in)/M;


% figure
% plotyy(depth./(sin(detectortheta*pi/180)),i4,depth./(sin(detectortheta*pi/180)),sam_grad)

%Selenium
i_io_se = zeros(M,1);
mu_CIGS_se = calc_mu_Se(sam_grad);
s1 = exp(-mu_ITO_SeK*p_ITO*x_ITO/sin(detectortheta*pi/180)); %ITO attn
s2 = exp(-mu_ZnO_SeK*p_ZnO*x_ZnO/sin(detectortheta*pi/180)); %ZnO attn
s3 = exp(-mu_CdS_SeK*p_CdS*x_CdS/sin(detectortheta*pi/180)); %CdS attn
s4 = exp(-mu_SiN_SeK*p_SiN*x_SiN/sin(detectortheta*pi/180)); %SiN attn
%Total GaK fluorescence attenuation including incident beam attn
s5 = s1*s2*s3*s4*b5;

for N = 1:M
    for i = 1:N
        beam_in = -p_CIGS(1:i).*mu_CIGS_beam(1:i)*dt/sin(beamtheta*pi/180);
        beam_out = -p_CIGS(1:i).*mu_CIGS_se(1:i)*dt/sin(detectortheta*pi/180);
        i_io_se(N) = s5*exp(sum(beam_in+beam_out));
    end
end
fSe = sum(i_io_se)/M;


TEND = num2str(toc(tstart));

disp(['Absorbtion Computation Time = ' TEND ' seconds.'])

end




function output = getgrading(samplename)
%X axis for grading profiles should be in cm. 
trigger = 0;
switch samplename
    
    case 'G23-16'
        %                   THESE ARE NOT REAL VALUES JUST AN INITIAL
        %                   ESTIMATION
        %norm of residual
        x = 1.8E-4; %cm
        grading = @(x) -1E-07*x.^5 + 1E-05*x.^4 - 0.0005*x.^3 + 0.0098*x.^2 - 0.0913*x + 0.6088;
        trigger = 1;
        output = struct('thick',x,'profile',grading);   
     case 'Large Miasole'
        %                   THESE ARE NOT REAL VALUES JUST AN INITIAL
        %                   ESTIMATION
        %norm of residual
        x = 1.8E-4; %cm
        grading = @(x) 1E-08*x.^6 - 1E-06*x.^5 + 6E-05*x.^4 - 0.0013*x.^3 + 0.0171*x.^2 - 0.1226*x + 0.6281;
        trigger = 1;
        output = struct('thick',x,'profile',grading);    
    case 'UDel CIS+KF'
        x=1.8e-4; %cm -- also a guess
        grading = @(x) 0.000000001*x+0.32;
        trigger = 1;
        output = struct('thick',x,'profile',grading);
    case 'UDel ACIS+KF'
        x=1.8e-4; %cm -- also a guess
        grading = @(x) 0.000000001*x+0.32;
        trigger = 1;
        output = struct('thick',x,'profile',grading);
end

if trigger == 0
    msgbox(['You have not enetered the grading or sample thickness for ' samplename]);
    return
else
    clear('trigger')
    %output the layer thickness and grading profile
end
end
