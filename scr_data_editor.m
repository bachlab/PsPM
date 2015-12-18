function varargout = scr_data_editor(varargin)
% SCR_DATA_EDITOR MATLAB code for scr_data_editor.fig
%      SCR_DATA_EDITOR, by itself, creates a new SCR_DATA_EDITOR or raises the existing
%      singleton*.
%
%      H = SCR_DATA_EDITOR returns the handle to a new SCR_DATA_EDITOR or the handle to
%      the existing singleton*.
%
%      SCR_DATA_EDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCR_DATA_EDITOR.M with the given input arguments.
%
%      SCR_DATA_EDITOR('Property','Value',...) creates a new SCR_DATA_EDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before scr_data_editor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to scr_data_editor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help scr_data_editor

% Last Modified by GUIDE v2.5 18-Dec-2015 15:17:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scr_data_editor_OpeningFcn, ...
                   'gui_OutputFcn',  @scr_data_editor_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before scr_data_editor is made visible.
function scr_data_editor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scr_data_editor (see VARARGIN)

% Choose default command line output for scr_data_editor
handles.output = hObject;
handles.mode = 'default';
handles.select = struct();
handles.plots = {};
handles.selected_data = {};
handles.epochs = {};
handles.highlighted_epoch = -1;

handles.fgDataEditor.WindowButtonDownFcn = @buttonDown_Callback;
handles.fgDataEditor.WindowButtonUpFcn = @buttonUp_Callback;
handles.fgDataEditor.WindowButtonMotionFcn = @buttonMotion_Callback;

p = plot(varargin{1});
hold on;
y = NaN(numel(p.YData),1);
x = p.XData;
hi = plot(x,y, 'LineWidth', 1.5);
hold off;

handles.plots{end+1}.data_plot = p;
handles.plots{end}.highlight_plot = hi;
handles.plots{end}.select_data.X = x';
handles.plots{end}.select_data.Y = y';

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = scr_data_editor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% UIWAIT makes scr_data_editor wait for user response (see UIRESUME)
% uiwait(handles.fgDataEditor);

% --- Executes on selection change in lbEpochs.
function lbEpochs_Callback(hObject, eventdata, handles)
% hObject    handle to lbEpochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbEpochs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbEpochs

epId = get(hObject,'Value');
HighlightEpoch(epId);

% --------------------------------------------------------------------
function ResetEpochHighlight
handles = guidata(gca);

for i=1:numel(handles.epochs)
    for j=1:numel(handles.epochs{i}.response_plots)
        set(handles.epochs{i}.response_plots{j}.p, ...
            'Color', 'green',  ...
            'LineWidth',0.5 ...
            );
    end;
end;

% --------------------------------------------------------------------
function HighlightEpoch(epId)
handles = guidata(gca);

% reset all epochs
ResetEpochHighlight;

ep = handles.epochs{epId};
range = ep.range(1):ep.range(2);

% highlight epochs
for i=1:numel(ep.response_plots)
    set(ep.response_plots{i}.p, 'Color', 'black', 'LineWidth', 1.5);
end;

cur_xlim = get(handles.axData, 'xlim');
start = cur_xlim(1);
stop = cur_xlim(2);
x_dist = stop-start;
new_dist = ep.range(2)-ep.range(1);

dstart = min(handles.plots{1}.data_plot.XData);
dstop = max(handles.plots{1}.data_plot.XData);

data_dist = dstop - dstart;

if (x_dist < data_dist)
    % try to set xlim
    if (new_dist > x_dist) % zoom out
        start = ep.range(1);
        stop = ep.range(2);
    else
        % try to center data
        offset = (x_dist-new_dist)/2;
        start = ep.range(1) - offset;
        stop = ep.range(2) + offset;
        
        if start < dstart
            start = dstart;
            stop = dstart+x_dist;
        elseif stop > dstop
            stop = dstop;
            start = stop-x_dist;
        end;
    end;  
    set(handles.axData, 'xlim', [start,stop]);
elseif x_dist >= data_dist
    start = dstart;
    stop = dstop;
    set(handles.axData, 'xlim', [start,stop]);
end;

x_dist = stop - start;

% try to set ylim
from = min(handles.plots{1}.data_plot.YData(range));
to = max(handles.plots{1}.data_plot.YData(range));

dmax = max(handles.plots{1}.data_plot.YData);
dmin = min(handles.plots{1}.data_plot.YData);

cur_ylim = get(handles.axData, 'ylim');
y_dist = cur_ylim(2) - cur_ylim(1);
new_dist = to - from;

if new_dist ~= y_dist
    if new_dist > y_dist
        start = from;
        stop = to;
    elseif new_dist < y_dist 
        if data_dist > x_dist
            offset = (y_dist-new_dist)/2;
            start = from - offset;
            stop = to + offset;
            if (stop > dmax || start < dmin) && ...
                    (round(dmax-dmin)==round(stop-start))
                stop = dmax;
                start = dmin;
            end;
        else
            start = dmin;
            stop = dmax;
        end;
    end;
    set(handles.axData, 'ylim', [start,stop]);
