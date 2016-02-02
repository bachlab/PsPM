function varargout = scr_data_editor(varargin)
% SCR_DATA_EDITOR MATLAB code for scr_data_editor.fig
%
% FORMAT: 
%   [varargout] = scr_data_editor(varargin)
%   [sts, outdata, outinfo] = scr_data_editor(indata, chan)
%
% DESCRIPTION: 
%
%
% INPUT:
%   varargin:       Can be multiple kinds of data types. In order to use
%                   scr_data_editor() to edit acquisition data, the actual
%                   data vector has to be passed via the varargin
%                   argmument. The data should be 1xn or nx1 double vector.
% OUTPUT:
%   varargout:      The output depends on the actual output type chosen in
%                   the graphical interface. At the moment either the
%                   interpolated data or epochs only can be chosen as
%                   output of the function.
%__________________________________________________________________________
% PsPM 3.1
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% Last Modified by GUIDE v2.5 02-Feb-2016 12:16:26

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

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;

if get(handles.rbInterpolate, 'Value') 
    set(handles.cbInterpolate, 'Enable', 'on');
    handles.output_type = 'interpolate';
else
    set(handles.cbInterpolate, 'Enable', 'off');
    handles.output_type = 'epochs';
end;

% Choose default command line output for scr_data_editor
handles.output = {};
handles.mode = 'default';
handles.select = struct();
handles.plots = {};
handles.selected_data = [];
handles.epochs = {};
handles.highlighted_epoch = -1;

handles.data = {};
handles.input_mode = '';
handles.input_file = '';
handles.output_file = '';
    
set(handles.fgDataEditor, 'WindowButtonDownFcn', @buttonDown_Callback);
set(handles.fgDataEditor, 'WindowButtonUpFcn', @buttonUp_Callback);
set(handles.fgDataEditor, 'WindowButtonMotionFcn', @buttonMotion_Callback);

% Update handles structure
guidata(hObject, handles);

if numel(varargin) > 0
    if ischar(varargin{1})
        if exist(varargin{1}, 'file')
            set(handles.pnlInput, 'Visible', 'on');
            set(handles.pnlOutput, 'Visible', 'on');
            
            loadFromFile(varargin{1});
        else
            warning('File ''%s'' does not exist.');
        end;
    elseif isnumeric(varargin{1})
        set(handles.pnlInput, 'Visible', 'off');
        set(handles.pnlOutput, 'Visible', 'off');
        
        handles.data = varargin{1};
        handles.input_mode = 'raw';
        guidata(hObject, handles);
        PlotData;
    end;
end;
uiwait(handles.fgDataEditor);

% --------------------------------------------------------------------
function [sts] = CreateOutput()

handles = guidata(gca);

sts = -1;
if strcmpi(handles.input_mode, 'file') && strcmpi(handles.output_file, '')
    msgbox('No output file specified. Cannot create output.','Error','error'); 
else
    out_file = handles.output_file;
    switch handles.output_type
        case 'interpolate'
            plots = ~cellfun(@isempty, handles.plots);
            interp = cellfun(@(x) get(x.interpolate, 'YData'), handles.plots(plots), 'UniformOutput', 0);
            
            if strcmpi(handles.input_mode, 'file')
                channels = find(plots);
                newchan = cell(numel(channels), 1);
                for i=1:numel(channels)
                    newchan{i} = handles.data{channels(i)};
                    newchan{i}.data = interp{i}';
                end;
                if exist(out_file, 'file')
                    overwrite = menu(sprintf('File (%s) already exists. Add channels?', out_file), 'yes', 'no');
                    if overwrite
                        scr_write_channel(out_file, newchan, 'add');
                    end;
                else
                    [sts, infos, data] = scr_load_data(out_file, newchan);
                end;
            else
                handles.output = interp;
            end;
            sts = 1;
        case 'epochs'
            ep = cellfun(@(x) x.range, handles.epochs, 'UniformOutput', 0);
            epochs = cell2mat(ep)';
            
            if strcmpi(handles.input_mode, 'file')
                if exist(out_file, 'file')
                    write_ok = menu(sprintf('File (%s) already exists. Overwrite?', out_file), 'yes', 'no');
                else
                    write_ok = true;
                end;
                
                if write_ok
                    save(out_file, 'epochs');
                end;
            else
                handles.output = epochs;
            end;
            sts = 1;
        otherwise
            handles.output = {};
            sts = 1;
    end;
