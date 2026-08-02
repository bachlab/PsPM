function [sts] = check_stimulus_presentation_fields(event_json)
%CHECK_STIMULUS_PRESENTATION_FIELDS checks if events.json 
% has the StimulusPresentation fields
  
sts = -1;

if ~isfield(event_json, 'StimulusPresentation')
    return
end

required_fields = { ...
    'ScreenDistance', ...
    'ScreenOrigin', ...
    'ScreenRefreshRate', ...
    'ScreenResolution', ...
    'ScreenSize' ...
    };

if ~all(isfield( event_json.StimulusPresentation, required_fields))
    return
end

sts = 1;

end
