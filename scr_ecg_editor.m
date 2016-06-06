function varargout = scr_ecg_editor(varargin)
%
% scr_ecg_edtior allows manual correction of ecg data and creates a hb output. 
% Function can be called seperately.
%
%   INPUT:
%       [sts, R] = scr_ecg_editor(pt)
%       [sts, R] = scr_ecg_editor(fn, chan, options)
%
%       pt:         A struct() from scr_ecg2hb detection.
%       fn:         A file to  data file containing the ecg channel to be
%                   edited
%       chan:       Channel id of ecg channel in the data file
%       options:    A struct() of options
%           hb:         Channel id of the existing hb channel
%           semi:       Defines whether to navigate between potentially
%                       wrong hb events only (semi = 1), or between all
%                       hb events (semi = 0 => manual mode)
%           artifact:   Epoch file with epochs of artifacts (to be ignored)
%           factor:     To what factor should potentially wrong hb events
%                       deviate from the standard deviation. (Default: 1)
%       
%
%   variable r
%       r(1,:) ... original r vector
%       r(2,:) ... r vector containing potential faulty labeled qrs compl.
%       r(3,:) ... removed
%       r(4,:) ... added
%__________________________________________________________________________
% PsPM 3.1
% (C) 2013-2016 Philipp C Paulus, Tobias Moser
% (Dresden University of Technology, University of Zurich)

% $Id$   
% $Rev$

% Last Modified by GUIDE v2.5 06-Jun-2016 15:36:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @scr_ecg_editor_OpeningFcn, ...
    'gui_OutputFcn',  @scr_ecg_editor_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1}) && ... 
        (numel(regexp(varargin{1}, [filesep])) == 0)
        gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before scr_ecg2hb_qc is made visible.
function scr_ecg_editor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scr_ecg2hb_qc (see VARARGIN)

% Choose default command line output for scr_ecg2hb_qc
handles.output = hObject;
% -------------------------------------------------------------------------
% set default status for GUI
handles.edit_mode = '';
handles.gui_mode = '';
handles.hb_chan = -1;
handles.data_chan = -1;
handles.write_chan = -1;
handles.fn = '';
handles.action=[];
handles.k=1;        % counter for the potential mislabeled qrs complexes
handles.s=[];
handles.e=0;        % flag for the status of the ecg plot.
handles.sts=[];       % outputvariable
handles.R=[];
handles.jo=0;       % default value for jump only - 0; plot data!
handles.artifact_fn = '';
handles.artifact_epochs = [];
set(handles.togg_add,'Value',0);
set(handles.togg_remove,'Value',0);
% settings for manual mode
handles.manualmode=0;       % default: deactivated
handles.winsize=4;          % winsize for the manual mode
handles.data = {};
% define filter properties (copied from scr_ecg2hb)
handles.filt = struct();
handles.filt.sr=0; % to be set
handles.filt.lpfreq=15;
handles.filt.lporder=1;
handles.filt.hpfreq=5;
handles.filt.hporder=1;
handles.filt.direction='uni';
handles.filt.down=200;
% -------------------------------------------------------------------------
% set color values
handles.clr{1}=[.0627 .3059 .5451]; % blue for ecg plot
handles.clr{2}=[0 .75 1]; % skyblue for correct ones
handles.clr{3}=[1 .6471 0]; % dark yellow for possibly wrong ones
handles.clr{4}=[.5412 .1686 .8863]; % violet for deleted ones
handles.clr{5}=[0 .3922 0]; % darkgreen for added ones
% -------------------------------------------------------------------------
guidata(hObject,handles);
% parse input
if numel(varargin) == 0 || ~isstruct(varargin{1})
    handles.gui_mode = 'file';
    handles.hb_chan = -1;
    if numel(varargin) > 2
        handles.options = varargin{3};
    else
        handles.options = struct();
    end;
    if isfield(handles.options, 'hb')
        handles.hb_chan = handles.options.hb;
    end;
    if isfield(handles.options, 'semi')
        set(handles.cbManualMode, 'Value', ~handles.options.semi);
    end;
    if isfield(handles.options, 'artifact')
        set(handles.cbArtifactEpochs, 'Value', 1);
        load_data_artifacts(hObject, handles, handles.options.artifact);
        handles = guidata(hObject);
    end;
    if numel(varargin) ~= 0
        if numel(varargin) >= 2
            handles.data_chan = varargin{2};
        end;
        load_data_file(hObject, handles, varargin{1});
        % update handles
        handles = guidata(hObject);
    end;
