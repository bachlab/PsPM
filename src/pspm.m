function varargout = pspm(varargin)
    % tag_PsPM is the main GUI for tag_PsPM
    %__________________________________________________________________________
    % tag_PsPM 5.1
    % (C) 2008-2021 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

    % $Id: tag_pspm.m 636 2019-03-15 07:56:42Z lciernik $
    % $Rev: 636 $

    % this code was mainly produced by GUIDE
    % PsPM_GUI M-file for PsPM_GUI.fig
    %      PsPM_GUI, by itself, creates a new tag_PsPM or raises the existing
    %      singleton*.
    %
    %      H = tag_pspm returns the handle to a new tag_PsPM or the handle to
    %      the existing singleton*.
    %
    %      tag_PsPM('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in tag_PsPM.M with the given input arguments.
    %
    %      tag_PsPM('Property','Value',...) creates a new tag_PsPM or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before PsPM_OpeningFunction gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to PsPM_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help tag_PsPM

    % Last Modified by GUIDE v2.5 07-Jul-2021 16:18:18
    % initialise
    % -------------------------------------------------------------------------
    global settings;
    if isempty(settings)
        pspm_init;
    end
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
end

% --- Executes just before tag_PsPM is made visible.
function PsPM_OpeningFcn(hObject, ~, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to tag_PsPM (see VARARGIN)
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
end


% --- Outputs from this function are returned to the command line.
function varargout = PsPM_OutputFcn(~, ~, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over tag_PsPM.
function tag_PsPM_ButtonDownFcn(~, ~, ~)
    % hObject    handle to tag_PsPM (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    pspm_show_arms;
end

% --- Executes on button press in Import_data.
function Import_data_Callback(~, ~, ~)
    % hObject    handle to Import_data (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % pspm_import_UI;
    cfg_add_module('pspm.prep.import');
end


% --- Executes on button press in Trim_data.
function Trim_data_Callback(~, ~, ~)
    % hObject    handle to Trim_data (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % pspm_trim_UI;
    cfg_add_module('pspm.prep.trim');
end

% --- Executes on button press in dispdata.
function dispdata_Callback(~, ~, ~)
    % hObject    handle to dispdata (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % pspm_disp;
    cfg_add_module('pspm.tools.disp');
end

% --- Executes on button press in tag_export_statistics.
function tag_export_statistics_Callback(~, ~, ~)
    % hObject    handle to tag_export_statistics (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % pspm_exp_UI;
    cfg_add_module('pspm.first_level.export');
end

% --- Executes on button press in tag_review_model.
function tag_review_model_Callback(~, ~, ~)
    % hObject    handle to tag_review_model (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %pspm_rev1_UI;
    pspm_review;
    % cfg_add_module('tag_pspm.first_level.review');
end

% --- Executes on button press in tag_contrast_manager.
function tag_contrast_manager_Callback(~, ~, ~)
    % hObject    handle to tag_contrast_manager (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % pspm_con1_UI;
    pspm_contrast;
    %cfg_add_module('tag_pspm.first_level.contrast');
end

% --- Executes on button press in tag_non_linear_scr_model.
function tag_non_linear_scr_model_Callback(~, ~, ~)
    % hObject    handle to tag_non_linear_scr_model (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % pspm_dcm_UI;
    cfg_add_module('pspm.first_level.scr.dcm');
end

% --- Executes on button press in tag_models_for_sf.
function tag_models_for_sf_Callback(~, ~, ~)
    % hObject    handle to tag_models_for_sf (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % pspm_sf_UI;
    cfg_add_module('pspm.first_level.scr.sf');
end

% --- Executes on button press in tag_report_second_level.
function tag_report_second_level_Callback(~, ~, ~)
    % hObject    handle to tag_report_second_level (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    cfg_add_module('pspm.second_level.report');
end

% --- Executes on button press in tag_second_level_model.
function tag_second_level_model_Callback(~, ~, ~)
    % hObject    handle to tag_second_level_model (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % pspm_con2_UI;
    cfg_add_module('pspm.second_level.contrast');
end

% --- Executes on button press in tag_batch.
function tag_batch_Callback(~, ~, ~)
    % hObject    handle to tag_batch (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    cfg_ui;
end

% --- Executes on button press in tag_quit.
function tag_quit_Callback(~, ~, ~)
    % hObject    handle to tag_quit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    pspm_quit;
    return;
end


% --- Executes on selection change in tag_tools_list.
function tag_tools_list_Callback(hObject, ~, ~)
    % hObject    handle to tag_tools_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % Hints: contents = get(hObject,'String') returns tag_tools_list contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from tag_tools_list
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
end

% --- Executes during object creation, after setting all properties.
function tag_tools_list_CreateFcn(hObject, ~, ~)
    % hObject    handle to tag_tools_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes during object creation, after setting all properties.
function tag_first_level_models_list_CreateFcn(hObject, ~, ~)
    % hObject    handle to tag_first_level_models_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on selection change in tag_first_level_models_list.
function tag_first_level_models_list_Callback(hObject, ~, ~)
    % hObject    handle to tag_first_level_models_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns tag_first_level_models_list contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from tag_first_level_models_list

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
    end
end


% --- Executes on selection change in tag_data_preprocessing_list.
function tag_data_preprocessing_list_Callback(hObject, ~, ~)
    % hObject    handle to tag_data_preprocessing_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns tag_data_preprocessing_list contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from tag_data_preprocessing_list

    selected = get(hObject,'Value');
    switch selected
    case 1
        cfg_add_module('pspm.data_preprocessing.pp_heart_period.pp_heart_data');
    case 2
        %cfg_add_module('tag_pspm.data_preprocessing.pp_heart_period.ecg_editor');
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
    case 10
        cfg_add_module('pspm.data_preprocessing.pp_emg.find_sounds');
    case 11
        cfg_add_module('pspm.data_preprocessing.pp_emg.pp_emg_data');
    case 12
        cfg_add_module('pspm.data_preprocessing.pp_scr');%pp_scr
    end
end



% --- Executes during object creation, after setting all properties.
function tag_data_preprocessing_list_CreateFcn(hObject, ~, ~)
    % hObject    handle to tag_data_preprocessing_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on selection change in tag_data_preparation_list.
function tag_data_preparation_list_Callback(hObject, ~, ~)
    % hObject    handle to tag_data_preparation_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns tag_data_preparation_list contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from tag_data_preparation_list

    selected = get(hObject,'Value');

    switch selected
    case 1
        cfg_add_module('pspm.prep.import');
    case 2
        cfg_add_module('pspm.prep.trim');
    end
end


% --- Executes during object creation, after setting all properties.
function tag_data_preparation_list_CreateFcn(hObject, ~, ~)
    % hObject    handle to tag_data_preparation_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on button press in tag_help.
function tag_help_Callback(~, ~, ~)
    % hObject    handle to tag_help (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    pspm_show_help_doc();
end


% --- Executes on button press in tag_feedback.
function tag_feedback_Callback(~, ~, ~)
    % hObject    handle to tag_feedback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    pspm_show_forum();
end
