function [elements, extension, title, zbar]= plot_database(scan)
switch scan
    case {'scan221','scan222','scan223','scan260'}
        elements = {'Ga', 'Cu', 'In_L', 'CGI', 'GGI', 'Fe', 'Cr', 'FetoCr', 'XBIV'}; 
        extension = {'map_mol', 'map_mol', 'map_mol', 'map', 'map', 'map_mol', 'map_mol', 'ratio.map', 'map'};
    
    case {'scan220','scan261'}
        elements = {'Ga', 'Cu', 'In_L', 'CGI', 'GGI', 'Fe', 'Cr', 'FetoCr','XBIC_XCE', 'XBIC_corr'}; 
        extension = {'map_mol', 'map_mol', 'map_mol', 'map', 'map', 'map_mol', 'map_mol', 'ratio.map', 'map', 'map'};
    case {'scan419'}
        elements = {'Cu', 'Cd_L', 'Te_L', 'ds_ic'};
        extension = {'map_mol', 'map'};
        title = {'Copper XRF Map', 'Cadmium XRF Map', 'Tellurium XRF Map','XBIC Map'};
        zbar = {'Concentration (mol/cm^2)','Concentration (mol/cm^2)','Concentration (mol/cm^2)','XBIC Signal (a.u.)'};
end
end