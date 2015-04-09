% create appropriate contrasts for DCM cond option

function varargout = scr_contrast(varargin)
% SCR_CONTRAST MATLAB code for scr_contrast.fig
%      SCR_CONTRAST, by itself, creates a new SCR_CONTRAST or raises the existing
%      singleton*.
%
%      H = SCR_CONTRAST returns the handle to a new SCR_CONTRAST or the handle to
%      the existing singleton*.
%
%      SCR_CONTRAST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCR_CONTRAST.M with the given input arguments.
%
%      SCR_CONTRAST('Property','Value',...) creates a new SCR_CONTRAST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before scr_contrast_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to scr_contrast_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help scr_contrast

% Last Modified by GUIDE v2.5 09-Apr-2015 08:53:23
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_contrast.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
% -------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @scr_contrast_OpeningFcn, ...
    'gui_OutputFcn',  @scr_contrast_OutputFcn, ...
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


% --- Executes just before scr_contrast is made visible.
function scr_contrast_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scr_contrast (see VARARGIN)

% Left alignment of text fields
set(handles.textStatus,'HorizontalAlignment','left')
set(handles.editContrastName,'HorizontalAlignment','left')

set(handles.textStatus,'String','Select a model...');

handles.listNamesValues = 1;

handles.colorString = {'red', 'green', 'fuchsia'};

handles.contrastCnt = 0;
handles.currentContrast = 1;

handles.contrastNamesString = [];

handles.enableGroupButtons = false;

% Choose default command line output for scr_contrast
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes scr_contrast wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = scr_contrast_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listNames.
function listNames_Callback(hObject, eventdata, handles)
% hObject    handle to listNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listNames contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listNames
listValue = get(handles.listNames, 'Value');
radioGroupValue = getGroupValue(handles);
contrastVal = find(handles.conArray{handles.currentContrast}.contrasts(:,listValue));
if isempty(contrastVal)
    handles.conArray{handles.currentContrast}.contrasts(radioGroupValue,listValue) = 1;
elseif contrastVal == radioGroupValue
    handles.conArray{handles.currentContrast}.contrasts(radioGroupValue,listValue) = ~handles.conArray{handles.currentContrast}.contrasts(radioGroupValue,listValue);
end

contrastVal = find(handles.conArray{handles.currentContrast}.contrasts(:,listValue));
if isempty(contrastVal)
    handles.conArray{handles.currentContrast}.namesString{listValue} = handles.names{listValue};
else
    handles.conArray{handles.currentContrast}.namesString{listValue} = sprintf('<HTML><FONT bgcolor="%s">%s</Font></html>',handles.colorString{contrastVal},handles.names{listValue});
end

set(handles.listNames,'String',handles.conArray{handles.currentContrast}.namesString);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function listNames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonLoadModel.
function buttonLoadModel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filt='.*\.mat$';
[modelfile, sts]=spm_select(1, filt, 'Select model file');
if sts==0, return; end;

handles.modelfile = modelfile;

% Init
handles.conArray = [];
handles.contrastCnt = 0;
handles.currentContrast = 1;
handles.contrastNamesString = [];
handles.names = [];
set(handles.listNames, 'String', handles.names);
set(handles.listNames, 'Value', 1);
set(handles.listNames,'Enable','off');
set(handles.listContrastNames,'String',handles.contrastNamesString);
set(handles.listContrastNames, 'Value', 1);
set(handles.listContrastNames,'Enable','off');
set(handles.buttonNewContrast,'Enable','off');
set(handles.buttonDeleteContrast,'Enable','off');
set(handles.buttonRun,'Enable','off');
set(handles.buttonClearCon,'Enable','off');
set(handles.checkboxDeleteCon,'Enable','off');
disableButtonGroups(handles)
handles.enableGroupButtons = false;

guidata(hObject, handles);

