function [hObject, handles] = pspm_ui(hObject,handles,window)
% ● Description
%   pspm_ui controls the UI of the referred handle.
% ● Arguments
%   * hObject : UI controllor of the specific GUI window.
%   * handles : UI controllor of the specific GUI window.
%   *  window : the name of the specific GUI window.
% ● History
%   Introduced in PsPM 5.1
%   Written and maintained in 2021-2022
%   Maintained in 2024 by Bernhard von Raußendorf

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
%% Check desktop system
addons = matlab.addons.installedAddons;
flag_new_desktop = any(strcmp(addons.Identifier,'ML_JAVASCRIPT_DESKTOP'));
%% Parameters for UI optimisation
if ispc
  if flag_new_desktop
    FSTitle = 10;
    FSText = 9;
    FSCaption = 8;
    FSAttr = 8;
  else
    FSTitle = 11;
    FSText = 10;
    FSCaption = 9;
    FSAttr = 9;
  end
  DisplayUnit = 'points';
  FNRoman = 'Segoe UI';
  FNEmph = 'Segoe UI Bold';
  MainWeight = 500;
  MainHeight = 500*0.8;
  DisplayWeight = 250;
  DisplayHeight = 250/5;
  SwitchResize = 'off';
elseif ismac
  if flag_new_desktop
    FSTitle = 12;
    FSText = 12;
    FSCaption = 10;
    FSAttr = 11;
  else
    FSTitle = 14;
    FSText = 14;
    FSCaption = 12;
    FSAttr = 13;
  end
  FNRoman = 'Helvetica';
  FNEmph = 'Helvetica-Bold';
  DisplayUnit = 'points';
  MainWeight = 750;
  MainHeight = 750*0.8;
  DisplayWeight = 190;
  DisplayHeight = 60;
  SwitchResize = 'off';
else
  if flag_new_desktop
    FSTitle = 10;
    FSText = 9;
    FSCaption = 8;
    FSAttr = 9;
  else
    FSTitle = 11;
    FSText = 10;
    FSCaption = 9;
    FSAttr = 10;
  end
  FNRoman = 'DejaVu Sans';
  FNEmph = 'DejaVu Sans Bold';
  DisplayUnit = 'points';
  MainWeight = 650;
  MainHeight = 650*0.8;
  DisplayWeight = 190;
  DisplayHeight = 60;
  SwitchResize = 'on';