end;

guidata(gca, handles);

% --------------------------------------------------------------------
function loadFromFile(file)
handles = guidata(gca);

% clear epochs
handles.selected_data(:) = NaN;
guidata(gca, handles);
UpdateEpochList;

% clear channels
handles.channels = {};
set(handles.lbChannel, 'String', '');

% remove plots
for i=1:numel(handles.plots)
    if ~isempty(handles.plots{i})
        RemovePlot(i);
    end;
end;

% load file
[sts, infos, data] = scr_load_data(file);
channels = cellfun(@(x) {x.header.chantype,x.header.units}, data, 'UniformOutput', 0);

set(handles.edOpenFilePath, 'String', file);

% format channels
corder = get(handles.fgDataEditor, 'defaultAxesColorOrder');
cl = length(corder)-2;
disp_names = cell(numel(channels), 1);
for i=1:numel(channels)
    if strcmpi(channels{i}(2), 'events')
        disp_names{i} = sprintf('<html><font color="#DDDDDD">%s</font></html>', channels{i}{1});
    else
        m = floor((i-0.1)/cl);
        color = corder(i - m*cl, :);
        disp_names{i} = sprintf('<html><font bgcolor="#%02s%02s%02s">%s</font></html>',...
            dec2hex(round(color(1)*255)), ...
            dec2hex(round(color(2)*255)), ...
            dec2hex(round(color(3)*255)), ...
            channels{i}{1});
    end;
end;

set(handles.lbChannel, 'String', disp_names);

handles.data = data;
handles.infos = infos;
handles.input_mode = 'file';
handles.plots = cell(size(data));
guidata(gca, handles);

PlotData;

% --------------------------------------------------------------------
function PlotData
handles = guidata(gca);
chan = {};
% load data
switch handles.input_mode
    case 'file'
        % get highest sample rate
        sr = max(cellfun(@(x) x.header.sr, handles.data));
        xdata = (0:sr^-1:handles.infos.duration)';
        chan_id = get(handles.lbChannel, 'Value');
        if ~any(numel(handles.data) < chan_id)
            chan = chan_id;
        else
            warning('Cannot plot selected channel(s).');
        end;
    case 'raw'
        xdata = (1:numel(handles.data))';
        chan = 1;
end;

handles.selected_data = NaN(numel(xdata),1);
handles.x_data = xdata;

guidata(gca, handles);

if ~isempty(chan)
    np = get(handles.axData, 'NextPlot');
    action = 'replace';
    for i=1:numel(chan)
        AddPlot(chan(i), action);
        action = 'add';
    end;   
    set(handles.axData, 'NextPlot', np);
end;

% --------------------------------------------------------------------
function AddPlot(chan_id, action)
handles = guidata(gca);

if isempty(action)
    action = 'replace';
end;

np = get(handles.axData, 'NextPlot');
set(handles.axData, 'NextPlot', action);
corder = get(handles.fgDataEditor, 'defaultAxesColorOrder');
cl = length(corder)-2;

m = floor((chan_id-0.1)/cl);
color = corder(chan_id - m*cl, :);
if strcmpi(handles.input_mode, 'file')
    sr = handles.data{chan_id}.header.sr;
    ydata = handles.data{chan_id}.data;
    xdata = (0:sr^-1:handles.infos.duration)';
    if numel(xdata) > numel(ydata)
        xdata = xdata(2:end);
    end;