% check model file
set(handles.textStatus,'String','Loading model. Please wait...');
drawnow
[sts, model, modeltype] = scr_load1(modelfile, 'all', 'any');
if sts == -1 || ~any(strcmp(modeltype,{'glm','dcm','sf'}))
    set(handles.textStatus,'String','No modeltype detected');
    drawnow
    return;
elseif strcmp(modeltype,'sf')
    if ~isfield(model,'dcm')
        set(handles.textStatus,'String','No supported modeltype detected');
        drawnow
        return;
    end
end
set(handles.buttonNewContrast,'Enable','on');
set(handles.checkboxDeleteCon,'Enable','on');
set(handles.checkboxDeleteCon,'Value',0);
% detect model
switch modeltype
    case 'glm'
        set(handles.textStatus,'String','Detected modeltype: GLM');
        drawnow
        handles.paramnames = model.names;
        handles.condnames = {};
        % get condition names, code borrowed from scr_glm_recon
        regno = (numel(model.names) - model.interceptno)/model.bf.bfno;
        for k = 1:regno
            foobar = model.names{((k - 1) * model.bf.bfno + 1)};
            foo = strfind(foobar, ', bf');
            handles.condnames{k} = foobar(1:(foo-1));
            clear foo foobar
        end;

    case 'dcm'
        set(handles.textStatus,'String','Detected modeltype: DCM')
        drawnow
        handles.paramnames = model.trlnames;
        handles.condnames = model.condnames;
    case 'sf'
        set(handles.textStatus,'String','Detected modeltype: SF')
        drawnow
        handles.paramnames = model.trlnames;
end

handles.names = handles.paramnames;
handles.modeltype = modeltype;
set(handles.listNames, 'String', handles.names);
setTestGroupValue(handles, 1)
guidata(hObject, handles);


% --- Executes on button press in buttonClearCon.
function buttonClearCon_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClearCon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = clearNamesColor(handles);
guidata(hObject, handles);



% --- Executes on button press in buttonExit.
function buttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcbf)

% --- Executes when selected object is changed in panelTestDef.
function panelTestDef_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panelTestDef
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

testGroupVal = getTestGroupValue(handles);
setContrastGroup(handles, testGroupVal);
if testGroupVal ~= handles.conArray{handles.currentContrast}.testGroupVal
    handles = clearNamesColor(handles);
end
handles.conArray{handles.currentContrast}.testGroupVal = testGroupVal;

guidata(hObject, handles);

% --- Executes when selected object is changed in panelStatsType.
function panelStatstype_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panelTestDef
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

% get current stats type and assign names --
testStatstype = getStatsTypeValue(handles);
if testStatstype == 1 || testStatstype == 4
    handles.names = handles.paramnames;
else
    handles.names = handles.condnames;
end;
set(handles.listNames, 'String', handles.names);

% assign stats type to contrast and initialise contrast vector --
handles.conArray{handles.contrastCnt}.statstype = testStatstype;
handles.conArray{handles.contrastCnt}.contrasts = zeros(3,numel(handles.names));

guidata(hObject, handles);


% --- Executes on selection change in listContrastNames.
function listContrastNames_Callback(hObject, eventdata, handles)
% hObject    handle to listContrastNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listContrastNames contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listContrastNames
entryNr = get(handles.listContrastNames,'Value');
handles.currentContrast = entryNr;
set(handles.listNames,'String',handles.conArray{handles.currentContrast}.namesString);
setTestGroupValue(handles, handles.conArray{handles.currentContrast}.testGroupVal);
setContrastGroup(handles, handles.conArray{handles.currentContrast}.testGroupVal)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listContrastNames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listContrastNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonNewContrast.
function buttonNewContrast_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNewContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.contrastCnt = handles.contrastCnt + 1;
handles.currentContrast = handles.contrastCnt;

handles.conArray{handles.contrastCnt}.namesString = handles.names;
handles.conArray{handles.contrastCnt}.contrasts = zeros(3,numel(handles.names));
handles.conArray{handles.contrastCnt}.testGroupVal = getTestGroupValue(handles);
handles.conArray{handles.contrastCnt}.statstype = getStatsTypeValue(handles);

