function varargout = scr_ecg2hb_qc(varargin)
%
% scr_ecg2hb_qc allows manual correction of ecg2hb. Function can only be
% called from within scr_ecg2hb.
%
%   variable r
%       r(1,:) ... original r vector
%       r(2,:) ... r vector containing potential faulty labeled qrs compl.
%       r(3,:) ... removed
%       r(4,:) ... added
%__________________________________________________________________________
% PsPM 3.0
% (C) 2013-2015 Philipp C Paulus
% (Technische Universitaet Dresden, University of Zurich)

% $Id$   
% $Rev$

% Last Modified by GUIDE v2.5 29-Apr-2015 11:42:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @scr_ecg2hb_qc_OpeningFcn, ...
    'gui_OutputFcn',  @scr_ecg2hb_qc_OutputFcn, ...
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


% --- Executes just before scr_ecg2hb_qc is made visible.
function scr_ecg2hb_qc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scr_ecg2hb_qc (see VARARGIN)

% Choose default command line output for scr_ecg2hb_qc
handles.output = hObject;
% -------------------------------------------------------------------------
% set default status for GUI
handles.action=[];
handles.k=1;        % counter for the potential mislabeled qrs complexes
handles.s=[];
handles.e=0;        % flag for the status of the ecg plot.
handles.sts=[];       % outputvariable
handles.R=[];
handles.jo=0;       % default value for jump only - 0; plot data!
set(handles.togg_add,'Value',0)
set(handles.togg_remove,'Value',0)
% -------------------------------------------------------------------------
% set color values
handles.clr{1}=[.0627 .3059 .5451]; % blue for ecg plot
handles.clr{2}=[.25 .25 .25]; % grey for correct ones
handles.clr{3}=[1 .6471 0]; % dark yellow for possibly wrong ones
handles.clr{4}=[1 .2706 0]; % red for deleted ones
handles.clr{5}=[0 .3922 0]; % green for added ones
% -------------------------------------------------------------------------
guidata(hObject,handles);
% get input
handles.data=varargin{1};
% set values
pp_set(hObject,handles);
handles=guidata(hObject);
% plot
pp_plot(hObject,handles);
% -------------------------------------------------------------------------
% activate buttons accordingly
handles=guidata(hObject);
if handles.maxk==1
    set(handles.push_next,'enable','off')
    set(handles.push_last,'enable','off')
else set(handles.push_last,'enable','off')
end
% -------------------------------------------------------------------------
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes scr_ecg2hb_qc wait for user response (see UIRESUME)
uiwait(handles.figure1);
% -------------------------------------------------------------------------

% --- Outputs from this function are returned to the command line.
function varargout = scr_ecg2hb_qc_OutputFcn(hObject, eventdata, handles)
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
delete(handles.figure1);
% -------------------------------------------------------------------------

% --- Executes on button press in togg_add.
function togg_add_Callback(hObject, eventdata, handles)
% hObject    handle to togg_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of togg_add
set(handles.togg_remove,'Value',0)
% -------------------------------------------------------------------------
% click input
[x,foo]=ginput(1);
x=round(x*handles.plot.sr);
% -------------------------------------------------------------------------
% add qrs complex at position x and remove entry from r(2,x)
handles.plot.r(4,x)=1;
handles.plot.r(2,x)=NaN;
handles.jo=0;   % changes were done, so set flag to 0
% Update handles structure
guidata(hObject,handles);
% plot new
pp_plot(hObject,handles);
% -------------------------------------------------------------------------


% --- Executes on button press in togg_remove.
function togg_remove_Callback(hObject, eventdata, handles)
% hObject    handle to togg_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togg_remove
% -------------------------------------------------------------------------
% click input
[x,foo]=ginput(1);
x=round(x*handles.plot.sr);
% -------------------------------------------------------------------------
% add qrs complex at position x and remove entry from r(2,x)
faulty=nansum(handles.plot.r,1);
pos=find(faulty==1);
[foo,ind]=min(abs(pos-x));
b=pos(ind);
% -------------------------------------------------------------------------
handles.plot.r(3,b)=1;
handles.plot.r([1 2 4],b)=NaN;
handles.jo=0;   % changes were done, so set flag to 0
% Update handles structure
guidata(hObject,handles);
% plot new
pp_plot(hObject,handles)
% -------------------------------------------------------------------------


% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output.sts=-1;
handles.output.R=[];
% Update handles structure
guidata(hObject,handles);
% -------------------------------------------------------------------------
uiresume


% --- Executes on button press in push_next.
function push_next_Callback(hObject, eventdata, handles)
% hObject    handle to push_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% -------------------------------------------------------------------------
handles.k=handles.k+1;
if handles.k==handles.maxk
    set(handles.push_next,'enable','off')
end
% enable last
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
handles.k=handles.k-1;
if handles.k==1
    set(handles.push_last,'enable','off')
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

% --- plots the current segment
function pp_set(hObject,handles)
% -------------------------------------------------------------------------

% header
factr=3;                % IBIs larger than mean(IBI)+(factr*std(IBI)) will
% be marked for checking as well as IBIs smaller
% than mean(IBI)-(factor*std(IBI))
sr=handles.data.settings.filt.sr;
% -------------------------------------------------------------------------
% get data from handles struct
r=handles.data.data.r';  % vector containing only zeros and ones where a QRS
% complex was found
R=handles.data.set.R;   % vector containing the timepoints of these QRS
% complexes
ibi=diff(R);            % duration of IBI intervalls
flag=zeros(size(ibi));  % flag variable to identify potential mislabeled
% QRS complexes
ecg=handles.data.data.x(:,1)';
% -------------------------------------------------------------------------
% create vectors for potential mislabeled qrs complexes
flag(ibi>(mean(ibi)+(factr*std(ibi))))=1;   % too short
flag(ibi<(mean(ibi)-(factr*std(ibi))))=1;   % too long
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
handles.maxk=maxk;
handles.factr=factr;
% Update handles structure
guidata(hObject,handles);

% --- plot data
function pp_plot(hObject,handles)
% for development and bugtracing only.
if handles.k<1
    keyboard
end
% -------------------------------------------------------------------------
% where are potential mislabeled qrs complexes?
if any(not(isnan(handles.plot.r(2,:))))
    count=handles.plot.R(handles.data.faulty(handles.k))/handles.plot.sr;
else keyboard
end
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
        sbase=get(handles.s(k),'baseline');
        set(sbase,'BaseValue',min(handles.plot.ecg),'Visible','off');
    end
end
% -------------------------------------------------------------------------
xlim([count-2 count+2])
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

uiresume
% Hint: delete(hObject) closes the figure
delete(hObject);