else
    xdata = 1:numel(handles.data)';
    ydata = handles.data;
    sr = 1;
end;

p = plot(xdata,ydata, 'Color', color);
set(handles.axData, 'NextPlot', 'add');
NaN_data = NaN(numel(xdata),1);
handles.plots{chan_id}.sr = sr;
handles.plots{chan_id}.data_plot = p;
handles.plots{chan_id}.y_data = ydata;
handles.plots{chan_id}.x_data = xdata;
handles.plots{chan_id}.sel_container = hggroup;
handles.plots{chan_id}.highlight_plot = plot(xdata,NaN_data, 'LineWidth', 1.5, 'Color', corder(end,:));
handles.plots{chan_id}.interpolate = plot(xdata,NaN_data, 'LineWidth', 0.5, 'Color', corder(end-1,:), 'LineStyle', '--');
uistack(handles.plots{chan_id}.interpolate, 'bottom');

% add response plots
for i=1:numel(handles.epochs)
    rp_x = handles.plots{chan_id}.x_data;
    rp_y = NaN(1,numel(handles.plots{chan_id}.x_data));
    range = rp_x > handles.epochs{i}.range(1) & rp_x < handles.epochs{i}.range(2);
    rp_y(range) = handles.plots{chan_id}.y_data(range);
    
    p = plot(rp_x, rp_y, 'Color', 'green', 'Parent', handles.plots{chan_id}.sel_container);
    handles.epochs{i}.response_plots{chan_id} = struct('p', p);
end;

set(handles.axData, 'NextPlot', np);
guidata(gca, handles);


% --------------------------------------------------------------------
function RemovePlot(chan_id)
handles = guidata(gca);

if numel(handles.plots) >= chan_id
    
    % remove response plots
    for i=1:numel(handles.epochs)
        if numel(handles.epochs{i}.response_plots) >= chan_id ...
                && ~isempty(handles.epochs{i}.response_plots{chan_id})
            delete(handles.epochs{i}.response_plots{chan_id}.p);
            handles.epochs{i}.response_plots{chan_id} = [];
        end;
    end;
    
    delete(handles.plots{chan_id}.data_plot);
    delete(handles.plots{chan_id}.sel_container);
    delete(handles.plots{chan_id}.highlight_plot);
    delete(handles.plots{chan_id}.interpolate);
    % empty entry
    handles.plots{chan_id} = [];
end;

guidata(gca, handles);


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
            if ~isempty(handles.epochs{i}.response_plots{j})
                set(handles.epochs{i}.response_plots{j}.p, ...
                    'Color', 'green',  ...
                    'LineWidth',0.5 ...
                    );
            end;
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

% highlight epochs
for i=1:numel(ep.response_plots)
    if ~isempty(ep.response_plots{i})
        set(ep.response_plots{i}.p, 'Color', 'black', 'LineWidth', 1.5);
    end;
end;

cur_xlim = get(handles.axData, 'xlim');
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
elseif x_dist >= data_dist
    start = dstart;
    stop = dstop;
    set(handles.axData, 'xlim', [start,stop]);
end;

x_dist = stop - start;

% try to set ylim
plots = ~cellfun(@isempty, handles.plots);
minmax = cellfun(@(x) [max(x.y_data(x.x_data >= ep.range(1)& x.x_data <= ep.range(2))), ...
    max(x.y_data), min(x.y_data(x.x_data >= ep.range(1)& x.x_data <= ep.range(2))), min(x.y_data)], ... 
    handles.plots(plots), 'UniformOutput', false);
minmax = cell2mat(minmax);
to = max(minmax(:,1));
from = min(minmax(:,3));
dmax = max(minmax(:,2));
dmin = min(minmax(:,4));

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