end
switch window
  case 'main'
    % TitleCase
    TitleComponents = {'tag_batch',...
      'tag_contrast_manager',...
      'tag_export_statistics',...
      'tag_feedback',...
      'tag_help',...
      'tag_models_for_sf',...
      'tag_non_linear_scr_model',...
      'tag_quit',...
      'tag_report_second_level',...
      'tag_review_model',...
      'tag_second_level_model'};
    % CaptionCase
    CaptionComponents = {'tag_data_preparation_list',...
      'tag_data_preparation_title',...
      'tag_data_preprocessing_list',...
      'tag_data_preprocessing_title',...
      'tag_first_level_models_list',...
      'tag_first_level_models_title',...
      'tag_more_title',...
      'tag_second_level_model_title',...
      'tag_tools_list',...
      'tag_tools_title'};
    % Others
    handles.figure1.Units = DisplayUnit;
    handles.tag_attribution.FontName = FNRoman;
    handles.tag_attribution.FontSize = FSAttr;
    %handles.tag_attribution.Visible = 'off';
    handles.tag_attribution.HorizontalAlignment = 'center';
    attribution_disp_text = sprintf(['Version 7.0, Build 25-01-2024 with MATLAB 2023a, ',...
      'The PsPM Team']);
    handles.tag_attribution.String = attribution_disp_text;
    handles.tag_PsPM.FontName = FNRoman;
    hObject.Position(3) = MainWeight;
    hObject.Position(4) = MainHeight;
    hObject.Resize = SwitchResize;
  case 'contrast'
    hObject.Resize = 'on';
    TitleComponents = {'panelContrastNames',...
                       'panelNames',...
                       'uipanelDefine',...
                       'panelModel',...
                       'panelStatus',...
                       'buttonExit'};
    TextComponents = {'listContrastNames',...
                      'listNames',...
                      'panelTestDef',...
                      'radioIntercept',...
                      'radioCondDiff',...
                      'radioQuadEffects',...
                      'panelDefineConName',...
                      'editContrastName',...
                      'buttonNewContrast',...
                      'buttonClearCon',...
                      'buttonDeleteContrast',...
                      'textStatus',...
                      'buttonLoadModel',...
                      'buttonRun',...
                      'radioGroup1',...
                      'radioGroup2',...
                      'radioGroup3',...
                      'radioParam',...
                      'radioCond',...
                      'radioRecon',...
                      'checkboxZscored',...
                      'checkboxDeleteCon',...
                      'panelGroup',...
                      'panelStatstype'};
  case 'display'
    % TitleCase
    TitleComponents = {'button_all',...
      'button_autoscale',...
      'button_plot',...
      'module_display_options',...
      'module_event_channels',...
      'module_event_options',...
      'module_summary',...
      'module_wave_channels',...
      'text_file_summary'};
    % CaptionCase
    CaptionComponents = {'display_plot'};
    % TextCase
    TextComponents = {'list_event_channel',...
      'list_wave_channel',...
      'option_extra',...
      'option_integrated',...
      'tag_summary_recording_duration_content',...
      'tag_summary_channel_list_content',...
      'text_starting_point',...
      'text_time_window',...
      'text_y_max',...
      'text_y_min',...
      'edit_start_x',...
      'edit_winsize_x',...
      'edit_y_max',...
      'edit_y_min',...
      'tag_summary_source_file_content'};
    % EmphCase
    EmphComponents = {'tag_summary_recording_duration_title',...
      'tag_summary_source_file_title',...
      'tag_summary_channel_list_title'};
    % Others
    %hObject.Position(3) = DisplayWeight;
    %hObject.Position(4) = DisplayHeight;
    hObject.Resize = 'off';
    handles.name=[];
    handles.prop.axis=[];
    handles.prop.event=[];
    handles.prop.eventchans=[];
    handles.prop.wave=[];
    handles.prop.wavechans=[];
  case 'ecg_editor'
    TitleComponents = {'pnlFileIO',...
                       'pnlArtifactEpochs', ...
                       'uipanel1',...
                       'pnlNavigate',...
                       'uipanel10',...
                       'pnlWrongEvents'};
    TextComponents = {'axes',...
                      'uipanel9',...
                      'txtDataFile',...
                      'edtDataFile',...
                      'pbChangeFile',...
                      'txtEcgChan',...
                      'ppEcgChan',...
                      'txtHbChan',...
                      'ppHbChan',...
                      'bgOutputOptions',...
                      'rbAddChan',...
                      'rbReplaceHbChan',...
                      'bgArtifactDisplaySettings',...
                      'rbShowArtefacts',...
                      'rbDisableArtefactDetection',...
                      'rbHideArtefactEvents',...
                      'bgOutputSettings',...
                      'rbIncludeArtefactQRS',...
                      'rbExcludeArtefactQRS',...
                      'edtArtefactFile',...
                      'pbArtefactFile',...
                      'pbArtefactsDisable',...
                      'text1',...
                      'zoomIn',...
                      'zoomOut',...
                      'togg_add',...
                      'togg_remove',...
                      'txtFactor',...
                      'edtFactor',...
                      'txtFactorStdDev',...
                      'txtUpperLimit',...
                      'edtUpperLimit',...
                      'txtLowerLimit',...
                      'edtLowerLimit',...
                      'edtApplyDetSet',...
                      'lstEvents',...
                      'cbManualMode',...
                      'push_last',...
                      'push_next',...
                      'push_done',...
                      'push_cancel'};
  case 'review'
    hObject.Resize = 'on';
    TitleComponents = {'panelStatus',...
      'panelModel',...
      'panelPlot'};
    TextComponents = {'textStatus',...
      'buttonAddModel',...
      'buttonRemoveModel',...
      'listModel',...
      'textPlot1',...
      'buttonPlot1',...
      'editEpochNr',...
      'textPlot2',...
      'buttonPlot2',...
      'editEpochNr',...
      'textPlot3',...
      'buttonPlot3',...
      'textPlot4',...
      'buttonPlot4',...
      'textPlot5',...
      'buttonPlot5',...
      'textPlot6',...
      'buttonPlot6',...
      'textPlot7',...
      'buttonPlot7',...
      'buttonPlotClose',...
      'textSessionNr',...
      'editSessionNr',...
      'textSessionRange',...
      'pushbutton_quit'};
  case 'data_editor'
    hObject.Resize = 'on';
    TitleComponents = {'pnlSettings'};
    TextComponents = {'bgOutputFormat',...
      'rbEpochs',...
      'rbInterpolate',...
      'cbInterpolate',...
      'lbChannel',...
      'edOpenFilePath',...
      'pbOpenInputFile',...
      'pnlEpoch',...
      'pnlInput',...
      'edOpenMissingEpochFilePath',...
      'pbOpenMissingEpochFile',...
      'edOutputFile',...
      'pbOpenOutputFile',...
      'pbSaveOutput',...
      'axData',...
      'pnlOutput',...
      'lbEpochs',...
      'pbCancel',...
      'pbApply'};
  case 'cfg_ui'
    hObject.Resize = 'on';
    TitleComponents = {'text4', ...
                      'moduleHead', ...
                      'valshowLabel'};
    TextComponents = {'modlist','module', 'valshow',...
                      'helpbox','BtnValEditVal',...
                      'BtnValAddDep'};
end
if exist('TitleComponents', 'var')
  ApplyStyle(handles, TitleComponents, FNRoman, FSTitle);
end
if exist('TextComponents', 'var')
  ApplyStyle(handles, TextComponents, FNRoman, FSText);
end
if exist('CaptionComponents', 'var')
  ApplyStyle(handles, CaptionComponents, FNRoman, FSCaption);
end
if exist('EmphComponents', 'var')
  ApplyStyle(handles, EmphComponents, FNEmph, FSText);
end
return
function ApplyStyle(handles, widgt, FN, FS)
[r,c] = size(widgt);
for i_r = 1:r
  for i_c = 1:c
    handles = setfield(handles, widgt{i_r,i_c}, 'FontName', FN);
    handles = setfield(handles, widgt{i_r,i_c}, 'FontSize', FS);
  end
end
