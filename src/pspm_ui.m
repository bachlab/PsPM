function pspm_ui(hObject,handles,window)

% pspm_ui controls the UI of the referred handle

%% Parameters for UI optimisation
if ispc
    FontSizeTitle = 11;
    FontSizeText = 10;
    FontSizeCaption = 9;
    FontNameDisplay = "Segoe UI";
    FontNameEmph = "Segoe UI";
    MainWeight = 0.5;
    MainHeight = 0.5;
elseif ismac
    FontSizeTitle = 16;
    FontSizeText = 14;
    FontSizeCaption = 12;
    FontSizeAttr = 10;
    FontNameDisplay = "Helvetica Neue";
    FontNameEmph = "Helvetica-Light";
    MainWeight = 0.2819; % adjust width
    MainHeight = 0.4425; % adjust height
else
    FontSizeTitle = 10;
    FontNameDisplay = "Verdana";
end

switch window
    case 'main'
        hObject.Position(3) = MainWeight;
        hObject.Position(4) = MainHeight;
        handles.tag_PsPM.FontName = FontNameDisplay;
        handles.tag_attribution.FontName = FontNameDisplay;
        handles.tag_attribution.FontSize = FontSizeAttr;
        handles.tag_batch.FontName = FontNameDisplay;
        handles.tag_batch.FontSize = FontSizeTitle;
        handles.tag_contrast_manager.FontName = FontNameDisplay;
        handles.tag_contrast_manager.FontSize = FontSizeTitle;
        handles.tag_data_preparation_list.FontName = FontNameDisplay;
        handles.tag_data_preparation_list.FontSize = FontSizeCaption;
        handles.tag_data_preparation_title.FontName = FontNameDisplay;
        handles.tag_data_preparation_title.FontSize = FontSizeCaption;
        handles.tag_data_preprocessing_list.FontName = FontNameDisplay;
        handles.tag_data_preprocessing_list.FontSize = FontSizeCaption;
        handles.tag_data_preprocessing_title.FontName = FontNameDisplay;
        handles.tag_data_preprocessing_title.FontSize = FontSizeCaption;
        handles.tag_export_statistics.FontName = FontNameDisplay;
        handles.tag_export_statistics.FontSize = FontSizeTitle;
        handles.tag_feedback.FontName = FontNameDisplay;
        handles.tag_feedback.FontSize = FontSizeTitle;
        handles.tag_first_level_models_list.FontName = FontNameDisplay;
        handles.tag_first_level_models_list.FontSize = FontSizeCaption;
        handles.tag_first_level_models_title.FontName = FontNameDisplay;
        handles.tag_first_level_models_title.FontSize = FontSizeCaption;
        handles.tag_help.FontName = FontNameDisplay;
        handles.tag_help.FontSize = FontSizeTitle;
        handles.tag_models_for_sf.FontName = FontNameDisplay;
        handles.tag_models_for_sf.FontSize = FontSizeTitle;
        handles.tag_more_title.FontName = FontNameDisplay;
        handles.tag_more_title.FontSize = FontSizeCaption;
        handles.tag_non_linear_scr_model.FontName = FontNameDisplay;
        handles.tag_non_linear_scr_model.FontSize = FontSizeTitle;
        handles.tag_quit.FontName = FontNameDisplay;
        handles.tag_quit.FontSize = FontSizeTitle;
        handles.tag_report_second_level.FontName = FontNameDisplay;
        handles.tag_report_second_level.FontSize = FontSizeTitle;
        handles.tag_review_model.FontName = FontNameDisplay;
        handles.tag_review_model.FontSize = FontSizeTitle;
        handles.tag_second_level_model_title.FontName = FontNameDisplay;
        handles.tag_second_level_model_title.FontSize = FontSizeCaption;
        handles.tag_second_level_model.FontName = FontNameDisplay;
        handles.tag_second_level_model.FontSize = FontSizeTitle;
        handles.tag_tools_list.FontName = FontNameDisplay;
        handles.tag_tools_list.FontSize = FontSizeCaption;
        handles.tag_tools_title.FontName = FontNameDisplay;
        handles.tag_tools_title.FontSize = FontSizeCaption;
        hObject.Resize = 'off';
    case 'display'
        handles.button_all.FontName = FontNameDisplay;
        handles.button_all.FontSize = FontSizeTitle;
        handles.button_autoscale.FontName = FontNameDisplay;
        handles.button_autoscale.FontSize = FontSizeTitle;
        handles.button_plot.FontName = FontNameDisplay;
        handles.button_plot.FontName = FontNameDisplay;
        handles.button_plot.FontSize = FontSizeTitle;
        handles.button_plot.FontSize = FontSizeTitle;
        handles.display_plot.FontName = FontNameDisplay;
        handles.display_plot.FontSize = FontSizeCaption;
        handles.list_event_channel.FontName = FontNameDisplay;
        handles.list_event_channel.FontSize = FontSizeText;
        handles.list_wave_channel.FontName = FontNameDisplay;
        handles.list_wave_channel.FontSize = FontSizeText;
        handles.module_display_options.FontName = FontNameDisplay;
        handles.module_display_options.FontSize = FontSizeTitle;
        handles.module_event_channels.FontName = FontNameDisplay;
        handles.module_event_channels.FontSize = FontSizeTitle;
        handles.module_event_options.FontName = FontNameDisplay;
        handles.module_event_options.FontSize = FontSizeTitle;
        handles.module_summary.FontName = FontNameDisplay;
        handles.module_summary.FontSize = FontSizeTitle;
        handles.module_wave_channels.FontName = FontNameDisplay;
        handles.module_wave_channels.FontSize = FontSizeTitle;
        handles.option_extra.FontName = FontNameDisplay;
        handles.option_extra.FontSize = FontSizeText;
        handles.option_integrated.FontName = FontNameDisplay;
        handles.option_integrated.FontSize = FontSizeText;
        handles.text_file_summary.FontName = FontNameDisplay;
        handles.text_file_summary.FontSize = FontSizeTitle;
        handles.text_starting_point.FontName = FontNameDisplay;
        handles.text_starting_point.FontSize = FontSizeText;
        handles.text_time_window.FontName = FontNameDisplay;
        handles.text_time_window.FontSize = FontSizeText;
        handles.text_y_max.FontName = FontNameDisplay;
        handles.text_y_max.FontSize = FontSizeText;
        handles.text_y_min.FontName = FontNameDisplay;
        handles.text_y_min.FontSize = FontSizeText;
        handles.tag_summary_source_file_title.FontName = FontNameEmph;
        handles.tag_summary_source_file_title.FontSize = FontSizeText;
        handles.tag_summary_source_file_content.FontName = FontNameDisplay;
        handles.tag_summary_source_file_content.FontSize = FontSizeText;
        handles.tag_summary_recording_duration_title.FontName = FontNameEmph;
        handles.tag_summary_recording_duration_title.FontSize = FontSizeText;
        handles.tag_summary_recording_duration_content.FontName = FontNameDisplay;
        handles.tag_summary_recording_duration_content.FontSize = FontSizeText;
        handles.prop.wave=[];
        handles.prop.event=[];
        handles.prop.wavechans=[];
        handles.prop.eventchans=[];
        handles.prop.axis=[];
        handles.name=[];
        set(hObject,'Resize','on');
end

end

