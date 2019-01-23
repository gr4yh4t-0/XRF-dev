%% plotting in mol/cm2
scan1 = 'scan398';
plot1 = 'Cd_L';
plot2 = 'Te_L';
plot3 = 'Cu';
ext = 'map_mol';
ext2 = 'map';

figure
surface(xrf.(scan1).rel_X,   xrf.(scan1).rel_Y,   xrf.(scan1).(plot1).(ext), 'LineStyle', 'none')
colormap jet
title('Cadmium XRF Map','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
set(gca,'fontsize',20,'fontweight','demi')
z= colorbar;
ylabel(z, 'Cd [mol/cm2]', 'fontsize', 20);
axis square
figure
surface(xrf.(scan1).rel_X,xrf.(scan1).rel_Y,xrf.(scan1).(plot2).(ext), 'LineStyle', 'none')
colormap jet
title('Tellerium XRF Map','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
axis square
z= colorbar;
set(gca,'fontsize',20,'fontweight','demi')
ylabel(z, 'Te [mol/cm2]', 'fontsize', 20);
axis square
figure
surface(xrf.(scan1).rel_X,xrf.(scan1).rel_Y,xrf.(scan1).(plot3).(ext), 'LineStyle', 'none')
colormap jet
title('Copper XRF Map','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
axis square
z= colorbar;
set(gca,'fontsize',20,'fontweight','demi')
ylabel(z, 'Cu [mol/cm2]', 'fontsize', 20);
axis([0 10 0 10])






%% for watershed
scan='scan141';

figure
surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).cigs.map, 'LineStyle', 'none')
colormap gray
%title('Ga+Cu','fontsize',20);
%xlabel('X position (\mum)','fontsize', 20);
%ylabel('Y position (\mum)','fontsize', 20);
z= colorbar;
%ylabel(z, 'Sum', 'fontsize', 20);
%set(gca,'fontsize',20,'fontweight','demi')
% zlabel('Cu [mol/cm2]');
axis square
%axis([10 15 15 20])
%axis([0 0.4 0 0.4])
%axis([0 50 0 50])

%% plotting in at%

scan = 'scan222';
plot1 = 'Curatio';
plot2 = 'Inratio';
plot3 = 'Garatio';
ext = 'map';


figure
surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).(plot1).(ext), 'LineStyle', 'none')
colormap jet
title('Copper Atomic %','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
z= colorbar;
ylabel(z, '%Cu', 'fontsize', 20);
set(gca,'fontsize',20,'fontweight','demi')
% zlabel('Cu [mol/cm2]');
axis square
axis([0 20 0 20])
%axis([0 0.4 0 0.4])
% axis([0 10 0 10])

figure
surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).(plot2).(ext), 'LineStyle', 'none')
colormap jet
title('Indium Atomic %','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
set(gca,'fontsize',20,'fontweight','demi')
axis square
z= colorbar;
ylabel(z, '%In', 'fontsize', 20);
%axis([0 0.4 0 0.4])
axis([0 20 0 20])
% axis([0 10 0 10])

figure
surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).(plot3).(ext), 'LineStyle', 'none')
colormap jet
title('Gallium Atomic %','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
set(gca,'fontsize',20,'fontweight','demi')
axis square
z= colorbar;
ylabel(z, '%Ga', 'fontsize', 20);
axis([0 20 0 20])
% axis([0 10 0 10])

%% Plotting GGI and CGI

scan = 'scan222';
plot1 = 'GGI';
plot2 = 'CGI';
ext = 'map';

figure; 
surface(xrf.(scan).rel_X,xrf.(scan).rel_Y, xrf.(scan).(plot1).(ext), 'LineStyle', 'none')
colormap jet
axis square
title('GGI','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
set(gca,'fontsize',20,'fontweight','demi')
z= colorbar;
% ylabel(z, 'Ga/(Ga+In)', 'fontsize', 20);
% zlabel('GGI');
axis([0 20 0 20])
%axis([0 0.4 0 0.4])

figure
surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).(plot2).(ext), 'LineStyle', 'none')
colormap jet
title('CGI','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
set(gca,'fontsize',20,'fontweight','demi')
z= colorbar;
ylabel(z, 'Cu/(Ga+In)', 'fontsize', 20);
% zlabel('Cu [mol/cm2]');
axis square
axis([0 20 0 20])
%axis([0 0.4 0 0.4])

%% Simple code for plotting various maps together for comparison

scan = 'scan296';
plot1 = 'Gapartialratio';
plot2 = 'Cupartialratio';
ext = 'map';

figure 
surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).(plot1).(ext), 'LineStyle', 'none')
colormap gray
title('Ga Atomic % (without In)','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
set(gca,'fontsize',20,'fontweight','demi')
z=colorbar;
ylabel(z, 'Ga atomic percent', 'fontsize', 20);

axis square
axis([0 20 0 20])
% axis([0 5 0 5])

figure
surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).(plot2).(ext), 'LineStyle', 'none')
colormap jet
title('Copper Atomic % (without In)','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
set(gca,'fontsize',20,'fontweight','demi')
z=colorbar;
ylabel(z, 'Cu atomic percent', 'fontsize', 20);
axis square
axis([0 20 0 20])
%axis([0 0.4 0 0.4])
% axis([0 5 0 5])

% figure
% surface(xrf.scan279.xPixelNo.map,xrf.scan279.yPixelNo.map,xrf.scan279.PbIratio.map, 'LineStyle', 'none')

%% Plotting Stainless Steel Substrate at%

scan = 'scan222';
plot1 = 'Fe';
plot2 = 'Cr';
ext = 'ratio.map';

figure
surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).(plot1).ratio.map, 'LineStyle', 'none')
colormap jet
title('Iron Concentration','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
set(gca,'fontsize',20,'fontweight','demi')
axis square
z= colorbar;
ylabel(z, '[Fe]/[Fe]+[Cr]', 'fontsize', 20);
%axis([0 50 0 50])
%axis([0 10 0 10])
 axis([0 20 0 20])

% figure
% surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).(plot2).ratio.map, 'LineStyle', 'none')
% colormap jet
% title('Chromium Atomic %','fontsize',20);
% xlabel('X position (\mum)','fontsize', 20);
% ylabel('Y position (\mum)','fontsize', 20);
% set(gca,'fontsize',20,'fontweight','demi')
% axis square
% z= colorbar;
% ylabel(z, '%Cr', 'fontsize', 20);
% %axis([0 50 0 50])
% % axis([0 10 0 10])
% axis([0 20 0 20])
%% Plot other element channels

