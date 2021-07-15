function pspm_ui(hObject,handles,window)

% pspm_ui controls the UI of the referred handle
% The PsPM Team, UCL

%% Parameters for UI optimisation
if ispc
    FontSizeTitle = 11;
    FontSizeText = 10;
    FontSizeCaption = 9;
    FontSizeAttr = 9;
    DisplayUnit = 'points';
    FontNameText = 'Segoe UI';
    FontNameEmph = 'Segoe UI';
    MainWeight = 500;
    MainHeight = 500*0.8;
    DisplayWeight = 250;
    DisplayHeight = 250/5;
elseif ismac
    FontSizeTitle = 16;
    FontSizeText = 14;
    FontSizeCaption = 12;
    FontSizeAttr = 13;
    FontNameText = 'Helvetica Neue';
    FontNameEmph = 'Helvetica-Light';
    DisplayUnit = 'normalized';
    MainWeight = 0.2819; % adjust width
    MainHeight = 0.4425; % adjust height
    DisplayWeight = 190;
    DisplayHeight = 60;
else
    FontSizeTitle = 11;
    FontSizeText = 10;
    FontSizeCaption = 9;
    FontSizeAttr = 8;
    FontNameText = 'DejaVu Sans';
    FontNameEmph = 'DejaVu Sans';
    MainWeight = 0.5;
    MainHeight = 0.5;
    DisplayWeight = 1.2;
    DisplayHeight = 1;
end

