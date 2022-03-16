function pspm_ui(hObject,handles,window)

  % pspm_ui controls the UI of the referred handle
  % The PsPM Team, UCL

  %% Parameters for UI optimisation
  if ispc
    FSTitle = 11;
    FSText = 10;
    FSCaption = 9;
    FSAttr = 9;
    DisplayUnit = 'points';
    FNRoman = 'Segoe UI';
    FNEmph = 'Segoe UI Bold';
    MainWeight = 500;
    MainHeight = 500*0.8;
    DisplayWeight = 250;
    DisplayHeight = 250/5;
    SwitchResize = 'off';
  elseif ismac
    FSTitle = 16;
    FSText = 14;
    FSCaption = 12;
    FSAttr = 13;
    FNRoman = 'Helvetica Neue';
    FNEmph = 'Gill Sans';
    DisplayUnit = 'points';
    MainWeight = 750;
    MainHeight = 750*0.8;
    DisplayWeight = 190;
    DisplayHeight = 60;
    SwitchResize = 'off';
  else
    FSTitle = 11;
    FSText = 10;
    FSCaption = 9;
    FSAttr = 10;
    FNRoman = 'DejaVu Sans';
    FNEmph = 'DejaVu Sans';
    DisplayUnit = 'points';
    MainWeight = 650;
    MainHeight = 650*0.8;
    DisplayWeight = 190;
    DisplayHeight = 60;
    SwitchResize = 'on';
  end
  switch window
  case 'main'
    handles.figure1.Units = DisplayUnit;
    handles.tag_attribution.FontName = FNRoman;
    handles.tag_attribution.FontSize = FSAttr;
    %handles.tag_attribution.Visible = 'off';
    handles.tag_attribution.HorizontalAlignment = 'center';
    attribution_disp_text = sprintf(['Version 5.1.1, Build ',datestr(now,'ddmmyyyy'),' with MATLAB 2021a, ',...
    'The PsPM Team, University College London']);
    handles.tag_attribution.String = attribution_disp_text;
    handles.tag_batch.FontName = FNRoman;
    handles.tag_batch.FontSize = FSTitle;
    handles.tag_contrast_manager.FontName = FNRoman;
    handles.tag_contrast_manager.FontSize = FSTitle;
    handles.tag_data_preparation_list.FontName = FNRoman;
    handles.tag_data_preparation_list.FontSize = FSCaption;
    handles.tag_data_preparation_title.FontName = FNRoman;
    handles.tag_data_preparation_title.FontSize = FSCaption;
    handles.tag_data_preprocessing_list.FontName = FNRoman;
    handles.tag_data_preprocessing_list.FontSize = FSCaption;
    handles.tag_data_preprocessing_title.FontName = FNRoman;
    handles.tag_data_preprocessing_title.FontSize = FSCaption;
    handles.tag_export_statistics.FontName = FNRoman;
    handles.tag_export_statistics.FontSize = FSTitle;
    handles.tag_feedback.FontName = FNRoman;
    handles.tag_feedback.FontSize = FSTitle;
    handles.tag_first_level_models_list.FontName = FNRoman;
    handles.tag_first_level_models_list.FontSize = FSCaption;
    handles.tag_first_level_models_title.FontName = FNRoman;
    handles.tag_first_level_models_title.FontSize = FSCaption;
    handles.tag_help.FontName = FNRoman;
    handles.tag_help.FontSize = FSTitle;
    handles.tag_models_for_sf.FontName = FNRoman;
    handles.tag_models_for_sf.FontSize = FSTitle;
    handles.tag_more_title.FontName = FNRoman;
    handles.tag_more_title.FontSize = FSCaption;
    handles.tag_non_linear_scr_model.FontName = FNRoman;
    handles.tag_non_linear_scr_model.FontSize = FSTitle;
    handles.tag_PsPM.FontName = FNRoman;
    handles.tag_quit.FontName = FNRoman;
    handles.tag_quit.FontSize = FSTitle;
    handles.tag_report_second_level.FontName = FNRoman;
    handles.tag_report_second_level.FontSize = FSTitle;
    handles.tag_review_model.FontName = FNRoman;
    handles.tag_review_model.FontSize = FSTitle;
    handles.tag_second_level_model_title.FontName = FNRoman;
    handles.tag_second_level_model_title.FontSize = FSCaption;
    handles.tag_second_level_model.FontName = FNRoman;
    handles.tag_second_level_model.FontSize = FSTitle;
    handles.tag_tools_list.FontName = FNRoman;
    handles.tag_tools_list.FontSize = FSCaption;
    handles.tag_tools_title.FontName = FNRoman;
    handles.tag_tools_title.FontSize = FSCaption;
    hObject.Position(3) = MainWeight;
    hObject.Position(4) = MainHeight;
    hObject.Resize = SwitchResize;
  case 'display'
    handles.button_all.FontName = FNRoman;
    handles.button_all.FontSize = FSTitle;
    handles.button_autoscale.FontName = FNRoman;
    handles.button_autoscale.FontSize = FSTitle;
    handles.button_plot.FontName = FNRoman;
    handles.button_plot.FontName = FNRoman;
    handles.button_plot.FontSize = FSTitle;
    handles.button_plot.FontSize = FSTitle;
    handles.display_plot.FontName = FNRoman;
    handles.display_plot.FontSize = FSCaption;
    handles.list_event_channel.FontName = FNRoman;
    handles.list_event_channel.FontSize = FSText;
    handles.list_wave_channel.FontName = FNRoman;
    handles.list_wave_channel.FontSize = FSText;
    handles.module_display_options.FontName = FNRoman;
    handles.module_display_options.FontSize = FSTitle;
    handles.module_event_channels.FontName = FNRoman;
    handles.module_event_channels.FontSize = FSTitle;
    handles.module_event_options.FontName = FNRoman;
    handles.module_event_options.FontSize = FSTitle;
    handles.module_summary.FontName = FNRoman;
    handles.module_summary.FontSize = FSTitle;
    handles.module_wave_channels.FontName = FNRoman;
    handles.module_wave_channels.FontSize = FSTitle;
    handles.name=[];
    handles.option_extra.FontName = FNRoman;
    handles.option_extra.FontSize = FSText;
    handles.option_integrated.FontName = FNRoman;
    handles.option_integrated.FontSize = FSText;
    handles.prop.axis=[];
    handles.prop.event=[];
    handles.prop.eventchans=[];
    handles.prop.wave=[];
    handles.prop.wavechans=[];
    handles.tag_summary_recording_duration_content.FontName = FNRoman;
    handles.tag_summary_recording_duration_content.FontSize = FSText;
    handles.tag_summary_recording_duration_title.FontName = FNEmph;
    handles.tag_summary_recording_duration_title.FontSize = FSText;
    handles.tag_summary_source_file_content.FontName = FNRoman;
    handles.tag_summary_source_file_content.FontSize = FSText;
    handles.tag_summary_source_file_title.FontName = FNEmph;
    handles.tag_summary_source_file_title.FontSize = FSText;
    handles.tag_summary_channel_list_title.FontName = FNEmph;
    handles.tag_summary_channel_list_title.FontSize = FSText;
    handles.tag_summary_channel_list_content.FontName = FNRoman;
    handles.tag_summary_channel_list_content.FontSize = FSText;
    handles.text_file_summary.FontName = FNRoman;
    handles.text_file_summary.FontSize = FSTitle;
    handles.text_starting_point.FontName = FNRoman;
    handles.text_starting_point.FontSize = FSText;
    handles.text_time_window.FontName = FNRoman;
    handles.text_time_window.FontSize = FSText;
    handles.text_y_max.FontName = FNRoman;
    handles.text_y_max.FontSize = FSText;
    handles.text_y_min.FontName = FNRoman;
    handles.text_y_min.FontSize = FSText;
    hObject.Position(3) = DisplayWeight;
    hObject.Position(4) = DisplayHeight;
    hObject.Resize = 'on';
  case 'review'
    hObject.Resize = 'on';
    Title_components = {'panelStatus',...
    'panelModel',...
    'panelPlot'};
    Text_components = {'textStatus',...
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
    'buttonPlotClose',...
    'textSessionNr',...
    'editSessionNr',...
    'textSessionRange',...
    'pushbutton_quit'};
  case 'data_editor'
    hObject.Resize = 'on';
    Title_components = {'pnlSettings'};
    Text_components = {'bgOutputFormat',...
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
    'lbEpochs',...
    'pbCancel',...
    'pbApply'};
  end
  if exist('Title_components', 'var')
    ApplyStyle(handles, Title_components, FNRoman, FSTitle);
  end
  if exist('Text_components', 'var')
    ApplyStyle(handles, Text_components, FNRoman, FSText);
  end
end

function ApplyStyle(handles, widgt, FN, FS)
  [r,c] = size(widgt);
  for i_r = 1:r
    for i_c = 1:c
      handles = setfield(handles, widgt{i_r,i_c}, 'FontName', FN);
      handles = setfield(handles, widgt{i_r,i_c}, 'FontSize', FS);
    end
  end
end