scan= 'scan222'; 
plot1= 'sub';
ext= 'map';

figure
surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).(plot1).(ext), 'LineStyle', 'none')
colormap hot
title('Steel XRF Map','fontsize',20);
xlabel('X position (\mum)','fontsize', 20);
ylabel('Y position (\mum)','fontsize', 20);
axis square
axis([0 20 0 20])
z= colorbar;
set(gca,'fontsize',20,'fontweight','demi')
ylabel(z, '[Fe] + [Cr] (\mug/cm^2)', 'fontsize', 20);


%% Plot XBIV
scan = 'scan222';
plot1='elect';
figure
surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).(plot1).map_corr, 'LineStyle', 'none')
colormap hot
xlabel('X position (µm)','fontsize',20);
ylabel('Y position (µm)','fontsize',20);
title('XBIV','fontsize',20);
z=colorbar;
ylabel(z, 'V (µV)', 'fontsize', 20);
axis([0 20 0 20])
set(gca,'fontsize',20,'fontweight','demi')
axis square

caxis([2.5 5.2])
%zlim([0 1]); 
%caxis([90 220]);
% %ylim([0 20]);
% min(min(uVXBIC));
% max(max(uVXBIC));
%surface(Xpos,Ypos,uVXBIC, 'LineStyle', 'none')
% range to block out dark blob : (16:61,1:101)
%surface(Xpos,Ypos, Xbic.XBICcorr.map, 'LineStyle', 'none')
% zD = uVXBIC;
%     %zD = flipud(zD);
%     alphadata = zeros(size(uVXBIC));
%     clf;
%     surface('XData',Xpos,...
%         'YData',Ypos,...
%         'ZData',alphadata,...
%         'Cdata',zD,...
%         'LineStyle','none');
%         view(-30,48)
%% Plot XBIC

scan = 'scan350';
plot1='elect';
figure
hparent=surface(xrf.(scan).rel_X,xrf.(scan).rel_Y,xrf.(scan).(plot1).map_corr, 'LineStyle', 'none');

colormap hot
xlabel('X position (µm)','fontsize',20);
ylabel('Y position (µm)','fontsize',20);
title('XBIC','fontsize',20);
set(gca,'fontsize',20,'fontweight','demi')
axis square
% axis([0 20 0 20])
axis([0 7.5 0 7.5])
z=colorbar;
ylabel(z, 'Current (nA)', 'fontsize', 20);
 
% h = impoly(hparent, position)
% caxis([2.2 4.8]);
%ylim([0 20]);
% min(min(actualXBIC))
% max(max(actualXBIC))

%%