end;

handles.highlighted_epoch = epId;
guidata(gca, handles);


% --- Executes during object creation, after setting all properties.
function lbEpochs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbEpochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function fgDataEditor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fgDataEditor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function tlCursor_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tlCursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(gcf, 'Pointer', 'arrow');

% --------------------------------------------------------------------
function tlAddEpoch_OffCallback(hObject, eventdata, handles)
% hObject    handle to tlAddEpoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mode = 'default';

% change to crosshair
set(gcf,'Pointer','arrow');

handles.select.start = [0,0];
handles.select.stop = [0,0];
handles.select.p = 0;

guidata(hObject, handles);


% --------------------------------------------------------------------
function tlAddEpoch_OnCallback(hObject, eventdata, handles)
% hObject    handle to tlAddEpoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.tlRemoveEpoch.State = 'off';
handles.tlZoomin.State = 'off';
handles.tlZoomout.State = 'off';
handles.tlNavigate.State = 'off';
pan off;
zoom off;

handles.mode = 'addepoch';

% change to crosshair
set(gcf,'Pointer','crosshair');

handles.select.start = [0,0];
handles.select.stop = [0,0];
handles.select.p = 0;
guidata(hObject, handles);


% --------------------------------------------------------------------
function tlRemoveEpoch_OffCallback(hObject, eventdata, handles)
% hObject    handle to tlRemoveEpoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.mode = 'default';
set(gcf,'Pointer','arrow');
guidata(hObject, handles);


% --------------------------------------------------------------------
function tlRemoveEpoch_OnCallback(hObject, eventdata, handles)
% hObject    handle to tlRemoveEpoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.tlAddEpoch.State = 'off';
handles.tlZoomin.State = 'off';
handles.tlZoomout.State = 'off';
handles.tlNavigate.State = 'off';
pan off;
zoom off;

handles.mode = 'removeepoch';

% change to crosshair
set(gcf,'Pointer','crosshair');

handles.select.start = [0,0];
handles.select.stop = [0,0];
handles.select.p = 0;
guidata(hObject, handles);


% --------------------------------------------------------------------
function tlZoomin_OnCallback(hObject, eventdata, handles)
% hObject    handle to tlZoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.tlAddEpoch.State = 'off';
handles.tlRemoveEpoch.State = 'off';
handles.tlZoomout.State = 'off';
handles.tlNavigate.State = 'off';
pan off;
z = zoom;
z.Motion = 'horizontal';
z.Direction = 'in';
z.Enable = 'on';

% --------------------------------------------------------------------
function drawSelection
handles = guidata(gca);
pt = get(handles.axData, 'CurrentPoint');
pos = pt(1,1:2);
start = handles.select.start;

x = [start(1), pos(1), pos(1), start(1)];
y = [start(2), start(2), pos(2), pos(2)];

if handles.select.p ~= 0
    p = handles.select.p;
    p.XData = x;
    p.YData = y;
else
    p = patch(x,y, 'white', 'FaceColor', 'none');
    handles.select.p = p;
end;

guidata(gca, handles);

% --------------------------------------------------------------------
function buttonDown_Callback(src, data)
% get current cursor position
handles = guidata(gca);
switch handles.mode
    case {'addepoch','removeepoch'}
        pt = get(handles.axData, 'CurrentPoint');
        handles.select.start = pt(1,1:2);
end;
guidata(gca, handles);

% --------------------------------------------------------------------
function buttonUp_Callback(src, data)
% get current cursor position
handles = guidata(gca);
switch handles.mode 
    case 'addepoch'
        pt = get(handles.axData, 'CurrentPoint');
        handles.select.stop = pt(1,1:2);
        if handles.select.p ~= 0
            delete(handles.select.p);
            handles.select.p = 0;
        end;
        % add selected area and draw
        guidata(gca, handles);
        SelectedArea('add');
    case 'removeepoch'
        pt = get(handles.axData, 'CurrentPoint');
        handles.select.stop = pt(1,1:2);
        if handles.select.p ~= 0
            delete(handles.select.p);
            handles.select.p = 0;
        end;
        % add selected area and draw
        guidata(gca, handles);
        SelectedArea('remove');
end;

UpdateEpochList;

% --------------------------------------------------------------------
function buttonMotion_Callback(src, data)
handles = guidata(gca);

switch handles.mode
    case {'addepoch', 'removeepoch'}
        if isequal(handles.select.stop,[0,0]) && ...
                ~isequal(handles.select.start,[0,0])
            drawSelection;
            SelectedArea('highlight');
        end;       
end;

% --------------------------------------------------------------------
function SelectedArea(action)
handles = guidata(gca);
start = handles.select.start;
if strcmpi(action, 'highlight')
    pt = get(handles.axData, 'CurrentPoint');
    stop = pt(1,1:2);
else
    stop = handles.select.stop;
end;

if start(1) > stop(1)
    x_from = stop(1);
    x_to = start(1);
else
    x_from = start(1);
    x_to = stop(1);
