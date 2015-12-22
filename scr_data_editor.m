function varargout = scr_data_editor(varargin)
% SCR_DATA_EDITOR MATLAB code for scr_data_editor.fig

%__________________________________________________________________________
% PsPM 3.1
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% Last Modified by GUIDE v2.5 22-Dec-2015 14:29:19

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
handles.output = {};
handles.mode = 'default';
handles.select = struct();
handles.plots = {};
handles.selected_data = {};
handles.epochs = {};
handles.highlighted_epoch = -1;
handles.output_type = 'interpolate';

set(handles.fgDataEditor, 'WindowButtonDownFcn', @buttonDown_Callback);
set(handles.fgDataEditor, 'WindowButtonUpFcn', @buttonUp_Callback);
set(handles.fgDataEditor, 'WindowButtonMotionFcn', @buttonMotion_Callback);
corder = get(handles.fgDataEditor, 'defaultAxesColorOrder');

p = plot(varargin{1}, 'Color', corder(1,:));
hold on;
ydata = get(p, 'YData');
y = NaN(numel(ydata),1);
x = get(p, 'XData');

handles.limits.x = get(handles.axData, 'xlim');
handles.limits.y = get(handles.axData, 'ylim');

handles.plots{end+1}.data_plot = p;
handles.NaN_data = y;
handles.plots{end}.y_data = ydata;
handles.x_data = x;
handles.plots{end}.sel_container = hggroup;
handles.plots{end}.highlight_plot = plot(x,y, 'LineWidth', 1.5, 'Color', corder(2,:));
handles.plots{end}.select_data.X = x';
handles.plots{end}.select_data.Y = y';
handles.plots{end}.interpolate = plot(x,y, 'LineWidth', 0.5, 'Color', corder(3,:));
uistack(handles.plots{end}.interpolate, 'bottom');

hold off;

% Update handles structure
guidata(hObject, handles);
uiwait(handles.fgDataEditor);

% --- Outputs from this function are returned to the command line.
function varargout = scr_data_editor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% UIWAIT makes scr_data_editor wait for user response (see UIRESUME)
varargout{1} = handles.output;
delete(hObject);

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
    if handles.epochs{i}.highlighted
        for j=1:numel(handles.epochs{i}.response_plots)
            set(handles.epochs{i}.response_plots{j}.p, ...
                'Color', 'green',  ...
                'LineWidth',0.5 ...
                );
        end;
        handles.epochs{i}.highlighted = false;
    end;
end;

guidata(gca, handles);

% --------------------------------------------------------------------
function HighlightEpoch(epId)
handles = guidata(gca);

% reset all epochs
ResetEpochHighlight;

ep = handles.epochs{epId};

ep.highlighted = true;
handles.epochs{epId} = ep;

range = ep.range(1):ep.range(2);

% highlight epochs
for i=1:numel(ep.response_plots)
    set(ep.response_plots{i}.p, 'Color', 'black', 'LineWidth', 1.5);
end;

cur_xlim = handles.limits.x;
start = cur_xlim(1);
stop = cur_xlim(2);
x_dist = stop-start;
new_dist = ep.range(2)-ep.range(1);

dstart = min(handles.x_data);
dstop = max(handles.x_data);

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
    handles.limits.x = [start,stop];
elseif x_dist >= data_dist
    start = dstart;
    stop = dstop;
    set(handles.axData, 'xlim', [start,stop]);
end;

x_dist = stop - start;

% try to set ylim
from = min(handles.plots{1}.y_data(range));
to = max(handles.plots{1}.y_data(range));

dmax = max(handles.plots{1}.y_data);
dmin = min(handles.plots{1}.y_data);

cur_ylim = handles.limits.y;
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
    handles.limits.y = [start,stop];
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

set(handles.tlRemoveEpoch, 'State', 'off');
set(handles.tlZoomin, 'State', 'off');
set(handles.tlZoomout, 'State', 'off');
set(handles.tlNavigate, 'State', 'off');
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

set(handles.tlAddEpoch, 'State', 'off');
set(handles.tlZoomin, 'State', 'off');
set(handles.tlZoomout, 'State', 'off');
set(handles.tlNavigate, 'State', 'off');
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

set(handles.tlRemoveEpoch, 'State', 'off');
set(handles.tlAddEpoch, 'State', 'off');
set(handles.tlZoomout, 'State', 'off');
set(handles.tlNavigate, 'State', 'off');
pan off;

z = zoom;
set(z, 'Motion', 'horizontal');
set(z, 'Direction', 'in');
% unset OnCallback while enabling zoomin otherwise this would end up in a
% recurstion loop (dont know why exactly)
cb = get(handles.tlZoomin, 'OnCallback');
set(handles.tlZoomin, 'OnCallback', '');
set(z, 'Enable', 'on');
set(handles.tlZoomin, 'OnCallback', cb);

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
    set(p, 'XData', x);
    set(p, 'YData', y);
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
    xd = handles.x_data;
    yd = p.y_data;
    
    if strcmpi(action, 'highlight') && strcmpi(handles.mode, 'removeepoch')
        range = find(xd >= x_from & xd <= x_to & ~isnan(p.select_data.Y));
    else
        range = find(xd >= x_from & xd <= x_to);
    end;
    highlight_yd = handles.NaN_data;
    switch action
        case 'add'
            p.select_data.Y(range) = yd(range);   
        case 'remove'
            p.select_data.Y(range) = NaN;
        case 'highlight'
            highlight_yd(range) = yd(range);
    end;
    set(p.highlight_plot, 'YData', highlight_yd);
    handles.plots{i} = p;
end;

if ~strcmpi(action, 'highlight')
    handles.select.start = [0,0];
    handles.select.stop = [0,0];