contrastName = get(handles.editContrastName,'String');
if isempty(contrastName)
    handles.contrastNamesString{handles.currentContrast} = ' ';
else
    handles.contrastNamesString{handles.currentContrast} = contrastName;
end
set(handles.listContrastNames,'String',handles.contrastNamesString);
set(handles.listContrastNames,'Value',handles.currentContrast);
set(handles.listNames,'String',handles.conArray{handles.currentContrast}.namesString);

if handles.enableGroupButtons == false
    set(handles.listNames,'Enable','on');
    enableButtonGroups(handles)
    set(handles.buttonRun,'Enable','on');
    set(handles.buttonClearCon,'Enable','on');
    set(handles.listContrastNames,'Enable','on');
    handles.enableGroupButtons = true;
end

if handles.contrastCnt > 1
    set(handles.buttonDeleteContrast, 'Enable', 'on');
end

guidata(hObject, handles);



function editContrastName_Callback(hObject, eventdata, handles)
% hObject    handle to editContrastName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editContrastName as text
%        str2double(get(hObject,'String')) returns contents of editContrastName as a double


% --- Executes during object creation, after setting all properties.
function editContrastName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editContrastName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonDeleteContrast.
function buttonDeleteContrast_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDeleteContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.conArray{handles.currentContrast} = [];
handles.conArray(cellfun('isempty',handles.conArray)) = [];
handles.contrastNamesString{handles.currentContrast} = [];
handles.contrastNamesString(cellfun('isempty',handles.contrastNamesString)) = [];
handles.contrastCnt = handles.contrastCnt - 1;
if handles.currentContrast > handles.contrastCnt
    handles.currentContrast = handles.contrastCnt;
end
set(handles.listContrastNames, 'Value', handles.currentContrast);
set(handles.listContrastNames, 'String', handles.contrastNamesString);
set(handles.listNames, 'String', handles.conArray{handles.currentContrast}.namesString);
setTestGroupValue(handles, handles.conArray{handles.currentContrast}.testGroupVal);
setContrastGroup(handles, handles.conArray{handles.currentContrast}.testGroupVal)

if handles.contrastCnt < 2
    set(handles.buttonDeleteContrast, 'Enable', 'off');
end

guidata(hObject, handles);

% --- Executes on selection change in popupDatatype.
function popupDatatype_Callback(hObject, eventdata, handles)
% hObject    handle to popupDatatype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupDatatype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupDatatype


% --- Executes during object creation, after setting all properties.
function popupDatatype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupDatatype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkboxDeleteCon.
function checkboxDeleteCon_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDeleteCon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxDeleteCon

% --- Executes on button press in buttonRun.
function buttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i=1:numel(handles.conArray)
    norm1 = sum(handles.conArray{i}.contrasts(1,:));
    if norm1 == 0
        norm1 = 1;
    end
    norm2 = sum(handles.conArray{i}.contrasts(2,:));
    if norm2 == 0
        norm2 = 1;
    end
    norm3 = sum(handles.conArray{i}.contrasts(3,:));
    if norm3 == 0
        norm3 = 1;
    end
    
    switch handles.conArray{i}.testGroupVal
        case 1
            conVec{i} = handles.conArray{i}.contrasts(1,:)/norm1;
            
        case 2
            conVec{i} = handles.conArray{i}.contrasts(1,:)/norm1 - handles.conArray{i}.contrasts(2,:)/norm2;
            
        case 3
            conVec{i} = handles.conArray{i}.contrasts(1,:)/norm1 - 2*handles.conArray{i}.contrasts(2,:)/norm2 + handles.conArray{i}.contrasts(3,:)/norm3;
    end
end

deletecon = get(handles.checkboxDeleteCon,'Value');
datatype = {'param', 'cond', 'recon', 'zscored'};
datatype = datatype{handles.conArray{i}.statstype};
scr_con1(handles.modelfile, handles.contrastNamesString, conVec, datatype, deletecon);