else
    handles.data = varargin{1};
    handles.gui_mode = 'inline';
end;

reload_plot(hObject, handles);
handles = guidata(hObject);
% -------------------------------------------------------------------------
if strcmpi(handles.gui_mode, 'file')
    set(handles.pnlFileIO, 'visible', 'on');
else
    set(handles.pnlFileIO, 'visible', 'off');
end;
% -------------------------------------------------------------------------
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes scr_ecg2hb_qc wait for user response (see UIRESUME)
uiwait(handles.figure1);
% -------------------------------------------------------------------------

% --- Outputs from this function are returned to the command line.
function varargout = scr_ecg_editor_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
handles=guidata(hObject);
if not(isempty(handles.sts))
    varargout{1} = handles.sts;
else
    varargout{1} = -1;
end
% -------------------------------------------------------------------------
    if varargout{1} == -1
        varargout{2} = [];
    elseif not(isempty(handles.R))
        if strcmpi(handles.gui_mode, 'inline')
            varargout{2} = handles.R;
        else
            varargout{2} = handles.write_chan;
        end;
    else
        varargout{2} = [];
    end;
delete(hObject);
% -------------------------------------------------------------------------

% --- Executes on button press in togg_add.
function togg_add_Callback(hObject, eventdata, handles)
% hObject    handle to togg_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of togg_add
pan off;
set(handles.togg_remove,'Value',0)
if strcmpi(handles.edit_mode, 'add_qrs')
    exitModus;
else
    handles.edit_mode = 'add_qrs';
    set(handles.figure1,'Pointer','crosshair');
    guidata(hObject, handles);
end;


% --- Executes on button press in togg_remove.
function togg_remove_Callback(hObject, eventdata, handles)
% hObject    handle to togg_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togg_remove
% -------------------------------------------------------------------------
pan off;
if strcmpi(handles.edit_mode, 'remove_qrs')
    exitModus;
else
    handles.edit_mode = 'remove_qrs';
    set(handles.figure1,'Pointer','crosshair');
    guidata(hObject, handles);
end;
% -------------------------------------------------------------------------


% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exitModus;
handles.sts=-1;
handles.R=[];
% Update handles structure
guidata(hObject,handles);
% -------------------------------------------------------------------------
uiresume
% delete(hObject);


% --- Executes on button press in push_next.
function push_next_Callback(hObject, eventdata, handles)
% hObject    handle to push_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% -------------------------------------------------------------------------
exitModus;
if ~handles.manualmode
    handles.k=handles.k+1;
    % disable next button if out of bounds.
    if handles.k==handles.maxk
        set(handles.push_next,'enable','off')
    end
else % manual mode
    handles.count=handles.count+(handles.winsize-handles.winsize/4);
    % disable next button if out of bounds.
    if handles.count + (handles.winsize-handles.winsize/4) >= length(handles.plot.r)/handles.plot.sr
        set(handles.push_next,'enable','off')
    end
end
% enable "back"
if strcmp(get(handles.push_last,'enable'),'off')
    set(handles.push_last,'enable','on')
end
handles.jo=1;   % no changes were done. jump only.
% update guidata
guidata(hObject,handles)
% call pp_plot
pp_plot(hObject,handles)