switch window
    case 'main'
        handles.figure1.Units = DisplayUnit;
        handles.tag_attribution.FontName = FontNameText;
        handles.tag_attribution.FontSize = FontSizeAttr;
        %handles.tag_attribution.Visible = 'off';
        handles.tag_attribution.HorizontalAlignment = 'center';
        attribution_disp_text = sprintf(['Version 5.1.1, Build ',datestr(now,'ddmmyyyy'),' with MATLAB 2021a, ',...
        'The PsPM Team, University College London']);
        handles.tag_attribution.String = attribution_disp_text;
        handles.tag_batch.FontName = FontNameText;
        handles.tag_batch.FontSize = FontSizeTitle;
        handles.tag_contrast_manager.FontName = FontNameText;
        handles.tag_contrast_manager.FontSize = FontSizeTitle;
        handles.tag_data_preparation_list.FontName = FontNameText;
        handles.tag_data_preparation_list.FontSize = FontSizeCaption;
        handles.tag_data_preparation_title.FontName = FontNameText;
        handles.tag_data_preparation_title.FontSize = FontSizeCaption;
        handles.tag_data_preprocessing_list.FontName = FontNameText;
        handles.tag_data_preprocessing_list.FontSize = FontSizeCaption;
        handles.tag_data_preprocessing_title.FontName = FontNameText;
        handles.tag_data_preprocessing_title.FontSize = FontSizeCaption;
        handles.tag_export_statistics.FontName = FontNameText;
        handles.tag_export_statistics.FontSize = FontSizeTitle;
        handles.tag_feedback.FontName = FontNameText;
        handles.tag_feedback.FontSize = FontSizeTitle;
        handles.tag_first_level_models_list.FontName = FontNameText;
        handles.tag_first_level_models_list.FontSize = FontSizeCaption;
        handles.tag_first_level_models_title.FontName = FontNameText;
        handles.tag_first_level_models_title.FontSize = FontSizeCaption;
        handles.tag_help.FontName = FontNameText;
        handles.tag_help.FontSize = FontSizeTitle;
        handles.tag_models_for_sf.FontName = FontNameText;
        handles.tag_models_for_sf.FontSize = FontSizeTitle;
        handles.tag_more_title.FontName = FontNameText;
        handles.tag_more_title.FontSize = FontSizeCaption;
        handles.tag_non_linear_scr_model.FontName = FontNameText;
        handles.tag_non_linear_scr_model.FontSize = FontSizeTitle;
        handles.tag_PsPM.FontName = FontNameText;
        handles.tag_quit.FontName = FontNameText;
        handles.tag_quit.FontSize = FontSizeTitle;
        handles.tag_report_second_level.FontName = FontNameText;
        handles.tag_report_second_level.FontSize = FontSizeTitle;
        handles.tag_review_model.FontName = FontNameText;
        handles.tag_review_model.FontSize = FontSizeTitle;
        handles.tag_second_level_model_title.FontName = FontNameText;
        handles.tag_second_level_model_title.FontSize = FontSizeCaption;
        handles.tag_second_level_model.FontName = FontNameText;
        handles.tag_second_level_model.FontSize = FontSizeTitle;
        handles.tag_tools_list.FontName = FontNameText;
        handles.tag_tools_list.FontSize = FontSizeCaption;
        handles.tag_tools_title.FontName = FontNameText;
        handles.tag_tools_title.FontSize = FontSizeCaption;
        hObject.Position(3) = MainWeight;
        hObject.Position(4) = MainHeight;
        hObject.Resize = 'off';
    case 'display'
        handles.button_all.FontName = FontNameText;
        handles.button_all.FontSize = FontSizeTitle;
        handles.button_autoscale.FontName = FontNameText;
        handles.button_autoscale.FontSize = FontSizeTitle;
        handles.button_plot.FontName = FontNameText;
        handles.button_plot.FontName = FontNameText;
        handles.button_plot.FontSize = FontSizeTitle;
        handles.button_plot.FontSize = FontSizeTitle;
        handles.display_plot.FontName = FontNameText;
        handles.display_plot.FontSize = FontSizeCaption;
        handles.list_event_channel.FontName = FontNameText;
        handles.list_event_channel.FontSize = FontSizeText;
        handles.list_wave_channel.FontName = FontNameText;
        handles.list_wave_channel.FontSize = FontSizeText;
        handles.module_display_options.FontName = FontNameText;
        handles.module_display_options.FontSize = FontSizeTitle;
        handles.module_event_channels.FontName = FontNameText;
        handles.module_event_channels.FontSize = FontSizeTitle;
        handles.module_event_options.FontName = FontNameText;
        handles.module_event_options.FontSize = FontSizeTitle;
        handles.module_summary.FontName = FontNameText;
        handles.module_summary.FontSize = FontSizeTitle;
        handles.module_wave_channels.FontName = FontNameText;
        handles.module_wave_channels.FontSize = FontSizeTitle;
        handles.name=[];
        handles.option_extra.FontName = FontNameText;
        handles.option_extra.FontSize = FontSizeText;
        handles.option_integrated.FontName = FontNameText;
        handles.option_integrated.FontSize = FontSizeText;
        handles.prop.axis=[];
        handles.prop.event=[];
        handles.prop.eventchans=[];
        handles.prop.wave=[];
        handles.prop.wavechans=[];
        handles.tag_summary_recording_duration_content.FontName = FontNameText;
        handles.tag_summary_recording_duration_content.FontSize = FontSizeText;
        handles.tag_summary_recording_duration_title.FontName = FontNameEmph;
        handles.tag_summary_recording_duration_title.FontSize = FontSizeText;
        handles.tag_summary_source_file_content.FontName = FontNameText;
        handles.tag_summary_source_file_content.FontSize = FontSizeText;
        handles.tag_summary_source_file_title.FontName = FontNameEmph;
        handles.tag_summary_source_file_title.FontSize = FontSizeText;
        handles.tag_summary_channel_list_title.FontName = FontNameEmph;
        handles.tag_summary_channel_list_title.FontSize = FontSizeText;
        handles.tag_summary_channel_list_content.FontName = FontNameText;
        handles.tag_summary_channel_list_content.FontSize = FontSizeText;
        handles.text_file_summary.FontName = FontNameText;
        handles.text_file_summary.FontSize = FontSizeTitle;
        handles.text_starting_point.FontName = FontNameText;
        handles.text_starting_point.FontSize = FontSizeText;
        handles.text_time_window.FontName = FontNameText;
        handles.text_time_window.FontSize = FontSizeText;
        handles.text_y_max.FontName = FontNameText;
        handles.text_y_max.FontSize = FontSizeText;
        handles.text_y_min.FontName = FontNameText;
        handles.text_y_min.FontSize = FontSizeText;
        hObject.Position(3) = DisplayWeight;
        hObject.Position(4) = DisplayHeight;
        set(hObject,'Resize','on');
end

end
