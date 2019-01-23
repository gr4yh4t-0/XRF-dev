%% plotting in mol/cm2
close all
scans = {'scan439' 'scan475' 'scan519' 'scan550'};                           %change to scans you've run
plot = {'XCE', 'Cd_L' , 'Te_L' , 'Cu'};                        %for reference within structure, used in surface function
%plotnaming = {'Cadmium', 'Tellurium', 'Copper'};        %for plot titles, labels, etc
ext = 'map_corr';

for j = 1:length(scans)
    for i = 1:length(plot)
        figure(j)
        subplot(2, 2, i);
        surface(xrf.(scans{j}).rel_X,   xrf.(scans{j}).rel_Y,   xrf.(scans{j}).(plot{i}).(ext), 'LineStyle', 'none');
        colormap jet;
        pltname = sprintf('%s, %s', samplename{j}, plot{i});
        title(pltname, 'fontsize', 10);
        xlabel('X position (\mum)','fontsize', 10);
        ylabel('Y position (\mum)','fontsize', 10);
        %set(gca,'fontsize',10,'fontweight','demi');
        z = colorbar;
        ynames = {'%', 'ug/cm2', 'ug/cm2', 'ug/cm2'};
        yname = ynames{i};
        ylabel(z, yname, 'fontsize', 10);
        axis square;
    end
        filename = sprintf("%s, %s.jpg", scans{j}, samplename{j});                                       %Specify name of sample
        plotpath = fullfile('C:\Users\Trumann\Desktop\2_xray\Plot Directory\', filename); %Specificy path in quotes
        saveas(gcf,  plotpath)
end
