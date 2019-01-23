function [scanlist,datelist,electtype, lockin,stanford,filt,flux,energy] = sample_database(samplename)
    switch samplename
        case 'G23-16'
        scanlist={'419'} % '142' '145' '153' '154' '165' '182' '185' '186' '195' '221' '222' '223' '254' '260' '261'}; %large grain
        datelist = {'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16'};
        electtype= {'XBIC' 'XBIC' 'XBIC' 'XBIC' 'XBIC' 'XBIC' 'XBIV' 'XBIV' 'XBIV' 'XBIV' 'XBIV' 'XBIV' 'XBIV' 'XBIV' 'XBIV' 'XBIC'};
        lockin=[1E8 1E8 1E8 1E8 1E8 1E8 1E3 1E3 1E3 1E3 1E5 1E5 1E5 1E4 1E4 10];
        stanford=[5E-8 5E-8 5E-8 5E-8 5E-8 5E-8 1 1 1 1 1 1 1 1 1 1E-7]; % in A/V
        filt =[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; %thickness in cm; only accurate for scan 221 right now 
        flux=6.4E5; % from runnotes slide 192
        energy = 10.5;

        case 'G06-16'
        datelist = {'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16' 'Jul 16'};
        electtype= {'XBIC' 'XBIV' 'XBIV' 'XBIV' 'XBIC'};

        case 'Miasole17'
        datelist = {'Dec 18 Ga' 'Dec 18 Ga' 'Dec 18 Ga'};  
        electtype= {'XBIC' 'XBIC' 'XBIV'}; 

        case 'AIST'
        datelist= {'Feb 18 Cu' 'Feb 18 Cu' 'Feb 18 Cu' 'Feb 18 Cu' 'Feb 18 Cu' 'Feb 18 Cu' 'Feb 18 Cu' 'Feb 18 Cu' 'Feb 18 Cu' 'Feb 18 Cu'}; 
        electtype={'XBIC' 'XBIC' 'XBIC' 'XBIC' 'XBIC' 'XBIC' 'XBIC' 'XBIC' 'XBIC'};
    
    end

end