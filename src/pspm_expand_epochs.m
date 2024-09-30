function [sts, ep_exp] = pspm_expand_epochs(epoches, expansion, options)

% fn passt nicht zu missing epochs
%   [sts, channel_index]   = pspm_expand_epochs( {data_fn,  channel},    expansion , options)
%   [sts, output_file]     = pspm_expand_epochs( missing_epochs_fn,      expansion , options)
%   [sts, expanded_epochs] = pspm_expand_epochs( missing_epochs,         expansion , options) %
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

switch options.mode
    % missing epochs
    case 'missing_ep'
        % Directly expand the given epochs
        [sts, ep_exp] = expand(epoches, expansion);
        return;

    % missing epoches file
    case 'missing_ep_file'
        % Load missing epochs from file
        data = load(epoches);  % Load the file without specifying a variable
        
        % Assuming the file contains a variable called 'epochs', access it
        % Right name?
        if isfield(data, 'epochs')
            missing_epochs = data.epochs;
        else
            error('File does not contain variable ''epochs''.');
            return;
        end

        if isempty(missing_epochs)
            error('Failed to load missing epochs from file.');
            return;
        end

        % Expand the loaded epochs
        [sts, ep_exp] = expand(missing_epochs, expansion);
        if sts == -1
            error('Failed to expand epochs.');
        end

        % Save expanded missing epoch to a new file with 'e' prefix
        [pathstr, name, ext] = fileparts(epoches);
        output_file = fullfile(pathstr, ['e' name ext]);
        save(output_file, 'ep_exp'); % should i save it as epoch???
        disp(['Expanded epochs saved to: ', output_file]);

        sts = 0;
        return;


    case 'datafile' % rename!!

        % Load channel data
        datafile = epoches{1};
        channel  = epoches{2};
        [lsts, ~, data] = pspm_load_data(datafile, channel);
        if lsts == -1
            error('Failed to load data from file.');
        end

        channel_data = data{1};
        sr = channel_data.header.sr;

        % Find NaN indices
        nan_indices = isnan(channel_data.data);

        % Convert NaN indices to epochs
        nan_epochs = pspm_logical2epochs(nan_indices, sr);

        % Expand the epochs
        [sts, ep_exp] = expand(nan_epochs, expansion);
        if sts == -1
            error('Failed to expand epochs.');
        end

        % Convert expanded epochs back to logical indices
        expanded_indices = pspm_epochs2logical(ep_exp, numel(channel_data.data), sr);

        % Set data to NaN at expanded indices
        channel_data.data(expanded_indices) = NaN;

        % Save the data back to the file
        [sts, out] = pspm_write_channel(datafile, {channel_data}, 'replace'); % add to options 'newfile'?
        varargout{2} = 23 % channel_data.data;
        return;


    otherwise
        error('Unknown mode in options.');
        return;
end

end


function [sts, ep_exp] = expand(ep, expansion)
% Helper function to expand epochs by the specified pre and post times
% and merge overlapping epochs.
% Also ensures that no epoch starts before time 0.

% Initialize status
sts = -1;

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
expanded_epochs_temp(expanded_epochs_temp(:,1) < 0, 1) = 0; % or <1???

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

% Success
sts = 0;
end