if isfield(handles, 'mode')
    switch handles.mode
        case {'addepoch', 'removeepoch'}
            if isequal(handles.select.stop,[0,0]) && ...
                    ~isequal(handles.select.start,[0,0])
                drawSelection;
                SelectedArea('highlight');
            end;
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
    % turn highlight off
    for i=1:numel(handles.plots)
        p = handles.plots{i};
        if ~isempty(p)
            xd = p.x_data;
            highlight_yd = NaN(numel(xd),1);
            set(p.highlight_plot, 'YData', highlight_yd');
        end;
    end;
end;

if start(1) > stop(1)
    x_from = stop(1);
    x_to = start(1);
else
    x_from = start(1);
    x_to = stop(1);
end;


sel_x = handles.x_data;

switch action
    case 'add'
        handles.selected_data(sel_x >= x_from & sel_x <= x_to) = 1;
    case 'remove'
        handles.selected_data(sel_x >= x_from & sel_x <= x_to) = NaN;
    case 'highlight'
        for i=1:numel(handles.plots)
            p = handles.plots{i};
            if ~isempty(p)
                xd = p.x_data;
                yd = p.y_data;
                r = xd >= x_from & xd <= x_to;
                highlight_yd = NaN(numel(xd),1);
                highlight_yd(r) = yd(r);
                set(p.highlight_plot, 'YData', highlight_yd');
            end;
        end;
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
        if ~isempty(handles.plots{i})
            xd = handles.plots{i}.x_data;
            yd = handles.plots{i}.y_data;
            
            for j = 1:numel(handles.epochs)
                range = xd >= handles.epochs{j}.range(1) & xd <= handles.epochs{j}.range(2);
                yd(range) = NaN;
            end;
            [sts, newyd] = scr_interpolate(yd);
            set(handles.plots{i}.interpolate, 'YData', newyd);
        end;
    end
else
    for i=1:numel(handles.plots)
        if ~isempty(handles.plots{i})
            NaN_data = NaN(numel(handles.plots{i}.x_data),1);
            set(handles.plots{i}.interpolate, 'YData', NaN_data);
        end;
    end;
end;

% --------------------------------------------------------------------
function [epochs] = findSelectedEpochs()
handles = guidata(gca);

sd = handles.selected_data;
% find epochs in yd
v_pos = find(~isnan(sd));
xd = handles.x_data;
if numel(v_pos)>1
    epoch_end = xd([v_pos(find(diff(v_pos) > 1)); v_pos(end)]);
    epoch_start = xd(v_pos([1;find(diff(v_pos) > 1)+1]));
    
    epochs = [epoch_start, epoch_end];
else
    epochs = [];
end;
    
% --------------------------------------------------------------------
function UpdateEpochList
handles = guidata(gca);

if numel(handles.plots) > 0 
    ep = findSelectedEpochs;
    epochs = handles.epochs;
    
    % add epochs if necessary
    for i=1:size(ep,1)
        response_plots = cell(numel(handles.plots),1);
        k = 1;
        epochFound = false;
        while ~epochFound && k <= numel(epochs)
            if epochs{k}.range == ep(i,1:2)
                epochFound = true;
            end;
            k = k+1;
        end;
        
        % add epoch if not found
        if ~epochFound
            hold on;
            for j=1:numel(handles.plots)
                if ~isempty(handles.plots{j})
                    rp_y = NaN(1,numel(handles.plots{j}.x_data));
                    rp_x = handles.plots{j}.x_data;
                    sta = ep(i,1);
                    sto = ep(i,2);
                    r = rp_x >= sta & rp_x <= sto;
                    rp_y(r) = handles.plots{j}.y_data(r);
                    
                    
                    p = plot(rp_x, rp_y, 'Color', 'green', 'Parent', handles.plots{j}.sel_container);
                    response_plots{j} = struct('p', p, 'p_id', j);
                end;
            end;
            hold off;
            
            epochs{numel(epochs) + 1} = struct( ...
                'name', sprintf('%d-%d', ep(i,1), ep(i,2)) , ...
                'range', ep(i, 1:2), ...
                'highlighted', false, ...
                'response_plots', {response_plots} ...
                );
        end;
    end;
    
    % remove epochs if necessary
    if numel(epochs) ~= size(ep,1)
        i = 1;
        while i <= numel(epochs)
            epochFound = false;
            k = 1;
            while ~epochFound && k <= size(ep,1)
                if epochs{i}.range == ep(k, 1:2)
                    epochFound = true;
                end;
                k = k+1;
            end;
            
            if ~epochFound
                for j=1:numel(epochs{i}.response_plots)
                    if ~isempty(epochs{i}.response_plots{j})
                        delete(epochs{i}.response_plots{j}.p);
                    end;
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
end;


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


% --- Executes on button press in pbApply.
function pbApply_Callback(hObject, eventdata, handles)
% hObject    handle to pbApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if CreateOutput == 1
    uiresume(handles.fgDataEditor);
end;


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


% --- Executes on selection change in lbChannel.
function lbChannel_Callback(hObject, eventdata, handles)
% hObject    handle to lbChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbChannel

if strcmpi(handles.input_mode, 'file')
    plots = find(cellfun(@(x) ~isempty(x), handles.plots));
    sel = get(hObject, 'Value');
    to_plot = sel(~ismember(sel, plots));
    to_remove = plots(~ismember(plots, sel));
    
    for i=1:numel(to_remove)
        RemovePlot(to_remove(i));
    end;
    
    for i=1:numel(to_plot)
        if ~strcmpi(handles.data{to_plot(i)}.header.units, 'events')
            AddPlot(to_plot(i), 'add');
        end;
    end;
    InterpolateData;
end;

% --- Executes during object creation, after setting all properties.
function lbChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbEpochs.
function rbEpochs_Callback(hObject, eventdata, handles)
% hObject    handle to rbEpochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbEpochs


% --- Executes on button press in rbInterpolate.
function rbInterpolate_Callback(hObject, eventdata, handles)
% hObject    handle to rbInterpolate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbInterpolate


% --- Executes on button press in pbOpenInputFile.
function pbOpenInputFile_Callback(hObject, eventdata, handles)
% hObject    handle to pbOpenInputFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('*.mat', 'Select input file');
if file ~= 0
    fn = [path,file];
    handles.input_file = fn;
    guidata(hObject, handles);
    loadFromFile(fn);
end;

% --- Executes on button press in pbOpenOutputFile.
function pbOpenOutputFile_Callback(hObject, eventdata, handles)
% hObject    handle to pbOpenOutputFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uiputfile('*.mat', 'Select output file');
if file ~= 0
    fn = [path,file];
    handles.output_file = fn;
    guidata(hObject, handles);
    set(handles.edOutputFile, 'String', handles.output_file);
end;


function edOpenFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to edOpenFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOpenFilePath as text
%        str2double(get(hObject,'String')) returns contents of edOpenFilePath as a double
if isempty(handles.input_file)
    set(hObject, 'String', 'No input specified');
else
    set(hObject, 'String', handles.input_file);
end;



function edOutputFile_Callback(hObject, eventdata, handles)
% hObject    handle to edOutputFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOutputFile as text
%        str2double(get(hObject,'String')) returns contents of edOutputFile as a double
if isempty(handles.output_file)
    set(hObject, 'String', 'No output specified');
else
    set(hObject, 'String', handles.output_file);
end;

% --- Executes when selected object is changed in bgMode.
function bgMode_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bgMode 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.rbInterpolate, 'Value') 
    set(handles.cbInterpolate, 'Enable', 'on');
    handles.output_type = 'interpolate';
else
    set(handles.cbInterpolate, 'Enable', 'off');
    handles.output_type = 'epochs';
end;

guidata(hObject, handles);
InterpolateData;


% --- Executes on button press in pbSaveOutput.
function pbSaveOutput_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CreateOutput;
