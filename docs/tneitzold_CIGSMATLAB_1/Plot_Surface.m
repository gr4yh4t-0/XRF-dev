function Plot_Surface(X,Y,Z,tit,z)
figure;

surface(X,Y,Z,'linestyle','none');
title(sprintf(tit))
xlabel('X position (\mum)');
ylabel('Y position (\mum)');
colormap jet
a = gca;
axis([min(X(1,:)) max(X(1,:)) min(Y(:,1)) max(Y(:,1))]);
daspect([1 1 1]);
c = colorbar;
set(c,...
    'LineWidth'         ,   1.2            );
ylabel(c ,sprintf(z));

%Set tick spacing for X and Y Axis
minX = min(X(1,:));
maxX = max(X(1,:));
if round(maxX) ~= round(maxX*100)/100
    maxX = floor(maxX);
end
stepX = (maxX-minX)/4;
xLabel = minX:stepX:maxX;

minY = floor(min(Y(:,1)));
maxY = max(Y(:,1));
if round(maxY) ~= round(maxY*100)/100
    maxY = floor(maxY);
end
stepY = (maxY-minY)/4;
yLabel = minY:stepY:maxY;

%Formats the X and Y Axis Ticks
set(a                         , ...
    'FontName'      ,   'Arial'     , ...
    'FontSize'      ,   20          , ...
    'FontWeight'    ,   'normal'    , ...
    'LineWidth'     ,   1           , ...
    'XTick'         ,   xLabel      , ...
    'XTickLabel'    ,   xLabel      , ...
    'YTick'         ,   yLabel      , ...
    'YTickLabel'    ,   yLabel      , ...
    'TickDir'       ,   'in'        ,...
    'TitleFontSizeMultiplier' , 1);

%Formats the Axis Titles
set ([a.XLabel, a.YLabel, c.Label]                           , ...
            'FontName'      ,       'Arial'         , ...
            'FontSize'      ,       20              , ...
            'FontWeight'    ,       'normal'          );       
end