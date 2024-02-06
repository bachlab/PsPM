function [segments, sessions] = pspm_extract_segments_core(data, onsets, segment_length, missing)
    % Verify if the inputs have the same size
    if ~(length(data) == length(onsets) && length(data) == length(missing))
        warning('pspm_extract_segments_core:SizeMismatch','The cell arrays data, onsets, and missing must have the same size.');
        segments = []; % Return empty outputs if there's a size mismatch
        sessions = [];
        return;
    end

    segments = []; % Initialize segments matrix
    sessions = []; % Initialize session index vector

    % Iterate through each cell of data
    for i = 1:length(data)
        currentData = data{i};
        currentOnsets = onsets{i};
        currentMissing = missing{i};

        % Check for valid onsets
        if any(currentOnsets < 1) || any(currentOnsets > length(currentData))
            warning('pspm_extract_segments_core:InvalidOnset','Onset values must be between 1 and the length of the corresponding data vector.');
            continue;
        end

        % Check if the length of the current missing data matches the length of the current data
        if length(currentMissing) ~= length(currentData)
            warning('pspm_extract_segments_core:MissingDataLengthMismatch', 'The length of the missing data vector must be the same as the corresponding data vector in cell.');
            continue;
        end

        % Handle missing data
        currentData(currentMissing) = NaN;

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
            sessions = [sessions, i];
        end
    end
end
