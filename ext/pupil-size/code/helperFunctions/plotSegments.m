function plotSegments(hAxs,segmentData)
% plotSegments Visualizes segments as patches.
%
%   This is an internal helper script, and is not intended to be called by
%   users.
%
%--------------------------------------------------------------------------
%
%   This code is part of the supplement material to the article:
%
%    Preprocessing Pupil Size Data. Guideline and Code.
%     Mariska Kret & Elio Sjak-Shie. 2018.
%
%--------------------------------------------------------------------------
%
%     Pupil Size Preprocessing Code (v1.1)
%      Copyright (C) 2018  Elio Sjak-Shie
%       E.E.Sjak-Shie@fsw.leidenuniv.nl.
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or (at
%     your option) any later version.
%
%     This program is distributed in the hope that it will be useful, but
%     WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%--------------------------------------------------------------------------


%% Generate Patches:

% Extract data from segments table:
segmentStart  = segmentData.segmentStart;
segmentEnd    = segmentData.segmentEnd;
segmentCount  = length(segmentEnd);

% Make patch stacking levels:
allLevels         = (1:segmentCount)';
segmentPlotLevel  = [1;NaN(segmentCount-1,1)];
for segmentII     = 2:segmentCount
    collisions    = (segmentStart(1:(segmentII-1))...
        <segmentEnd(segmentII))...
        &(segmentEnd(1:(segmentII-1))...
        >segmentStart(segmentII));
    segmentPlotLevel(segmentII) ...
        = find(~ismember(allLevels,segmentPlotLevel(collisions))...
        ,1,'first');
end
totalLevels  = max(segmentPlotLevel);
margin       = min([0.1/(totalLevels-1),0.15]);
levelHeight  = (1-((totalLevels-1)*margin))/totalLevels;
yPatchBottom = 0:(levelHeight+margin):1;
yPatchTop    = levelHeight:(levelHeight+margin):1;

% Generate patch data, and plot patches:
yPatchAllLevels    = [yPatchBottom;yPatchBottom;yPatchTop;yPatchTop];
yPatch             = yPatchAllLevels(:,segmentPlotLevel);
xPatch             = [segmentStart';segmentEnd';segmentEnd';segmentStart'];
segmentColorRand   = hsv2rgb(rgb2hsv(jet(segmentCount)).*...
    repmat([0.9 0.5 0.9],segmentCount,1));
rng(sum(uint8('   :-D     oh hai  ')));
segmentColorRand   = segmentColorRand(randperm(segmentCount)',:);
if isprop(hAxs,'ClippingStyle')
    set(hAxs,'ClippingStyle','rectangle');
end
hPatch             = patch(xPatch,yPatch...
    ,reshape(segmentColorRand,1,segmentCount,3),'parent',hAxs);
set(hPatch,'EdgeColor',[20 20 20]/255)
ylim(hAxs,[(-1.5*margin) 1+(1.5*margin)]);

% Add User Interaction:
set(hPatch,'ButtonDownFcn',@(src,evt) ...
    clickCB(src,evt,segmentData));
hZoom = zoom;
hPan  = pan;
set(hZoom,'ButtonDownFilter',@zoomCB);
set(hPan,'ButtonDownFilter',@zoomCB);
setAxesZoomMotion(hZoom,hAxs,'horizontal');
setAxesPanMotion(hPan,hAxs,'horizontal');


end


%% Callback Functions:

%==========================================================================
function flag = zoomCB(src,~)
% Callback function for supressing the zoom and pan actions when clickin on
% pacthes.
%
%--------------------------------------------------------------------------

% Check if the user clicked on a patch (test HG & HG2 names); if they did,
% disable the pan/zoom:
if isa(src,'matlab.graphics.primitive.Patch') || isa(src,'patch')
    flag = true;
else
    flag = false;
end
end


%==========================================================================
function clickCB(src,evt,segmentData)
% Callback for showing segment info.
%
%--------------------------------------------------------------------------

% Hittest:
if ~verLessThan('matlab','8.5') && evt.Button ~=1
    return
end
if verLessThan('matlab','8.5')
    IntersectionPoint = get(get(src,'Parent'),'CurrentPoint');
    IntersectionPoint = IntersectionPoint(1,1:2);
else
    IntersectionPoint = evt.IntersectionPoint;
end
XData             = get(src,'XData');
YData             = get(src,'YData');
isInWhichSegment ...
    = (...
    IntersectionPoint(1)   >=   XData(1:4:end)...
    & IntersectionPoint(1)  <   XData(2:4:end))...
    ...
    & (IntersectionPoint(2) >=  YData(1:4:end)...
    & IntersectionPoint(2)  <   YData(3:4:end)...
    );
if ~any(isInWhichSegment)
    return
end

% Show popup:
segmentNames = cellstr(segmentData.segmentName);
uiwait(msgbox([...
    'Segment Name: ' ...
    segmentNames{isInWhichSegment} char(10) ...
    'Segment Start Time: ' ...
    num2str(segmentData.segmentStart(isInWhichSegment))...
    ' seconds' char(10) ...
    'Segment End Time: ' ...
    num2str(segmentData.segmentEnd(isInWhichSegment))...
    ' seconds' char(10) ...
    'Segment Duration: ' ...
    num2str(segmentData.segmentEnd(isInWhichSegment)...
    -segmentData.segmentStart(isInWhichSegment))...
    ' seconds'],'Segment','modal')) %#ok<*CHARTEN>

end



