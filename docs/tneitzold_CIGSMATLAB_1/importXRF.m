function [output] = importXRF(file)
%file  = ['I:\ArgonneData_Fitted\SnS_data\output\combined_ASCII_2idd_0' scan '.h5.csv'];
newData1 = importdata(file);

for i = 1:size(newData1.colheaders, 2)
    newData1.colheaders{i} = genvarname(newData1.colheaders{i});
    %assignin('base', newData1.colheaders{i}, newData1.data(:,i));
    eval(['WORK.  ' newData1.colheaders{i}  '.raw = newData1.data(:,i);'])
end
%WORK = data.(scanheader);
WORK.headers = newData1.colheaders;

xPixelNo = WORK.xPixelNo.raw;
yPixelNo = WORK.yPixelNo.raw;

%Converts all raw data arrays into 2D matricies
for i = 1:length(WORK.headers)
    channel = WORK.headers{i};
    %WORK.(channel).map = map(xPixelNo,yPixelNo,WORK.(channel).raw);
    WORK.(channel).map = reshape(WORK.(channel).raw,[max(yPixelNo)+1,max(xPixelNo)+1]);
end


%Put the data back into the structure
output   = WORK;
end
