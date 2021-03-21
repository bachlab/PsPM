function varargout = pspm(varargin)
% PsPM is the main GUI for PsPM
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: pspm.m 636 2019-03-15 07:56:42Z lciernik $
% $Rev: 636 $ 

% this code was mainly produced by GUIDE
% PsPM_GUI M-file for PsPM_GUI.fig
%      PsPM_GUI, by itself, creates a new PsPM or raises the existing
%      singleton*.
%
%      H = pspm returns the handle to a new PsPM or the handle to
%      the existing singleton*.
%
%      PsPM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PsPM.M with the given input arguments.
%
%      PsPM('Property','Value',...) creates a new PsPM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PsPM_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PsPM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PsPM

% Last Modified by GUIDE v2.5 25-Jul-2016 17:05:55
% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;
% -------------------------------------------------------------------------
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PsPM_OpeningFcn, ...
                   'gui_OutputFcn',  @PsPM_OutputFcn, ...
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

% --- Executes just before PsPM is made visible.
function PsPM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PsPM (see VARARGIN)
pspm_init;
cfg_util('initcfg'); % This must be the first call to cfg_util
%cfg_ui('Visible','off'); % Create invisible batch ui

% Choose default command line output for PsPM
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PsPM wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PsPM_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PsPM.
function PsPM_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PsPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pspm_show_arms;

% --- Executes on button press in Import_data.
function Import_data_Callback(hObject, eventdata, handles)
% hObject    handle to Import_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% pspm_import_UI;
cfg_add_module('pspm.prep.import');


% --- Executes on button press in Trim_data.
function Trim_data_Callback(hObject, eventdata, handles)
% hObject    handle to Trim_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% pspm_trim_UI;
cfg_add_module('pspm.prep.trim');

% --- Executes on button press in dispdata.
function dispdata_Callback(hObject, eventdata, handles)
% hObject    handle to dispdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% pspm_disp;
cfg_add_module('pspm.tools.disp');

% --- Executes on button press in Export_data.
function Export_data_Callback(hObject, eventdata, handles)
% hObject    handle to Export_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% pspm_exp_UI;
cfg_add_module('pspm.first_level.export');

% --- Executes on button press in rev1.
function rev1_Callback(hObject, eventdata, handles)
% hObject    handle to rev1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%pspm_rev1_UI;
pspm_review;
% cfg_add_module('pspm.first_level.review');

% --- Executes on button press in con1.
function con1_Callback(hObject, eventdata, handles)
% hObject    handle to con1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% pspm_con1_UI;
pspm_contrast;
%cfg_add_module('pspm.first_level.contrast');

% --- Executes on button press in DCM.
function DCM_Callback(hObject, eventdata, handles)
% hObject    handle to DCM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% pspm_dcm_UI;
cfg_add_module('pspm.first_level.scr.dcm');

% --- Executes on button press in SF.
function SF_Callback(hObject, eventdata, handles)
% hObject    handle to SF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% pspm_sf_UI;
cfg_add_module('pspm.first_level.scr.sf');

% --- Executes on button press in rev2.
function rev2_Callback(hObject, eventdata, handles)
% hObject    handle to rev2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cfg_add_module('pspm.second_level.report');

% --- Executes on button press in con2.
function con2_Callback(hObject, eventdata, handles)
% hObject    handle to con2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% pspm_con2_UI;
cfg_add_module('pspm.second_level.contrast');


% --- Executes on button press in batch_pushbutton.
function batch_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to batch_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cfg_ui;

% --- Executes on button press in QuitGUI.
function QuitGUI_Callback(hObject, eventdata, handles)
% hObject    handle to QuitGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pspm_quit; return;


