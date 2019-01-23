%% Import and Plot XANES Spectra
path='C:\Users\Tara\Documents\Research\NREL_CdTe\17-12_2IDD\CdTe\';
scan={'411'};

for i=1:length(scan)
    newscan=scan{1,i};
    file=[path 'line2idd_0' newscan '.h5.csv'];
    newData1=importdata(file);
    
end

for i = 1:size(newData1.colheaders, 2)
    newData1.colheaders{i} = genvarname(newData1.colheaders{i});
    %assignin('base', newData1.colheaders{i}, newData1.data(:,i));
    eval(['WORK.  ' newData1.colheaders{i}  '.raw = newData1.data(:,i);'])
end
%WORK = data.(scanheader);
WORK.headers = newData1.colheaders;

%Put the data back into the structure
output   = WORK;

WORK.Cu.raw=WORK.Cu0x5Bug0x2Fcm0x5E20x5D.raw;
WORK.Cd.raw=WORK.Cd_L0x5Bug0x2Fcm0x5E20x5D.raw;
WORK.Te.raw=WORK.Te_L0x5Bug0x2Fcm0x5E20x5D.raw;
WORK.xpos.raw=WORK.axis_pos0x5Bmm0x5D.raw*1000; %keV

%% plot spectra

plot(WORK.xpos.raw,WORK.Cu.raw,'LineWidth',1.25)
xlabel('Energy (keV)','fontsize', 16);
ylabel('Cu Intensity','fontsize', 16);
set(gca,'fontsize',16,'fontweight','demi')
