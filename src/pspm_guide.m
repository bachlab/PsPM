function varargout = pspm_guide(varargin)
% ● Description
%   pspm handles the main GUI for PsPM
% ● Developer's Guide
%   Template
%   function varargout = FunctionName(hObject, eventdata, handles, varargin)
%     varargout  cell array for returning output args (see VARARGOUT);
%     hObject    handle to figure
%     eventdata  reserved - to be defined in a future version of MATLAB
%     handles    structure with handles and user data (see GUIDATA)
%     varargin   command line arguments to the function (see VARARGIN)
%   end
% ● Copyright
%   Introduced in PsPM 1.0 and terminated in PsPM 6.1.
%   Written by Dominik R Bach (Wellcome Centre for Human Neuroimaging) in 2008-2021
%   Lastly updated in PsPM 6.1 by Teddy Chao (UCL) in 2022

%% Initialise
global settings
if isempty(settings)
    pspm_init;
end
% sts = -1;
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


function PsPM_OpeningFcn(hObject, ~, handles, ~)
  % Executes just before tag_PsPM is made visible. 
  % This function has no output args, see OutputFcn.
  pspm_init;
  cfg_util('initcfg'); % This must be the first call to cfg_util
  %cfg_ui('Visible','off'); % Create invisible batch ui
  handles.output = hObject;
  % Choose default command line output for tag_PsPM
  pspm_ui(hObject, handles, 'main');
  % Update handles structure
  guidata(hObject, handles);
  % UIWAIT makes tag_PsPM wait for user response (see UIRESUME)
  % uiwait(handles.figure1);
function varargout = PsPM_OutputFcn(~, ~, handles)
  % Outputs from this function are returned to the command line.
  % Get default command line output from handles structure
  varargout{1} = handles.output;
function tag_PsPM_ButtonDownFcn(~, ~, ~)
  % Button: PsPM
  % --- If Enable == 'on', executes on mouse press in 5 pixel border.
  % --- Otherwise, executes on mouse press in 5 pixel border or over tag_PsPM.
  pspm_show_arms;
  %% Data preparation - import
  % --- Executes on button press in Import_data.