% --- Executes on selection change in Other_utils.
function Other_utils_Callback(hObject, eventdata, handles)
% hObject    handle to Other_utils (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Other_utils contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Other_utils
val = get(hObject,'Value');
switch val
    case 1
        pspm_display;
    case 2
        cfg_add_module('pspm.tools.rename');
    case 3
        cfg_add_module('pspm.tools.split_sessions');
    case 4
        cfg_add_module('pspm.tools.merge');
    case 5
        cfg_add_module('pspm.tools.artefact_rm');
    case 6
        cfg_add_module('pspm.tools.downsample');
    case 7
        cfg_add_module('pspm.tools.interpolate');
    case 8
        cfg_add_module('pspm.tools.extract_segments');
    case 9
        cfg_add_module('pspm.tools.segment_mean');
    case 10
        cfg_add_module('pspm.tools.extract_markerinfo');
    case 11
        pspm_data_editor();
    case 12
        cfg_add_module('pspm.tools.convert_data');
end;

% --- Executes during object creation, after setting all properties.
function Other_utils_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Other_utils (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function GLM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GLM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in GLM.
function GLM_Callback(hObject, eventdata, handles)
% hObject    handle to GLM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GLM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GLM

selected = get(hObject,'Value');

switch selected
    case 1
        cfg_add_module('pspm.first_level.scr.glm_scr');
    case 2
        cfg_add_module('pspm.first_level.hp.glm_hp_e');
    case 3 
        cfg_add_module('pspm.first_level.hp.glm_hp_fc');
    case 4
        cfg_add_module('pspm.first_level.ps.glm_ps_fc');
    case 5
        cfg_add_module('pspm.first_level.resp.glm_ra_e');
    case 6
        cfg_add_module('pspm.first_level.resp.glm_ra_fc');
    case 7
        cfg_add_module('pspm.first_level.resp.glm_rp_e');
    case 8
        cfg_add_module('pspm.first_level.resp.glm_rfr_e');
    case 9
        cfg_add_module('pspm.first_level.sebr.glm_sebr');
    case 10
        cfg_add_module('pspm.first_level.sps.glm_sps');
end;


% --- Executes on selection change in ppDataPreprocessing.
function ppDataPreprocessing_Callback(hObject, eventdata, handles)
% hObject    handle to ppDataPreprocessing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ppDataPreprocessing contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppDataPreprocessing

selected = get(hObject,'Value');

switch selected
    case 1
        cfg_add_module('pspm.data_preprocessing.pp_heart_period.pp_heart_data');
    case 2
        %cfg_add_module('pspm.data_preprocessing.pp_heart_period.ecg_editor');
        pspm_ecg_editor();
    case 3
        cfg_add_module('pspm.data_preprocessing.resp_pp');
    case 4 
        cfg_add_module('pspm.data_preprocessing.pp_pupil.process_illuminance');
    case 5
        cfg_add_module('pspm.data_preprocessing.pp_pupil.find_valid_fixations');
    case 6
        cfg_add_module('pspm.data_preprocessing.pp_pupil.pupil_correct');
    case 7
        cfg_add_module('pspm.data_preprocessing.pp_pupil.pupil_preprocess');
    case 8
        cfg_add_module('pspm.data_preprocessing.pupil_size_convert');
    case 9
        cfg_add_module('pspm.data_preprocessing.gaze_convert');
    %case 10
    %    cfg_add_module('pspm.tools.convert_data');
    case 10
        cfg_add_module('pspm.data_preprocessing.pp_emg.find_sounds');
    case 11
        cfg_add_module('pspm.data_preprocessing.pp_emg.pp_emg_data');
end;



% --- Executes during object creation, after setting all properties.
function ppDataPreprocessing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppDataPreprocessing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ppDataPreparation.
function ppDataPreparation_Callback(hObject, eventdata, handles)
% hObject    handle to ppDataPreparation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ppDataPreparation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppDataPreparation

selected = get(hObject,'Value');

switch selected
    case 1
        cfg_add_module('pspm.prep.import');
    case 2
        cfg_add_module('pspm.prep.trim');
end;


% --- Executes during object creation, after setting all properties.
function ppDataPreparation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppDataPreparation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
