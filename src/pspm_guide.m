function varargout = pspm_guide(varargin)
% ● Description
%   pspm_guide handles the main GUI for PsPM
% ● Developer's Guide
%   * Template
%     function varargout = FunctionName(hObject, eventdata, handles, varargin)
%       varargout  cell array for returning output args (see VARARGOUT);
%       hObject    handle to figure
%       eventdata  reserved - to be defined in a future version of MATLAB
%       handles    structure with handles and user data (see GUIDATA)
%       varargin   command line arguments to the function (see VARARGIN)
%     end
%   * Selection list
%       contents = get(hObject,'String') returns the list contents as cell array
%       contents{get(hObject,'Value')} returns selected item from the list
%   * Hint
%       popupmenu controls usually have a white background on Windows.
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
    'gui_Visible',    'off' , ...
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

% 1 Logo
function pspm_logo(~, ~, ~)
  % Button: PsPM
  % If Enable == 'on', executes on mouse press in 5 pixel border.
  % Otherwise, executes on mouse press in 5 pixel border or over tag_PsPM.
  pspm_show_arms;

% 2 Data Preparation
function data_preparation_list_callback(hObject, ~, ~)
  % Selection list: data preparation
  selected = get(hObject,'Value');
  switch selected
    case 1
      cfg_add_module('pspm.prep.import');
    case 2
      cfg_add_module('pspm.prep.trim');
  end
function data_preparation_list_create_function(hObject, ~, ~)
  % Hint: popupmenu controls usually have a white background on Windows.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
function import_callback(~, ~, ~)
  % List item: data preparation - import
  % pspm_import_UI;
  cfg_add_module('pspm.prep.import');
function trim_callback(~, ~, ~)
  % List item: data preparation - trim
  % pspm_trim_UI;
  cfg_add_module('pspm.prep.trim');

% 3 Data Preprocessing
function data_preprocessing_list_callback(hObject, ~, ~)
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
      cfg_add_module('pspm.data_preprocessing.pp_pupil.pupil_size_convert');
    case 10
      cfg_add_module('pspm.data_preprocessing.pp_pupil.gaze_convert');
    case 11
      cfg_add_module('pspm.data_preprocessing.pp_emg.find_sounds');
    case 12
      cfg_add_module('pspm.data_preprocessing.pp_emg.pp_emg_data');
  end

% 4 Tools
function tools_list_callback(hObject, ~, ~)
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
function tools_list_create_function(hObject, ~, ~)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

function display_data_callback(~, ~, ~)
  % Tools - display data
  % main function: pspm_disp
  cfg_add_module('pspm.tools.disp');

% 5 First Level Models
function first_level_models_list_callback(hObject, ~, ~)
  switch get(hObject,'Value')
    case 1
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
function first_level_models_list_create_function(hObject, ~, ~)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

% 6 Non-linear SCR Model
function non_linear_scr_model_callback(~, ~, ~)
  % pspm_dcm_UI;
  cfg_add_module('pspm.first_level.scr.dcm');

% 7 Models for SF
function models_for_sf_callback(~, ~, ~)
  % pspm_sf_UI;
  cfg_add_module('pspm.first_level.scr.sf');

% 8 Review Model
function review_model_callback(~, ~, ~)
  % pspm_rev1_UI;
  pspm_review;
  % cfg_add_module('tag_pspm.first_level.review');

% 9 Contrast Manager
function contrast_manager_callback(~, ~, ~)
  % pspm_con1_UI;
  pspm_contrast;
  %cfg_add_module('tag_pspm.first_level.contrast');

% 10 Export Statistics
function export_statistics_callback(~, ~, ~)
  % Export statistics
  % pspm_exp_UI;
  cfg_add_module('pspm.first_level.export');

% 11 Second level model
function second_level_model_callback(~, ~, ~)
  % pspm_con2_UI;
  cfg_add_module('pspm.second_level.contrast');

% 12 Report second level
function report_second_level_callback(~, ~, ~)
  cfg_add_module('pspm.second_level.report');

% 13 Batch
function batch_callback(~, ~, ~)
  cfg_ui;

% 14 Help
function help_callback(~, ~, ~)
  pspm_show_help_doc();

% 15 Feedback
function feedback_callback(~, ~, ~)
  pspm_show_forum();

% 16 Quit
function quit_callback(~, ~, ~)
  pspm_quit;
  return