function Import_data_Callback(~, ~, ~)
  % hObject    handle to Import_data (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % pspm_import_UI;
  cfg_add_module('pspm.prep.import');
  %% Data preparation - trim
function Trim_data_Callback(~, ~, ~)
  % hObject    handle to Trim_data (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % pspm_trim_UI;
  cfg_add_module('pspm.prep.trim');
function dispdata_Callback(~, ~, ~)
  % Tools - display data
  % main function: pspm_disp
  cfg_add_module('pspm.tools.disp');
function tag_export_statistics_Callback(~, ~, ~)
  %% Export statistics
  % pspm_exp_UI;
  cfg_add_module('pspm.first_level.export');
function tag_review_model_Callback(~, ~, ~)
  %% Review model
  % --- Executes on button press in tag_review_model.
  % hObject    handle to tag_review_model (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % pspm_rev1_UI;
  pspm_review;
  % cfg_add_module('tag_pspm.first_level.review');
function tag_contrast_manager_Callback(~, ~, ~)
  % Description
  %   Executes on button press in tag_contrast_manager.
  % pspm_con1_UI;
  pspm_contrast;
  %cfg_add_module('tag_pspm.first_level.contrast');
function tag_non_linear_scr_model_Callback(~, ~, ~)
  % Description
  %   Executes on button press in tag_non_linear_scr_model.
  % pspm_dcm_UI;
  cfg_add_module('pspm.first_level.scr.dcm');
function tag_models_for_sf_Callback(~, ~, ~)
  % Description
  %   Executes on button press in tag_models_for_sf.
  % pspm_sf_UI;
  cfg_add_module('pspm.first_level.scr.sf');
function tag_report_second_level_Callback(~, ~, ~)
  % Description
  %   Executes on button press in tag_report_second_level.
  cfg_add_module('pspm.second_level.report');
function tag_second_level_model_Callback(~, ~, ~)
  % Description
  %   Executes on button press in tag_second_level_model.
  % pspm_con2_UI;
  cfg_add_module('pspm.second_level.contrast');
function tag_batch_Callback(~, ~, ~)
  % Description
  %   Executes on button press in tag_batch.
  cfg_ui;
function tag_quit_Callback(~, ~, ~)
  % Description
  %   Executes on button press in tag_quit.
  pspm_quit;
  return
function tag_tools_list_Callback(hObject, ~, ~)
  % Description
  %   Executes on selection change in tag_tools_list.
  % Hints
  %   contents = get(hObject,'String') returns tag_tools_list contents as cell array
  %   contents{get(hObject,'Value')} returns selected item from tag_tools_list
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
  end
function tag_tools_list_CreateFcn(hObject, ~, ~)
  % Hint
  %   popupmenu controls usually have a white background on Windows.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
function tag_first_level_models_list_CreateFcn(hObject, ~, ~)
  % Hint: popupmenu controls usually have a white background on Windows.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
function tag_first_level_models_list_Callback(hObject, ~, ~)
  % Description
  %   Executes on selection change in tag_first_level_models_list.
  % Hints
  %   contents = cellstr(get(hObject,'String')) returns 
  %   tag_first_level_models_list contents as cell array
  %   contents{get(hObject,'Value')} returns selected item from 
  %   tag_first_level_models_list
  selected = get(hObject,'Value');
  switch selected
    case 1 % SCR
        cfg_add_module('pspm.first_level.scr.glm_scr');
    case 2
        cfg_add_module('pspm.first_level.hp.glm_hp_e');
    case 3
        cfg_add_module('pspm.first_level.hp.glm_hp_fc');
    case 4
        cfg_add_module('pspm.first_level.resp.glm_ra_e');
    case 5
        cfg_add_module('pspm.first_level.resp.glm_ra_fc');
    case 6
        cfg_add_module('pspm.first_level.resp.glm_rfr_e');
    case 7
        cfg_add_module('pspm.first_level.resp.glm_rp_e');
    case 8
        cfg_add_module('pspm.first_level.ps.glm_ps_fc');
    case 9
        cfg_add_module('pspm.first_level.sebr.glm_sebr');
    case 10
        cfg_add_module('pspm.first_level.sps.glm_sps');
  end
function tag_data_preprocessing_list_Callback(hObject, ~, ~)
  % Description
  %   Executes on selection change in tag_data_preprocessing_list.
  % Hints
  % contents = cellstr(get(hObject,'String')) returns 
  % tag_data_preprocessing_list contents as cell array
  % contents{get(hObject,'Value')} returns selected item from 
  % tag_data_preprocessing_list
  selected = get(hObject,'Value');
  switch selected
    case 1
      cfg_add_module('pspm.data_preprocessing.pp_scr');%pp_scr
    case 2
      cfg_add_module('pspm.data_preprocessing.pp_heart_period.pp_heart_data');
    case 3
      %cfg_add_module('tag_pspm.data_preprocessing.pp_heart_period.ecg_editor');
      pspm_ecg_editor();
    case 4
      cfg_add_module('pspm.data_preprocessing.resp_pp');
    case 5
      cfg_add_module('pspm.data_preprocessing.pp_pupil.process_illuminance');
    case 6
      cfg_add_module('pspm.data_preprocessing.pp_pupil.find_valid_fixations');
    case 7
      cfg_add_module('pspm.data_preprocessing.pp_pupil.pupil_correct');
    case 8
      cfg_add_module('pspm.data_preprocessing.pp_pupil.pupil_preprocess');
    case 9
      cfg_add_module('pspm.data_preprocessing.pupil_size_convert');
    case 10
      cfg_add_module('pspm.data_preprocessing.gaze_convert');
    case 11
      cfg_add_module('pspm.data_preprocessing.pp_emg.find_sounds');
    case 12
      cfg_add_module('pspm.data_preprocessing.pp_emg.pp_emg_data');
  end
function tag_data_preprocessing_list_CreateFcn(hObject, ~, ~)
  % Description
  %   Executes during object creation, after setting all properties.
  % Hints
  %   popupmenu controls usually have a white background on Windows.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
function tag_data_preparation_list_Callback(hObject, ~, ~)
  % Description
  %   Executes on selection change in tag_data_preparation_list.
  % Hints
  %   contents = cellstr(get(hObject,'String')) returns 
  %   tag_data_preparation_list contents as cell array
  %   contents{get(hObject,'Value')} returns selected item from 
  %   tag_data_preparation_list
  selected = get(hObject,'Value');
  switch selected
    case 1
      cfg_add_module('pspm.prep.import');
    case 2
      cfg_add_module('pspm.prep.trim');
  end
function tag_data_preparation_list_CreateFcn(hObject, ~, ~)
  % Description
  %   Executes during object creation, after setting all properties.
  % Hint
  %   popupmenu controls usually have a white background on Windows.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
function tag_feedback_Callback(~, ~, ~)
  % Description
  %   Executes on button press in tag_feedback.
  pspm_show_forum();
function tag_help_Callback(~, ~, ~)
  % Description
  %   Executes on button press in tag_help.
  pspm_show_help_doc();