end;

guidata(gca, handles);

% --------------------------------------------------------------------
function InterpolateData
handles = guidata(gca);
interp_state = get(handles.cbInterpolate, 'Value');

if interp_state ~= 0 && strcmpi(handles.output_type, 'interpolate');
    for i=1:numel(handles.plots)
        xd = handles.x_data;
        yd = handles.plots{i}.y_data;
        
        for j = 1:numel(handles.epochs)
            start = find(xd == handles.epochs{j}.range(1));
            stop = find(xd == handles.epochs{j}.range(2));
            yd(start:stop) = NaN;
        end;
        [sts, newyd] = scr_interpolate(yd);
        set(handles.plots{i}.interpolate, 'YData', newyd);
    end
else
    for i=1:numel(handles.plots)
        set(handles.plots{i}.interpolate, 'YData', handles.NaN_data);
    end;
end;
% --------------------------------------------------------------------
function UpdateEpochList
handles = guidata(gca);

% we work with plot 1 only because epochs are for all plots the same
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
epochs = handles.epochs;
xd = handles.x_data;

% add epochs if necessary
for i=1:size(ep,2)
    response_plots = cell(numel(handles.plots),1);
    k = 1;
    epochFound = false;
    while ~epochFound && k <= numel(epochs)
        if epochs{k}.range == xd(ep(1:2, i))
            epochFound = true;
        end;
        k = k+1;
    end;
            
    % add epoch if not found
    if ~epochFound 
        hold on;
        for j=1:numel(handles.plots)
            
            yd = handles.NaN_data;
            yd(ep(1,i):ep(2,i)) = handles.plots{j}.y_data(ep(1,i):ep(2,i));
            
            p = plot(xd, yd, 'Color', 'green', 'Parent', handles.plots{j}.sel_container);
            response_plots{j} = struct('p', p);
        end;
        hold off;
        
        epochs{numel(epochs) + 1} = struct( ...
            'name', sprintf('%d-%d', xd(ep(1,i)), xd(ep(2,i))) , ...
            'range', xd(ep(1:2, i)), ...
            'highlighted', false, ...
            'response_plots', {response_plots} ...
            );
    end;
end;

% remove epochs if necessary
if numel(epochs) ~= size(ep,2)
    i = 1;
    while i <= numel(epochs)
        epochFound = false;
        k = 1;
        while ~epochFound && k <= size(ep,2)
            if epochs{i}.range == xd(ep(1:2, k))
                epochFound = true;
            end;
            k = k+1;
        end;
        
        if ~epochFound
            for j=1:numel(epochs{i}.response_plots)
                delete(epochs{i}.response_plots{j}.p);
            end;
            epochs(i) = [];
        else
            i = i+1;
        end;
    end;
end;

names = cellfun(@(x) x.name, epochs, 'UniformOutput', 0);
sel_ep = get(handles.lbEpochs, 'Value');
if sel_ep > numel(names)
    sel_ep = numel(names);
    set(handles.lbEpochs, 'Value', sel_ep);
elseif (sel_ep == 0) && (numel(names) > 0)
    sel_ep = 1;
    handles.highlighted_epoch = -1;
    set(handles.lbEpochs, 'Value', sel_ep);
end;
set(handles.lbEpochs, 'String', names);

handles.epochs = epochs;
guidata(gca, handles);

InterpolateData;


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
set(handles.tlRemoveEpoch, 'State', 'off');
set(handles.tlZoomin, 'State', 'off');
set(handles.tlZoomout, 'State', 'off');
set(handles.tlAddEpoch, 'State', 'off');
zoom off;
pan on;


% --------------------------------------------------------------------
function tlZoomout_OnCallback(hObject, eventdata, handles)
% hObject    handle to tlZoomout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.tlRemoveEpoch, 'State', 'off');
set(handles.tlZoomin, 'State', 'off');
set(handles.tlAddEpoch, 'State', 'off');
set(handles.tlNavigate, 'State', 'off');
pan off;

z = zoom;
set(z, 'Motion', 'horizontal');
set(z, 'Direction', 'out');
set(z, 'Enable', 'on');


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


% --- Executes on button press in pbOk.
function pbOk_Callback(hObject, eventdata, handles)
% hObject    handle to pbOk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch handles.output_type
    case 'interpolate'
        interp = cellfun(@(x) get(x.interpolate, 'YData'), handles.plots, 'UniformOutput', 0);
        handles.output = interp;
    case 'epochs'
        ep = cellfun(@(x) x.range, handles.epochs, 'UniformOutput', 0);
        handles.output = ep;
    otherwise 
        handles.output = {};
end;
        
guidata(gca, handles);
uiresume(handles.fgDataEditor);


% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = {};
guidata(gca, handles);
uiresume(handles.fgDataEditor);


% --- Executes on button press in cbInterpolate.
function cbInterpolate_Callback(hObject, eventdata, handles)
% hObject    handle to cbInterpolate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbInterpolate
InterpolateData;

% --- Executes on selection change in ppOutput.
function ppOutput_Callback(hObject, eventdata, handles)
% hObject    handle to ppOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ppOutput contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppOutput

output_type = get(hObject,'Value');

switch output_type
    case 1
        set(handles.cbInterpolate, 'Enable', 'on');
        handles.output_type = 'interpolate';
    case 2
        set(handles.cbInterpolate, 'Enable', 'off');
        handles.output_type = 'epochs';
end;
guidata(hObject, handles);
InterpolateData;


% --- Executes during object creation, after setting all properties.
function ppOutput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close fgDataEditor.
function fgDataEditor_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to fgDataEditor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
handles.output = {};
uiresume(handles.fgDataEditor);
