function [sts, segments, sessions] = pspm_extract_segments_core(data, onsets, segment_length, missing)
% ● Description
%   pspm_extract_segments_core extracts segments of equal length from a
%   cell array of data
% ● Format
%   [sts, segments, session_index] = pspm_extract_segments_core(data, onsets, segment_length, missing)
% ● Arguments
%          data:  [cell] a cell array of data vectors of arbitrary length
%        onsets:  [cell] a cell array of the same size as 'data', with
%                        segment onsets defined in terms of a numerical
%                        index of arbitrary length
% segment_length: [integer] an integer specificying the length of the
%                  data segments
%        missing: [cell array] OPTIONAL a logical index of missing values
%                        which will be set to NaN in the extracted segments.
%                        A cell array of the same size as 'data', with
%                        elements of the same size as the elements of
%                        'data'
% ● History
%   Introduced in PsPM version 6.2

% Initialise --------------------------------------------------------------
sts = -1;

segments = []; % Initialize segments matrix
sessions = []; % Initialize session index vector

% check input -------------------------------------------------------------
if nargin < 4
    missing = cell(size(data));
    for i = 1:length(data)
        missing{i} = zeros(size(data{i}));
    end
end

% Verify if the inputs have the same size
if ~(length(data) == length(onsets) && length(data) == length(missing))
    warning('pspm_extract_segments_core:SizeMismatch','The cell arrays data, onsets, and missing must have the same size.');
    return;
end

% Iterate through each cell of data ---------------------------------------
for i = 1:length(data)
    currentData = data{i}(:)';
    currentOnsets = onsets{i};
    currentMissing = missing{i}(:)';

    % Check for valid onsets
    if any(currentOnsets < 1) || any(currentOnsets > length(currentData))
        warning('pspm_extract_segments_core:InvalidOnset','Onset values must be between 1 and the length of the corresponding data vector.');
        return;
    end

    % Check if the length of the current missing data matches the length of the current data
    if length(currentMissing) ~= length(currentData)
        warning('pspm_extract_segments_core:MissingDataLengthMismatch', 'The length of the missing data vector must be the same as the corresponding data vector in cell.');
        return;
    end

    % Handle missing data
    if any(currentMissing)
        currentData(currentMissing) = NaN;
    end

    % Extract segments
    for j = 1:length(currentOnsets)
        onset = currentOnsets(j);
        endIndex = onset + segment_length - 1;

        % Check if the segment extends beyond the data
        if endIndex > length(currentData)
            segment = [currentData(onset:end), NaN(1, endIndex - length(currentData))];
        else
            segment = currentData(onset:endIndex);
        end

        % Add to segments and sessions
        segments = [segments; segment];
        sessions = [sessions; i];
    end
end
sts = 1;
end
