function pspm_ui_initialisation(hObject, handles, window)
% ● Description
%   pspm_ui_initialisation adjusts the required UI parameters for window
%   initialisation.
% ● Format
%   pspm_ui_initialisation(hObject, handles, window)
% ● Arguments
%   hObject: MATLAB UI controllor
%   handles: MATLAB UI controllor
%    window: the name of the GUI window.
%            accepts: 'main', 'display', and 'review'
% ● History
%   Introduced in PsPM 5.1.2
%   Written and maintained in 2021 by Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
switch window
  case 'main'
    handles.figure1.Units = settings.ui.DisplayUnit;
    handles.tag_attribution.FontName = settings.ui.FontNameText;
    handles.tag_attribution.FontSize = settings.ui.FontSizeAttr;
    handles.tag_attribution.HorizontalAlignment = 'center';
    attribution_disp_text = sprintf(['Version 5.1.1, Build ',...
      datestr(now,'ddmmyyyy'),' with MATLAB 2021a, ',...
      'The PsPM Team, University College London']);
    handles.tag_attribution.String = attribution_disp_text;
    handles.tag_batch.FontName = settings.ui.FontNameText;
    handles.tag_batch.FontSize = settings.ui.FontSizeTitle;
    handles.tag_contrast_manager.FontName = settings.ui.FontNameText;
    handles.tag_contrast_manager.FontSize = settings.ui.FontSizeTitle;
    handles.tag_data_preparation_list.FontName = settings.ui.FontNameText;
    handles.tag_data_preparation_list.FontSize = settings.ui.FontSizeCaption;
    handles.tag_data_preparation_title.FontName = settings.ui.FontNameText;
    handles.tag_data_preparation_title.FontSize = settings.ui.FontSizeCaption;
    handles.tag_data_preprocessing_list.FontName = settings.ui.FontNameText;
    handles.tag_data_preprocessing_list.FontSize = settings.ui.FontSizeCaption;
    handles.tag_data_preprocessing_title.FontName = settings.ui.FontNameText;
    handles.tag_data_preprocessing_title.FontSize = settings.ui.FontSizeCaption;
    handles.tag_export_statistics.FontName = settings.ui.FontNameText;
    handles.tag_export_statistics.FontSize = settings.ui.FontSizeTitle;
    handles.tag_feedback.FontName = settings.ui.FontNameText;
    handles.tag_feedback.FontSize = settings.ui.FontSizeTitle;
    handles.tag_first_level_models_list.FontName = settings.ui.FontNameText;
    handles.tag_first_level_models_list.FontSize = settings.ui.FontSizeCaption;
    handles.tag_first_level_models_title.FontName = settings.ui.FontNameText;
    handles.tag_first_level_models_title.FontSize = settings.ui.FontSizeCaption;
    handles.tag_help.FontName = settings.ui.FontNameText;
    handles.tag_help.FontSize = settings.ui.FontSizeTitle;
    handles.tag_models_for_sf.FontName = settings.ui.FontNameText;
    handles.tag_models_for_sf.FontSize = settings.ui.FontSizeTitle;
    handles.tag_more_title.FontName = settings.ui.FontNameText;
    handles.tag_more_title.FontSize = settings.ui.FontSizeCaption;
    handles.tag_non_linear_scr_model.FontName = settings.ui.FontNameText;
    handles.tag_non_linear_scr_model.FontSize = settings.ui.FontSizeTitle;
    handles.tag_PsPM.FontName = settings.ui.FontNameText;
    handles.tag_quit.FontName = settings.ui.FontNameText;
    handles.tag_quit.FontSize = settings.ui.FontSizeTitle;
    handles.tag_report_second_level.FontName = settings.ui.FontNameText;
    handles.tag_report_second_level.FontSize = settings.ui.FontSizeTitle;
    handles.tag_review_model.FontName = settings.ui.FontNameText;
    handles.tag_review_model.FontSize = settings.ui.FontSizeTitle;
    handles.tag_second_level_model_title.FontName = settings.ui.FontNameText;
    handles.tag_second_level_model_title.FontSize = settings.ui.FontSizeCaption;
    handles.tag_second_level_model.FontName = settings.ui.FontNameText;
    handles.tag_second_level_model.FontSize = settings.ui.FontSizeTitle;
    handles.tag_tools_list.FontName = settings.ui.FontNameText;
    handles.tag_tools_list.FontSize = settings.ui.FontSizeCaption;
    handles.tag_tools_title.FontName = settings.ui.FontNameText;
    handles.tag_tools_title.FontSize = settings.ui.FontSizeCaption;
    hObject.Position(3) = settings.ui.MainWeight;
    hObject.Position(4) = settings.ui.MainHeight;
    hObject.Resize = settings.ui.SwitchResize;
  case 'display'
    handles.button_all.FontName = settings.ui.FontNameText;
    handles.button_all.FontSize = settings.ui.FontSizeTitle;
    handles.button_autoscale.FontName = settings.ui.FontNameText;
    handles.button_autoscale.FontSize = settings.ui.FontSizeTitle;
    handles.button_plot.FontName = settings.ui.FontNameText;
    handles.button_plot.FontName = settings.ui.FontNameText;
    handles.button_plot.FontSize = settings.ui.FontSizeTitle;
    handles.button_plot.FontSize = settings.ui.FontSizeTitle;
    handles.display_plot.FontName = settings.ui.FontNameText;
    handles.display_plot.FontSize = settings.ui.FontSizeCaption;
    handles.list_event_channel.FontName = settings.ui.FontNameText;
    handles.list_event_channel.FontSize = settings.ui.FontSizeText;
    handles.list_wave_channel.FontName = settings.ui.FontNameText;
    handles.list_wave_channel.FontSize = settings.ui.FontSizeText;
    handles.module_display_options.FontName = settings.ui.FontNameText;
    handles.module_display_options.FontSize = settings.ui.FontSizeTitle;
    handles.module_event_channels.FontName = settings.ui.FontNameText;
    handles.module_event_channels.FontSize = settings.ui.FontSizeTitle;
    handles.module_event_options.FontName = settings.ui.FontNameText;
    handles.module_event_options.FontSize = settings.ui.FontSizeTitle;
    handles.module_summary.FontName = settings.ui.FontNameText;
    handles.module_summary.FontSize = settings.ui.FontSizeTitle;
    handles.module_wave_channels.FontName = settings.ui.FontNameText;
    handles.module_wave_channels.FontSize = settings.ui.FontSizeTitle;
    handles.name = [];
    handles.option_extra.FontName = settings.ui.FontNameText;
    handles.option_extra.FontSize = settings.ui.FontSizeText;
    handles.option_integrated.FontName = settings.ui.FontNameText;
    handles.option_integrated.FontSize = settings.ui.FontSizeText;
    handles.prop.axis = [];
    handles.prop.event = [];
    handles.prop.eventchans = [];
    handles.prop.wave = [];
    handles.prop.wavechans=[];
    handles.tag_summary_recording_duration_content.FontName = settings.ui.FontNameText;
    handles.tag_summary_recording_duration_content.FontSize = settings.ui.FontSizeText;
    handles.tag_summary_recording_duration_title.FontName = settings.ui.FontNameEmph;
    handles.tag_summary_recording_duration_title.FontSize = settings.ui.FontSizeText;
    handles.tag_summary_source_file_content.FontName = settings.ui.FontNameText;
    handles.tag_summary_source_file_content.FontSize = settings.ui.FontSizeText;
    handles.tag_summary_source_file_title.FontName = settings.ui.FontNameEmph;
    handles.tag_summary_source_file_title.FontSize = settings.ui.FontSizeText;
    handles.tag_summary_channel_list_title.FontName = settings.ui.FontNameEmph;
    handles.tag_summary_channel_list_title.FontSize = settings.ui.FontSizeText;
    handles.tag_summary_channel_list_content.FontName = settings.ui.FontNameText;
    handles.tag_summary_channel_list_content.FontSize = settings.ui.FontSizeText;
    handles.text_file_summary.FontName = settings.ui.FontNameText;
    handles.text_file_summary.FontSize = settings.ui.FontSizeTitle;
    handles.text_starting_point.FontName = settings.ui.FontNameText;
    handles.text_starting_point.FontSize = settings.ui.FontSizeText;
    handles.text_time_window.FontName = settings.ui.FontNameText;
    handles.text_time_window.FontSize = settings.ui.FontSizeText;
    handles.text_y_max.FontName = settings.ui.FontNameText;
    handles.text_y_max.FontSize = settings.ui.FontSizeText;
    handles.text_y_min.FontName = settings.ui.FontNameText;
    handles.text_y_min.FontSize = settings.ui.FontSizeText;
    hObject.Position(3) = settings.ui.DisplayWeight;
    hObject.Position(4) = settings.ui.DisplayHeight;
    hObject.Resize = 'on';
  case 'review'
    handles.button_all.FontName = settings.ui.FontNameText;
    hObject.Resize = 'on';
end
end