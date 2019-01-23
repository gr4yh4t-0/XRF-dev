%% Make multiple plots using plot_database and Plot_PrettySurface

% enter scan you are interested in:
scan='scan419';
X=xrf.(scan).rel_X;
Y=xrf.(scan).rel_Y;
[elements, extension, title,zbar]= plot_database(scan);

for i=1:length(elements)
    el = elements{1,i};
    ext = extension{1,i};
    tit=title{1,i};
    z=zbar{1,i};
    Z=xrf.(scan).(el).(ext);
    Plot_Surface(X,Y,Z,tit,z)
    
    % Saves the Image if you want
    % set(gcf, 'PaperPositionMode', 'auto');
    % print('-dtiff', '-r200', [scan el '.tiff']);
end