function sts = pspm_doc_gen(varargin)
% ● Description
%   pspm_doc_gen generates the documents of help text 
%   in pspm functions into markdown files.
% ● Format
%   sts = pspm_doc_gen()
%   sts = pspm_doc_gen({'pspm_dcm'})
%   sts = pspm_doc_gen('/Users/pspm/')
%   sts = pspm_doc_gen({'pspm_dcm'}, '/Users/pspm/')
% ● History
%   Introduced in PsPM 7.0
%   Written in 2024 by Teddy

global settings
if isempty(settings)
  pspm_init;
end
sts = 1;
switch nargin
  case 0
    savepath = [settings.path, '/ref'];
    mkdir(savepath);
  case 1
    switch class(varargin{1})
      case 'char'
        savepath = varargin{1};
      case 'cell'
        savepath = [settings.path, '/ref'];
        mkdir(savepath);
        list_func = varargin{1};
    end
  case 2
    list_func = varargin{1};
    savepath = varargin{2};
end
if ~exist('list_func', 'var')
 list_func = { ...
     'pspm_import', ...
     'pspm_trim', ... 
     'pspm_split_sessions', ... 
     'pspm_merge', ... 
     'pspm_rename', ... 
     'pspm_combine_markerchannels', ... 
     'pspm_convert_area2diameter', ... 
     'pspm_convert_au2unit', ... 
     'pspm_convert_ecg2hb', ... 
     'pspm_convert_ecg2hb_amri', ... 
     'pspm_convert_gaze', ... 
     'pspm_convert_hb2hp', ... 
     'pspm_convert_ppg2hb', ... 
     'pspm_emg_pp', ... 
     'pspm_expand_epochs', ...
     'pspm_find_sounds', ... 
     'pspm_find_valid_fixations', ... 
     'pspm_gaze_pp', ... 
     'pspm_interpolate', ... 
     'pspm_pp', ... 
     'pspm_pupil_correct_eyelink', ... 
     'pspm_pupil_pp', ... 
     'pspm_remove_epochs', ... 
     'pspm_resp_pp', ... 
     'pspm_scr_pp', ... 
     'pspm_dcm', ... 
     'pspm_glm', ... 
     'pspm_process_illuminance', ... 
     'pspm_sf', ... 
     'pspm_tam', ... 
     'pspm_export', ... 
     'pspm_extract_segments', ...
     'pspm_get_markerinfo' ...
     };
end
for i_func = 1:length(list_func)
  options = struct();
  options.path = savepath;
  options.post = 1;
  disp(list_func{i_func});
  sts_temp = pspm_doc(list_func{i_func}, options);
  if sts_temp == -1
    sts = -1;
  end
end
end