% --- Executes on button press in push_last.
function push_last_Callback(hObject, eventdata, handles)
% hObject    handle to push_last (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% -------------------------------------------------------------------------
handles.edit_mode = '';
if ~handles.manualmode
    handles.k=handles.k-1;
    if handles.k==1
        set(handles.push_last,'enable','off')
    end
else % manual mode
    handles.count=handles.count-(handles.winsize-handles.winsize/4);
    if handles.count <= 0
        set(handles.push_last,'enable','off')
    end
end
% enable next
if strcmp(get(handles.push_next,'enable'),'off')
    set(handles.push_next,'enable','on')
end;
handles.jo=1;   % no changes were done. jump only.
% update guidata
guidata(hObject,handles)
% call pp_plot
pp_plot(hObject,handles)

% --- Executes on button press in push_done.
function push_done_Callback(hObject, eventdata, handles)
% hObject    handle to push_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
handles.edit_mode = '';
% -------------------------------------------------------------------------
r=handles.plot.r;
sr=handles.plot.sr;
r(1,r(3,:)==1)=NaN; % deleted QRS markers
r(1,r(4,:)==1)=1;   % added QRS markers
r(1,r(2,:)==1)=1;   % unchanged QRS markers

% remove artifact markers
if get(handles.cbArtifactEpochs, 'Value') ...
        && ~isempty(handles.artifact_epochs) && numel(r) > 0
    
    for i=1:length(handles.artifact_epochs)
        a_coord = handles.artifact_epochs(i, 1:end);
        r(1, round(a_coord(1)*sr):round(a_coord(2)*sr)) = NaN;
    end;
    
end;


handles.R=[];
handles.R=find(r(1,:)==1);
handles.sts=1;

% write channel accordingly
if strcmpi(handles.gui_mode, 'file') && numel(handles.R) > 0
    % assemble output settings
    output_settings = get(handles.rbAddChan, 'Value') + ...
        get(handles.rbReplaceEcgChan, 'Value')*2 + ...
        get(handles.rbReplaceHbChan, 'Value')*3;
    
    % prepare outputs
    out_d = struct();
    out_d.data = handles.R/sr;
    out_d.header = struct();
    out_d.header.chantype = 'hb';
    out_d.header.sr = 1;
    out_d.header.units = 'events';
    
    % transpose if necessary
    if max(size(out_d.data,1)) ~= length(out_d.data)
        out_d.data = out_d.data';
    end;
    
    switch output_settings
        case 1
            w_action = 'add';
            w_chan = 0;
        case 2
            w_action = 'replace';
            w_chan = handles.data_chan;
        case 3
            w_action = 'replace';
            w_chan = handles.hb_chan;
    end;
    op = struct('channel', w_chan);
    [nsts, infos] = scr_write_channel(handles.fn, out_d, w_action, op);
    
    if nsts ~= -1
        handles.write_chan = infos.channel;
    else
        warning('ID:invalid_input', 'Could not write channel.');
        handles.sts = nsts;
    end;
end;

guidata(hObject,handles);
uiresume
% -------------------------------------------------------------------------
% delete(hObject);

% --- plots the current segment
function pp_set(hObject,handles)
% -------------------------------------------------------------------------

if isstruct(handles.data)
    % header
    factr=handles.data.settings.outfact; % IBIs larger than mean(IBI)+(factr*std(IBI)) will
    % be marked for checking as well as IBIs smaller
    % than mean(IBI)-(factor*std(IBI))
    sr=handles.data.settings.filt.sr;
    % -------------------------------------------------------------------------
    % get data from handles struct
    r=handles.data.data.r';  % vector containing only zeros and ones where a QRS
    % complex was found
    R=handles.data.set.R;   % vector containing the timepoints of these QRS
    % QRS complexes
    ecg=handles.data.data.x(:,1)';
else
    data = handles.data{handles.data_chan};
    handles.manualmode = 1;
    handles.count = 0;

    if handles.hb_chan ~= -1
        hb = handles.data{handles.hb_chan}.data;
    else
        hb = {};
    end;
    if isfield(handles.options, 'factor')
        factr = handles.options.factor;
    else
        factr = 1;
    end;
    sr = data.header.sr;
    handles.filt.sr = sr;
    % filter data
    [nsts,ecg,sr]=scr_prepdata(data.data, handles.filt);
    if nsts == -1
        warning('Could not filter data, will use unfiltered data.');
        ecg = data.data;
    end;
    r = zeros(4,numel(ecg));
    if numel(hb) > 1
        R = round(hb*sr);
        r(1,R) = 1;
        handles.manualmode = get(handles.cbManualMode, 'Value');
    else
        R = [];
    end;
end;
% complexes
ibi=diff(R);            % duration of IBI intervalls
flag=zeros(size(ibi));  % flag variable to identify potential mislabeled

% -------------------------------------------------------------------------
% create vectors for potential mislabeled qrs complexes
flag(ibi>(mean(ibi)+(factr*std(ibi))))=1;   % too short
flag(ibi<(mean(ibi)-(factr*std(ibi))))=1;   % too long
flag(ibi/sr < 60/120)=1;                    % get all ibis > 120 bpm
flag(ibi/sr > 60/40)=1;                     % get all ibis < 40 bpm

% reset according to artifact epochs
if get(handles.cbArtifactEpochs, 'Value') && ...
        ~isempty(handles.artifact_epochs) && numel(R) > 0
    for i=1:length(handles.artifact_epochs)
        a_coord = handles.artifact_epochs(i, 1:end);
        flag((R(2:end) > a_coord(1)*sr) & (R(2:end) < a_coord(2)*sr)) = 0;
    end;
end;

maxk=length(find(flag==1));
r(2,R(flag==1))=1;
r(1,R(flag==1))=0;
r(r==0)=NaN;
r(3:4,:)=NaN;   % initialise for no qrs at this point and additional qrs at this point

y=1/sr:1/sr:length(r)/sr;
% -------------------------------------------------------------------------
% output.
handles.plot.R=R;
handles.plot.r=r;
handles.plot.ibi=ibi;
handles.plot.factr=factr;
handles.plot.y=y;
handles.plot.ecg=ecg;
handles.plot.sr=sr;
handles.filt.sr=sr;

% use self detected faulties
handles.faulty = find(flag);

%if exist('handles.maxk','var')==0 && exist('maxk','var')
handles.maxk=maxk;
%end
% Update handles structure
guidata(hObject,handles);

% --- plot data
function pp_plot(hObject,handles)

% where are potential mislabeled qrs complexes?
if any(not(isnan(handles.plot.r(2,:)))) && ~handles.manualmode
    count=handles.plot.R(handles.faulty(handles.k))/handles.plot.sr;
else
    count=handles.count;
end;
% -------------------------------------------------------------------------
if handles.jo==0 % check only if changes were done.
    % plot ecg signal
    if handles.e==0
        hold on;
        plot(handles.plot.y,handles.plot.ecg,'color',handles.clr{1})
        handles.e=1;
    end
    % -------------------------------------------------------------------------
    if not(isempty(handles.s))
        try
            delete(handles.s)
        end
    end
    % -------------------------------------------------------------------------
    for k=1:size(handles.plot.r,1)
        handles.s(k)=stem(handles.plot.y,handles.plot.r(k,:),'color',handles.clr{k+1});
        set(handles.s(k),'linewidth',2,'MarkerFaceColor',handles.clr{k+1})
        sbase=get(handles.s(k),'baseline');
        set(sbase,'BaseValue',min(handles.plot.ecg),'Visible','off');
    end
end
% -------------------------------------------------------------------------
if ~handles.manualmode
    xlim([count-2 count+2])
else
    xlim([count-(handles.winsize-handles.winsize/4) ...
        count+(handles.winsize-handles.winsize/4)])
end
xlabel('time in seconds [s]')
% -------------------------------------------------------------------------
handles.count=count; % set current position.

% Update handles structure
guidata(hObject,handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.sts=-1;
handles.R=[];
% Update handles structure
guidata(hObject,handles);
% -------------------------------------------------------------------------
uiresume
% Hint: delete(hObject) closes the figure
% delete(hObject);


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(eventdata.Key, 'escape')
    exitModus;
end;

% -------------------------------------------------------------------------
function exitModus()
handles = guidata(gca);
set(handles.figure1, 'Pointer', 'Arrow');
handles.edit_mode = '';
guidata(gca, handles);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pt = get(handles.axes, 'CurrentPoint');

switch handles.edit_mode
    case 'add_qrs'
        x = pt(1);
        % -----------------------------------------------------------------
        % click input
        x=round(x*handles.plot.sr);
        % -----------------------------------------------------------------
        % add qrs complex at position x and remove entry from r(2,x)
        handles.plot.r(4,x)=1;
        handles.plot.r(2,x)=NaN;
        handles.jo=0;   % changes were done, so set flag to 0
        % Update handles structure
        guidata(hObject,handles);
        % plot new
        pp_plot(hObject,handles);
        % -----------------------------------------------------------------
    case 'remove_qrs'        % click input
        x = pt(1);
        x=round(x*handles.plot.sr);
        % -----------------------------------------------------------------
        % add qrs complex at position x and remove entry from r(2,x)
        faulty=nansum(handles.plot.r,1);
        pos=find(faulty==1);
        [foo,ind]=min(abs(pos-x));
        b=pos(ind);
        % -----------------------------------------------------------------
        handles.plot.r(3,b)=1;
        handles.plot.r([1 2 4],b)=NaN;
        handles.jo=0;   % changes were done, so set flag to 0
        % Update handles structure
        guidata(hObject,handles);
        % plot new
        pp_plot(hObject,handles)
end;

% --- Executes on button press in zoomIn.
function zoomIn_Callback(hObject, eventdata, handles)
% hObject    handle to zoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xl = xlim();
xlim([xl(1)/2, xl(2)/2]);
handles.winsize = handles.winsize / 2;
guidata(hObject, handles);

% --- Executes on button press in zoomOut.
function zoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to zoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xl = xlim();
xlim([xl(1)*2, xl(2)*2]);
handles.winsize = handles.winsize * 2;
guidata(hObject, handles);

function edtDataFile_Callback(hObject, eventdata, handles)
% hObject    handle to edtDataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtDataFile as text
%        str2double(get(hObject,'String')) returns contents of edtDataFile as a double

set(hObject, 'String', handles.fn);

% --- Executes during object creation, after setting all properties.
function edtDataFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtDataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pbChangeFile.
function pbChangeFile_Callback(hObject, eventdata, handles)
% hObject    handle to pbChangeFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fname, fpath] = uigetfile({'*.mat'}, 'Select file with ECG data');
if ischar(fname) && ~isempty(fname)
    fn = fullfile(fpath, fname);
    load_data_file(hObject, handles, fn);
    handles = guidata(hObject);
    reload_plot(hObject, handles);
end;


% --- Executes on selection change in ppHbChan.
function ppHbChan_Callback(hObject, ~, handles)
% hObject    handle to ppHbChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ppHbChan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppHbChan

if ~isempty(handles.data)
    contents = cellstr(get(hObject,'String'));
    new_hb_chan = contents{get(hObject,'Value')};
    if strcmpi(new_hb_chan, 'None')
        handles.hb_chan = -1;
        set(handles.rbReplaceHbChan, 'Enable', 'off');
        set(handles.cbManualMode, 'Enable', 'off');
        set(handles.cbManualMode, 'Value', 1);
        
        if get(handles.rbReplaceHbChan, 'Value')
            set(handles.rbAddChan, 'Value', 1);
        end;
        
        handles.manualmode = 1;
    else
        handles.hb_chan = str2double(new_hb_chan);
        set(handles.rbReplaceHbChan, 'Enable', 'on');
        set(handles.cbManualMode, 'Enable', 'on');
        handles.manualmode = 1 && get(handles.cbManualMode, 'Value');
    end;
    
    reload_plot(hObject, handles);
end;

% --- Executes on selection change in ppEcgChan.
function ppEcgChan_Callback(hObject, ~, handles)
% hObject    handle to ppEcgChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ppEcgChan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppEcgChan

if ~isempty(handles.data)
    contents = cellstr(get(hObject,'String'));
    new_ecg_chan = contents{get(hObject,'Value')};
    handles.ecg_chan = str2double(new_ecg_chan);
    
    reload_plot(hObject, handles);
end;

% --- Executes during object creation, after setting all properties.
function ppEcgChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppEcgChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Load Data file 
function load_data_file(hObject, handles, fn)
    [ ~, ~, handles.data, ~] = scr_load_data(fn);
    ecg_chans = find(cellfun(@(x) strcmpi(x.header.chantype, 'ecg'), handles.data));
    % set possible ecg chans
    sel_ecg_chan = find(ecg_chans == handles.data_chan, 1, 'first');
    if isempty(sel_ecg_chan)
        sel_ecg_chan = 1;
    end;
    handles.data_chan = ecg_chans(sel_ecg_chan);
    set(handles.ppEcgChan, 'String', ecg_chans);
    set(handles.ppEcgChan, 'Value', sel_ecg_chan);
    
    hb_chans = find(cellfun(@(x) strcmpi(x.header.chantype, 'hb'), handles.data));
    hb_chan_list = cell(1,length(hb_chans)+1);
    hb_chan_list{1} = 'None';
    hb_chan_list(2:end) = num2cell(hb_chans);
    if handles.hb_chan == -1
        sel_hb_chan = 1;
        set(handles.cbManualMode, 'Enable', 'off');
    else
        sel_hb_chan = find(cell2mat(hb_chan_list(2:end)) == handles.hb_chan) + 1;
    end;
    
    set(handles.ppHbChan, 'String', hb_chan_list);
    set(handles.ppHbChan, 'Value', sel_hb_chan);
    
    handles.hb_chan = hb_chan_list(sel_hb_chan);
    if strcmpi(handles.hb_chan, 'None')
        handles.hb_chan = -1;
        set(handles.rbReplaceHbChan, 'Enable', 'off');
    end;
    
    handles.fn = fn;
    set(handles.edtDataFile, 'String', fn);
        
    guidata(hObject, handles);
    
% --- Reload plot settings
function reload_plot(hObject, handles)

if ~isempty(handles.data)
    % set values
    pp_set(hObject,handles);
    handles=guidata(hObject);
    % plot
    handles.jo = 0;
    pp_plot(hObject,handles);
    handles=guidata(hObject);    
    
    % check nex_prev button
    check_navigation_buttons(hObject, handles);
end;

% --- Check navigation buttons
function check_navigation_buttons(hObject, handles)
% activate buttons accordingly
if handles.maxk==1
    set(handles.push_next,'enable','off')
    set(handles.push_last,'enable','off')
else
    if ~handles.manualmode
        next = handles.k + 1;
        maximum = handles.maxk;
        prev = handles.k - 1;
    else
        next = handles.count + (handles.winsize-handles.winsize/4);
        maximum = length(handles.plot.r)/handles.plot.sr;
        prev = handles.count - (handles.winsize-handles.winsize/4);
    end;
    if  next >= maximum
        set(handles.push_next,'enable','off');
    else
        set(handles.push_last, 'enable', 'on');
    end;
    
    if prev <= 0
        set(handles.push_last, 'enable', 'off');
    else
        set(handles.push_last, 'enable', 'on');
    end;
end;


% --- Executes during object creation, after setting all properties.
function ppHbChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppHbChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbManualMode.
function cbManualMode_Callback(hObject, eventdata, handles)
% hObject    handle to cbManualMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbManualMode
handles.manualmode = get(hObject, 'Value');
% check nex_prev button
check_navigation_buttons(hObject, handles);
pp_plot(hObject, handles);



function edtArtifactFile_Callback(hObject, eventdata, handles)
% hObject    handle to edtArtifactFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtArtifactFile as text
%        str2double(get(hObject,'String')) returns contents of edtArtifactFile as a double

set(hObject, 'String', handles.artifact_fn);


% --- Executes during object creation, after setting all properties.
function edtArtifactFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtArtifactFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbArtifactFile.
function pbArtifactFile_Callback(hObject, eventdata, handles)
% hObject    handle to pbArtifactFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[fname, fpath] = uigetfile({'*.mat'}, 'Select file with Artifact epochs');
if ischar(fname) && ~isempty(fname)
    fn = fullfile(fpath, fname);
    load_data_artifacts(hObject, handles, fn);
    handles = guidata(hObject);
    reload_plot(hObject, handles);
end;

% --- Load artifact epochs file
function load_data_artifacts(hObject, handles, fn)
if exist(fn, 'file')
    try
        art_file = load(fn);
        if isfield(art_file, 'epochs')
            handles.artifact_epochs = art_file.epochs;
            handles.artifact_fn = fn;
            set(handles.edtArtifactFile, 'String', fn);
        else
            warning('ID:invalid_input', 'Not a valid artifact / epoch file provided.');
        end;
    catch
        warning('ID:invalid_input', 'Could not load artifact file.');
    end;
else
    warning('ID:invalid_input', 'Artifact file does not exist.');
end;
guidata(hObject, handles);


% --- Executes on button press in cbArtifactEpochs.
function cbArtifactEpochs_Callback(hObject, eventdata, handles)
% hObject    handle to cbArtifactEpochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbArtifactEpochs
if get(hObject, 'Value')
    set(handles.edtArtifactFile, 'Enable', 'on');
    set(handles.pbArtifactFile, 'Enable', 'on');
else
    set(handles.edtArtifactFile, 'Enable', 'off');
    set(handles.pbArtifactFile, 'Enable', 'off');
end;

if ~isempty(handles.artifact_epochs)
    reload_plot(hObject, handles);
end;