end;

for i=1:numel(handles.plots)
    p = handles.plots{i};
    xd = p.data_plot.XData;
    yd = p.data_plot.YData;
    
    if strcmpi(action, 'highlight') && strcmpi(handles.mode, 'removeepoch')
        range = find(xd >= x_from & xd <= x_to & ~isnan(p.select_data.Y));
    else
        range = find(xd >= x_from & xd <= x_to);
    end;
    highlight_yd = NaN(numel(yd), 1);
    switch action
        case 'add'
            p.select_data.Y(range) = yd(range);   
        case 'remove'
            p.select_data.Y(range) = NaN;
        case 'highlight'
            highlight_yd(range) = yd(range);
    end;
    p.highlight_plot.YData = highlight_yd;
    handles.plots{i} = p;
end;

if ~strcmpi(action, 'highlight')
    handles.select.start = [0,0];
    handles.select.stop = [0,0];
end;

guidata(gca, handles);

% --------------------------------------------------------------------
function UpdateEpochList
handles = guidata(gca);

% we work with plot 1 only because epochs are for all plots the same
xd = handles.plots{1}.select_data.X;
yd = handles.plots{1}.select_data.Y;

% find epochs in yd
v_pos = find(~isnan(yd));
if numel(v_pos)>1
    epoch_end = [v_pos(find(diff(v_pos) > 1)), v_pos(end)];
    epoch_start = v_pos([1,find(diff(v_pos) > 1)+1]);
    
    ep = [epoch_start; epoch_end];
else
    ep = [];
end;
old_epochs = handles.epochs;
new_epochs = {};

for i=1:size(ep,2)
    response_plots = cell(numel(handles.plots),1);
    
    hold on;
    for j=1:numel(handles.plots)
        xd = handles.plots{j}.data_plot.XData;
        yd = NaN(numel(xd), 1);
        yd(ep(1,i):ep(2,i)) = handles.plots{j}.data_plot.YData(ep(1,i):ep(2,i));
        
        p = plot(xd, yd, 'Color', 'green');
        response_plots{j} = struct('p', p);
    end;
    hold off;
    
    new_epochs{i} = struct( ...
        'name', sprintf('%d: %d-%d', i, xd(ep(1,i)), xd(ep(2,i))) , ...
        'range', xd(ep(1:2, i)), ...
        'response_plots', {response_plots} ...
    );
end;

names = cellfun(@(x) x.name, new_epochs, 'UniformOutput', 0);
sel_ep = get(handles.lbEpochs, 'Value');
if sel_ep > numel(names)
    sel_ep = numel(names);
    set(handles.lbEpochs, 'Value', sel_ep);
elseif sel_ep == 0 && numel(names) > 0
    sel_ep = 1;
    handles.highlighted_epoch = -1;
    set(handles.lbEpochs, 'Value', sel_ep);
end;
set(handles.lbEpochs, 'String', names);

% clean up old_epochs
for i=1:numel(old_epochs)
    for j=1:numel(old_epochs{i}.response_plots)
        delete(old_epochs{i}.response_plots{j}.p);
    end;
end;

handles.epochs = new_epochs;

% put highlight plots on top
for i=1:numel(handles.plots)
    uistack(handles.plots{i}.highlight_plot, 'top');
end;

guidata(gca, handles);


% --------------------------------------------------------------------
function tlNavigate_OffCallback(hObject, eventdata, handles)
% hObject    handle to tlNavigate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pan off;


% --------------------------------------------------------------------
function tlNavigate_OnCallback(hObject, eventdata, handles)
% hObject    handle to tlNavigate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.tlAddEpoch.State = 'off';
handles.tlRemoveEpoch.State = 'off';
handles.tlZoomout.State = 'off';
handles.tlZoomin.State = 'off';
zoom off;
pan on;


% --------------------------------------------------------------------
function tlZoomout_OnCallback(hObject, eventdata, handles)
% hObject    handle to tlZoomout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.tlAddEpoch.State = 'off';
handles.tlRemoveEpoch.State = 'off';
handles.tlZoomin.State = 'off';
handles.tlNavigate.State = 'off';
pan off;

z = zoom;
z.Motion = 'horizontal';
z.Direction = 'out';
z.Enable = 'on';


% --------------------------------------------------------------------
function tlNext_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tlNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if handles.highlighted_epoch == -1 || ...
        handles.highlighted_epoch >= numel(handles.epochs)
    new_ep = 1;
else
    new_ep = handles.highlighted_epoch + 1;
end;

set(handles.lbEpochs, 'Value', new_ep);
HighlightEpoch(new_ep);


% --------------------------------------------------------------------
function tlPrevious_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tlPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.highlighted_epoch == -1 || ...
        handles.highlighted_epoch == 1 || ...
        handles.highlighted_epoch > numel(handles.epochs)
    
    new_ep = numel(handles.epochs);
else
    new_ep = handles.highlighted_epoch - 1;
end;
set(handles.lbEpochs, 'Value', new_ep);
HighlightEpoch(new_ep);