%--------------------------------------------------------------------------
% Functions
%--------------------------------------------------------------------------
function val = getGroupValue(handles)
val(1) = get(handles.radioGroup1,'Value');
val(2) = get(handles.radioGroup2,'Value');
val(3) = get(handles.radioGroup3,'Value');
val = find(val);

function val = getTestGroupValue(handles)
val(1) = get(handles.radioIntercept,'Value');
val(2) = get(handles.radioCondDiff,'Value');
val(3) = get(handles.radioQuadEffects,'Value');
val = find(val);

function val = getStatsTypeValue(handles)
val(1) = get(handles.radioParam,'Value');
val(2) = get(handles.radioCond,'Value');
val(3) = get(handles.radioRecon,'Value');
val(4) = get(handles.radioZscored,'Value');
val = find(val);

function setTestGroupValue(handles, val)
switch val
    case 1
        set(handles.radioIntercept,'Value',1);
    case 2
        set(handles.radioCondDiff,'Value',1);
    case 3
        set(handles.radioQuadEffects,'Value',1);
end


function handles = clearNamesColor(handles)
handles.conArray{handles.currentContrast}.namesString = handles.names;
handles.conArray{handles.currentContrast}.contrasts = zeros(size(handles.conArray{handles.currentContrast}.contrasts));
set(handles.listNames,'String',handles.conArray{handles.currentContrast}.namesString);

function setContrastGroup(handles, nr)
set(handles.radioGroup1,'Enable','on');
set(handles.radioGroup1,'Value',1);
if nr > 1
    set(handles.radioGroup2,'Enable','on');
    set(handles.radioGroup2,'String',sprintf('<HTML><FONT bgcolor="%s">%s</Font></html>',handles.colorString{2},'Group 2'));
else
    set(handles.radioGroup2,'Enable','off');
    set(handles.radioGroup2,'String','Group 2');
end
if nr > 2
    set(handles.radioGroup3,'Enable','on');
    set(handles.radioGroup3,'String',sprintf('<HTML><FONT bgcolor="%s">%s</Font></html>',handles.colorString{3},'Group 3'));
else
    set(handles.radioGroup3,'Enable','off');
    set(handles.radioGroup3,'String','Group 3');
end


function disableButtonGroups(handles)
set(handles.radioGroup1,'Enable','off');
set(handles.radioGroup2,'Enable','off');
set(handles.radioGroup3,'Enable','off');
set(handles.radioGroup1,'String','Group 1');
set(handles.radioGroup2,'String','Group 2');
set(handles.radioGroup3,'String','Group 3');

set(handles.radioIntercept,'Enable','off');
set(handles.radioCondDiff,'Enable','off');
set(handles.radioQuadEffects,'Enable','off');

set(handles.radioParam,'Enable','off');
set(handles.radioCond,'Enable','off');
set(handles.radioRecon,'Enable','off');
set(handles.radioZscored, 'Enable', 'off');


function enableButtonGroups(handles)
set(handles.radioGroup1,'Enable','on');
set(handles.radioGroup1,'Value',1);
set(handles.radioGroup1,'String',sprintf('<HTML><FONT bgcolor="%s">%s</Font></html>',handles.colorString{1},'Group 1'));

set(handles.radioIntercept,'Enable','on');
set(handles.radioIntercept,'Value',1);
set(handles.radioCondDiff,'Enable','on');
set(handles.radioQuadEffects,'Enable','on');

set(handles.radioParam,'Enable','on');
set(handles.radioParam,'Value',1);
if ~strcmpi(handles.modeltype, 'sf')
    set(handles.radioCond,'Enable','on');
end;
if strcmpi(handles.modeltype, 'glm')
    set(handles.radioRecon,'Enable','on');
end;
if strcmpi(handles.modeltype, 'dcm')
    set(handles.radioZscored,'Enable', 'on');
end;
