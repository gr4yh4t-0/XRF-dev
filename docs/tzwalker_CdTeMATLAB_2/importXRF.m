function [output] = importXRF(file)

A = importdata(file);

for i = 1:size(A.colheaders, 2)
    A.colheaders{i} = genvarname(A.colheaders{i});
    %assignin('base', newData1.colheaders{i}, newData1.data(:,i));
    eval(['WORK.  ' A.colheaders{i}  '.raw = A.data(:,i);'])
end
%WORK = data.(scanheader);
WORK.headers = A.colheaders;

xPixelNo = WORK.xPixelNo.raw;
yPixelNo = WORK.yPixelNo.raw;

%Converts all raw data arrays into 2D matricies
for i = 1:length(WORK.headers)
    channel = WORK.headers{i};
%     WORK.(channel).map = map(xPixelNo,yPixelNo, WORK.(channel).raw);
    WORK.(channel).map = reshape(WORK.(channel).raw,[max(yPixelNo)+1,max(xPixelNo)+1]);
end

%Put the data back into the structure
output   = WORK;
end
