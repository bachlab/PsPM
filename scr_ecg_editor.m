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
%           artifact:   Epoch file with epochs of artifacts (to be ignored)
%           
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

% Last Modified by GUIDE v2.5 31-May-2016 11:09:04

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
handles.action=[];
handles.k=1;        % counter for the potential mislabeled qrs complexes
handles.s=[];
handles.e=0;        % flag for the status of the ecg plot.
handles.sts=[];       % outputvariable
handles.R=[];
handles.jo=0;       % default value for jump only - 0; plot data!
set(handles.togg_add,'Value',0);
set(handles.togg_remove,'Value',0);
% settings for manual mode
handles.manualmode=0;       % default: deactivated
handles.winsize=8;          % winsize for the manual mode
handles.data = {};
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
    if numel(varargin)~= 0
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
    varargout{2} = handles.R;
else varargout{2} = [];
end
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
if handles.manualmode==0
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
if handles.manualmode==0
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
end
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
r(1,r(3,:)==1)=NaN; % deleted QRS markers
r(1,r(4,:)==1)=1;   % added QRS markers
r(1,r(2,:)==1)=1;   % unchanged QRS markers

handles.R=[];
handles.R=find(r(1,:)==1);
handles.sts=1;
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
    ecg = data.data;
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
if any(not(isnan(handles.plot.r(2,:)))) && handles.manualmode==0
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
if handles.manualmode==0
    xlim([count-2 count+2])
else
    xlim([count-1 count+(handles.winsize-handles.winsize/4)])
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
if ~isempty(fname)
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
    
    % activate buttons accordingly
    if handles.maxk==1
        set(handles.push_next,'enable','off')
        set(handles.push_last,'enable','off')
    else
        set(handles.push_last,'enable','off')
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
guidata(hObject, handles);

% --- Executes on button press in cbFilterData.
function cbFilterData_Callback(hObject, eventdata, handles)
% hObject    handle to cbFilterData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbFilterData
