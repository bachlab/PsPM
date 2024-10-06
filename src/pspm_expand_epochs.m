function [sts, ep_exp] = pspm_expand_epochs(varargin)

% fn passt nicht zu missing epochs
%   [sts, output_file]     = pspm_expand_epochs( missing_epochs_fn,      expansion , options)
%   [sts, expanded_epochs] = pspm_expand_epochs( missing_epochs,         expansion , options) 
%   [sts, channel_index]   = pspm_expand_epochs( filename,  channel,    expansion , options)
%   options.mode =  'datafile'
%                   'missing_ep_file'
%                   'missing_ep'

global settings
if isempty(settings)
  pspm_init;
end

sts = -1;

if nargin < 3
  warning('ID:invalid_input', 'Not enough input arguments');
  return;
end




if nargin == 3
    
    expansion = varargin{2};
    options   = varargin{3};

    switch options.mode
        % missing epochs
        case 'missing_ep'
            % Directly expand the given epochs
            epochs = varargin{1};
            [ests, ep_exp] = expand(epochs, expansion);

            if ests == -1
                error("Failed to expand epochs.");
                return;
            end 
            
            sts = 1;
            return;

            % missing epoches file
        case 'missing_ep_file'
            % Load missing epochs from file
            filename = varargin{1};

            [lsts, epochs] = pspm_get_timing('file', filename);
           
            
            if lsts == -1
                error("Epoch could not be loaded");
                return;
            end 

            % Expand the loaded epochs
            [ests, ep_exp] = expand(epochs.epochs, expansion);
            if ests == -1
                error('Failed to expand epochs.');
                return;
            end

            % Save expanded missing epoch to a new file with 'e' prefix
            [pathstr, name, ext] = fileparts(filename);
            output_file = fullfile(pathstr, ['e' name ext]);
            save(output_file, 'ep_exp'); % should i save it as epoch???
            disp(['Expanded epochs saved to: ', output_file]);

            sts = 1;
            return;
    end
end

if nargin == 4 %&& options.mode == 'datafile' % rename!!
   
    % Load channel data
    filename = varargin{1};
    channel  = varargin{2};
    expansion = varargin{3};
    [lsts, ~, data] = pspm_load_data(filename, channel);
    if lsts == -1
        error('Failed to load data from file.');
        return;
    end

    channel_data = data{1};
    sr = channel_data.header.sr;

    % Find NaN indices
    nan_indices = isnan(channel_data.data);

    % Convert NaN indices to epochs
    nan_epochs = pspm_logical2epochs(nan_indices, sr);

    % Expand the epochs
    [ests, ep_exp] = expand(nan_epochs, expansion);
    if ests == -1
        error('Failed to expand epochs.');
    end

    % Convert expanded epochs back to logical indices
    expanded_indices = pspm_epochs2logical(ep_exp, numel(channel_data.data), sr);

    % Set data to NaN at expanded indices
    channel_data.data(logical(expanded_indices)) = NaN;

    % Save the data back to the file
    opt = struct();
    [wsts, ~] = pspm_write_channel(filename, {channel_data}, 'replace',opt); % add to options 'newfile'?
     % channel_data.data;

    if wsts == -1
        error('Failed to write the new channel.');
        return
    end

    sts = 1;
    return;


else
    error('Unknown mode in options.'); 
    return;
end


end



function [ests, ep_exp] = expand(ep, expansion)
% Helper function to expand epochs by the specified pre and post times
% and merge overlapping epochs.
% Also ensures that no epoch starts before time 0.

% Initialize status of expand
ests = -1;
ep_exp = [];

% Check if epochs matrix and expansion vector are valid
if isempty(ep) || numel(expansion) ~= 2
    error('Invalid input to expand function.');
    return;
end

% Expand epochs
pre = expansion(1);
post = expansion(2);
expanded_epochs_temp = [ep(:,1) - pre, ep(:,2) + post];

%
% Ensure that the start of any epoch is not negative

[ksts, expanded_epochs_temp] = pspm_get_timing('epochs',expanded_epochs_temp , 'seconds') ;
if ksts == -1 
    error('Offsets must be larger than onsets')
    return
end

% If there is only one epoch, no need for merging
if size(expanded_epochs_temp, 1) == 1
    ep_exp = expanded_epochs_temp;
    ests = 1;
    return;
end



% Merge overlapping epochs
ep_exp = expanded_epochs_temp(1, :);  % Start with the first epoch
for i = 2:size(expanded_epochs_temp, 1)
    % If the current epoch overlaps with the previous, merge them
    if ep_exp(end, 2) >= expanded_epochs_temp(i, 1)
        ep_exp(end, 2) = max(ep_exp(end, 2), expanded_epochs_temp(i, 2));
    else
        % Otherwise, add the current epoch as a new row
        ep_exp = [ep_exp; expanded_epochs_temp(i, :)];
    end
end

ests = 1;
end
