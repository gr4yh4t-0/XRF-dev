% Correcting XBIC for qantified elements

function CIGS_I_I0 = XBICattencorrect(MW_Cu, MW_Ga, MW_In, MW_Se, cu,in,ga,se,incidentE)

% turn this on when need to calculate Se for CIGS:
% se = (cu/MW_Cu + in/MW_In+ ga/MW_Ga)*MW_Se;

%all elements are now in g/cm2
%selenium has been estimated as Cu+In+GA

switch incidentE
    case 9.0
        muCU = 2.768E2; %cm2/g
        muGA = 4.561E1; %cm2/g
        muIN = 1.748E2; %cm2/g
        muSE = 5.88E1; %cm2/g
    case 10.4
        muCU = 1.962; %cm2/g
        muGA = 2.196E2; %cm2/g
        muIN = 1.189E2; %cm2/g
        muSE = 3.963E1; %cm2/g
    case 10.5
        muCU = 1.916E2; %cm2/g
        muGA = 2.143E2; %cm2/g
        muIN = 1.158E2; %cm2/g
        muSE = 3.861E1; %cm2/g
    case 12.8
        muCU = 1.141E2; %cm2/g
        muGA = 1.291E2; %cm2/g
        muIN = 6.797E2;  %cm2/g
        muSE = 1.545E2; %cm2/g
end

CIGS_I_I0 = 1 - exp(-cu.*muCU-in.*muIN-ga.*muGA-se.*muSE);

end