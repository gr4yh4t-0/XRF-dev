function [fCd, fTe, fCu] = CdTe_Absorb(sample, rundate)

%select the approriate beam setup for given rundate  --> i got rid of the
%other instances here because i didn't like looking at them... and i wasn't
%sure how much it helped
switch rundate
    case 'Dec 17'
        beamenergy = 8.99; %keV
        beamtheta = 90;  
        detectortheta = 47;
end

rad_beam = sin(beamtheta*pi/180);           %--> here i perform and define the angle to radians constant
rad_det = sin(detectortheta*pi/180);

%Stack
% Mo/ ZnTe/ Cu/ CdTe + CdCl2/ CdS + O2/ SnO2/ SnO2 + F/ CaHNaO2 --> i made this simply for reference

%capture cross-sections
%--> found values for relevant CdTe layers, this is where the python code would really shine, we wouldn't have to look these up

%Set SnO2 info
mu_SnO2_MoL = 1190.5; %cm2/g
mu_SnO2_ZnK= 171.0127; %cm2/g
mu_SnO2_TeL = 311.8658; %cm2/g
mu_SnO2_CuK = 197.3373; %cm2/g
mu_SnO2_CdL = 492.0328; %cm2/g
mu_SnO2_SK = 1171.4; %cm2/g

%Set CdS info
mu_CdS_MoL = 922.9015; %cm2/g
mu_CdS_ZnK = 168.2039; %cm2/g
mu_CdS_TeL = 1221; %cm2/g
mu_CdS_CuK = 1.933E2; %cm2/g
mu_CdS_CdL = 657.7857; %cm2/g

%Set CdTe info
mu_CdTe_CdL  = 566.2543; %cm2/g
mu_CdTe_TeL  = 8.372E2; %cm2/g
mu_CdTe_CuK  = 2.454E2; %cm2/g

%Set Cu info
mu_Cu_CdL = 695.4808;
mu_Cu_TeL =  440.4480;
mu_Cu_CuK = 51.8756;

%Set ZnTe info
mu_ZnTe_CdL = 680.0102;
mu_ZnTe_TeL = 437.554;
mu_ZnTe_CuK = 196.3259;

%Set Mo info
mu_Mo_CdL = 1872.8;
mu_Mo_TeL = 1212.0;
mu_Mo_CuK = 154.9601;

if     beamenergy == 8.0                %--> largerly left this alone, didn't want to mess with any of it for now
    mu_ITO_Beam = 1.997E2; %cm2/g
    mu_ZnO_Beam = 4.900E1;   %cm2/g
    mu_SnS_Beam = 9.776E2; %cm2/g
elseif beamenergy == 9.0
    % these are scattering of layer itself; use beam energy instead of element energy 
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
elseif beamenergy == 8.99               %correct values
    mu_Mo_Beam = 121.5342; %cm2/g
    mu_ZnTe_Beam = 152.0136; %cm2/g
    mu_Cu_Beam = 277.6288; %cm2/g
    mu_CdS_Beam = 152.5925; %cm2/g
    mu_CdTe_Beam= 194.2055; %cm2/g
    mu_SnO2_Beam = 155.2955;
    mu_SLG_Beam = 64.0922;
else
    msgbox(['The beam energy for the run on ' rundate 'and for sample ', ...
        sample ' has not be entered yet. Please input the run information.']);
end

%set layer densities
calc_p_CIGS = @(x) -0.15.*x + 5.75; %Formula to Calculate CIGS density Cu(In(1-x),Ga(x))Se2
p_Mo = 10.22;       %g/cm3
p_ZnTe = 6.34;      %g/cm3
p_Cu = 8.96;        %g/cm3
p_CdTe = 5.85;      %g/cm3
p_CdS = 4.82;       %g/cm3
p_SnO2 = 6.85;      %g/cm3 (all looked up)

%set layer thickness
x_Mo = 5.0E-5;              %cm
x_ZnTe = 3.75E-5;           %cm   
x_hiCu = 1E-6;              %cm          MUST CHANGE FOR EACH CdTe SAMPLE
x_CdTe = 5.0E-4;                        %cm
x_CdS = 8E-6;            %cm
x_SnO2 = 6E-5;    %bottom 500nm layer has F, top 100nm layer no F

