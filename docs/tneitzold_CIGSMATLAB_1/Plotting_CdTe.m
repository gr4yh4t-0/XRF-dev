%% plotting in mol/cm2
close all
scans = {'scan575'};                           %change to scans you've corrected
plot = {'Cd_L' , 'Te_L' , 'Cu'};                        %for reference within structure, used in surface function
plotnaming = {'Cadmium', 'Tellurium', 'Copper'};        %for plot titles, labels, etc
ext = 'map';
% ext2 = 'map';

for j = 1:length(scans)
    for i = 1:length(plot)
        figure(i);
        surface(xrf.(scans{j}).rel_X,   xrf.(scans{j}).rel_Y,   xrf.(scans{j}).(plot{i}).(ext), 'LineStyle', 'none');
        colormap jet;
        pltname = [plotnaming{i} ' XRF Map'];
        title(pltname,'fontsize',20);
        xlabel('X position (\mum)','fontsize', 20);
        ylabel('Y position (\mum)','fontsize', 20);
        set(gca,'fontsize',20,'fontweight','demi');
        z= colorbar;
        yname = [plotnaming{i} ' [mol/cm2]'];
        ylabel(z, yname, 'fontsize', 20);
        axis square;
        filename = sprintf("20180716 NBL3-2 %s.jpg", plot{i});                 %Specify name of sample
        plotpath = fullfile('C:\Users\Trumann\Desktop\2_xray\plots', filename); %Specificy path in quotes
        saveas(gcf,plotpath)
    end
end
%%
figure(5);
surface(xrf.scan609.rel_X,   xrf.scan609.rel_Y,   xrf.scan609.ds_ic.map, 'LineStyle', 'none');
colormap jet;
pltname = ['XBIC Map'];
title(pltname,'fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
set(gca,'fontsize',20,'fontweight','demi');
z= colorbar;
yname = ['Current(nA)'];
ylabel(z, yname, 'fontsize', 20);
axis square;