%set CdTe layer increments and gradings
dt = 0.000001; %1nm thick layers
M = x_CdTe/dt;
M = round(M); %rounds to nearest integer for total number of layers
depth = 0:dt:x_CdTe; %1nm increments

%internal layer absorption
%--> note for the next couple lines, position of element in stack must match position of value in lay_mu_beam, lay_thick, and lay_dens
%

stack = {'Mo', 'ZnTe', 'hiCu', 'CdTe', 'CdS', 'SnO2'};                 %--> placed elements as strings in a stack 
lay_mu_beam =[121.5342 152.0136 277.6288 152.5925 194.2055 155.2955];   %--> placed layer attenuation in matrix 
lay_thick = [5.0E-5 3.75E-5 1E-6 5.0E-4 8E-6 6E-5];                      %--> placed layer thickness in matrix 
lay_dens = [10.22 6.34 8.96 5.85 4.82 6.85];                            %--> placed compound density in matrix, looked up, didn't calculate

Bo = prod(exp(-lay_mu_beam.*lay_dens.*lay_thick/rad_beam)); % total incident beam attenuation (Bo), not sure if this is correct, but it's what i gathered previous versions of the code were performing
                                                            %no for loop necessary because all constants  

%from here forward the changes applied to the first element (Cd), were
%applied to the loops and sections for Te and Cu
                                                            
%Cadmium
i_io_cd = zeros(M,1);                       %--> here's the first instance of the angle to radians conversion
cd1 = exp(-mu_Mo_CdL*p_Mo*x_Mo/rad_det); 
cd2 = exp(-mu_ZnTe_CdL*p_ZnTe*x_ZnTe/rad_det);
cd3 = exp(-mu_Cu_CdL*p_Cu*x_hiCu/rad_det); 
cd4 = exp(-mu_CdTe_CdL*p_CdTe*x_CdTe/rad_det);

%Total CdL fluorescence attenuation including incident beam attn
cdo = Bo*cd1*cd2*cd3*cd4;                               %-->Bo included this line for each element section; seemed to be how previous files incorporated it
                                                        %also might've redefined "cdo"
for i = 1:length(depth)                                 %-->eliminated double for loop, it was redundant
        beam_in = -p_CdS*mu_CdS_Beam*depth(i)/rad_beam;
        beam_out = -p_CdS*mu_CdS_CdL*depth(i)/rad_det; %(check 1-sin?)
        i_io_cd(i) = cdo*exp(sum(beam_in+beam_out));
end
fCd = sum(i_io_cd)/M;

%Tellurium 
i_io_te = zeros(M,1);
te1 = exp(-mu_Mo_TeL*p_Mo*x_Mo/rad_det); 
te2 = exp(-mu_ZnTe_TeL*p_ZnTe*x_ZnTe/rad_det);
te3 = exp(-mu_Cu_TeL*p_Cu*x_hiCu/rad_det); 

%Total TeL fluorescence attenuation including incident beam attn
teo = Bo*te1*te2*te3;

for i=1:length(depth)
    beam_in = -p_CdTe*mu_CdTe_Beam*depth(i)/rad_beam;
    beam_out = -p_CdTe*mu_CdTe_TeL*depth(i)/rad_det;
    i_io_te(i) = teo*exp(sum(beam_in+beam_out));
end
fTe = sum(i_io_te)/M;

%Copper 
i_io_cu = zeros(M,1);
cu1 = exp(-mu_Mo_CuK*p_Mo*x_Mo/rad_det); 
cu2 = exp(-mu_ZnTe_CuK*p_ZnTe*x_ZnTe/rad_det);

%Total CuK fluorescence attenuation including incident beam attn
teo = Bo*cu1*cu2;

for i = 1:length(depth)
    beam_in = -p_Cu*mu_Cu_Beam*depth(i)/rad_beam;
    beam_out = -p_Cu*mu_Cu_CuK*depth(i)/rad_det;
    i_io_cu(i) = exp(sum(beam_in+beam_out));
end
fCu = sum(i_io_cu)/M;
end

