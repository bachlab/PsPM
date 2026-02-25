function data = build_pspm_eye_channels(eye_data_cell)
%BUILD_PSPM_EYE_CHANNELS Build PsPM eye-tracking channels from imported BIDS-like entries.
%
%   data = BUILD_PSPM_EYE_CHANNELS(eye_data_cell)
%
%   Converts eye-tracking data/metadata entries (typically parsed from BIDS
%   physio JSON/TSV pairs) into a PsPM-style channel cell array containing
%   pupil size and gaze coordinate signals for right and/or left eye.
%
%   The function:
%     - Normalizes input entries to a consistent right/left representation
%       (via NORMALIZE_EYE_ENTRIES).
%     - Creates up to 6 channels total (3 signals × 2 eyes) in a stable
%       order: right eye first, then left eye.
%     - For each created channel:
%         * Copies the data vector from the corresponding table column.
%         * Sets hdr.chantype to '<signal>_<side>' (e.g., 'pupil_r').
%         * Populates additional header fields using FILL_EYE_CHANNEL_HEADER
%           (e.g., sampling rate, units, description, gaze range).
%
%   Inputs
%   ------
%   eye_data_cell : cell array
%       Cell array of eye entries. Each entry is expected (typically) to
%       contain:
%         - RecordedEye           : 'right'/'left' recommended (used by the
%                                  normalization step)
%         - Columns               : table containing some/all of:
%                                  'pupil_size', 'x_coordinate', 'y_coordinate'
%         - SamplingFrequency     : numeric (optional)
%         - pupil_size.Description: string/char (optional)
%         - pupil_size.Units      : string/char (optional)
%         - SampleCoordinateUnits : string/char (optional) OR
%           x_coordinate.Units / y_coordinate.Units (optional)
%         - GazeRange.xmin/xmax/ymin/ymax (optional)
%
%   Output
%   ------
%   data : cell array
%       Cell array of PsPM channels. Each channel is a struct with fields:
%         - data{i}.data   : numeric column vector (samples x 1)
%         - data{i}.header : struct with at least:
%                            * chantype (e.g., 'gaze_x_r')
%                            and potentially:
%                            * sr, units, Description, range
%
%   Channel mapping
%   ---------------
%   The following columns (if present) are mapped to channels:
%     - 'pupil_size'   -> chantype 'pupil_<side>'
%     - 'x_coordinate' -> chantype 'gaze_x_<side>'
%     - 'y_coordinate' -> chantype 'gaze_y_<side>'
%
%   Warnings / edge cases
%   ---------------------
%   - If eye_data_cell is empty: warns and returns {}.
%   - If no valid right/left entries are found: warns and returns {}.
%   - If only one eye is present: warns once per encountered side.
%   - If an entry lacks a valid Columns table: warns and skips that eye.
%   - If a required column is missing: warns and skips that channel.
%
%   See also
%   --------
%   NORMALIZE_EYE_ENTRIES, FILL_EYE_CHANNEL_HEADER

data = {};  % output cell array of PsPM channels

if isempty(eye_data_cell)
    warning('No eye data available.');
    return
end

% normalize to "eyes.r" and "eyes.l" (robust to ordering)
eyes = normalize_eye_entries(eye_data_cell);

if isempty(eyes.r) && isempty(eyes.l)
    warning('No valid right/left eye entries found.');
    return
end

% define channel mapping once
sig = struct( ...
    'col',  {'pupil_size', 'x_coordinate', 'y_coordinate'}, ...
    'name', {'pupil',      'gaze_x',       'gaze_y'} ...
);

% create channels in consistent order: right then left
order = {'r','l'};
ch = 0;

for s = 1:numel(order)
    side = order{s};
    m = eyes.(side);
    if isempty(m), continue; end

    % warn if only one eye present
    if xor(isempty(eyes.r), isempty(eyes.l))
        if side == 'r'
            warning('Only right eye data available.');
        else
            warning('Only left eye data available.');
        end
    end

    T = m.Columns;
    if ~istable(T)
        warning('Eye "%s" has no valid Columns table; skipping.', side);
        continue
    end

    for k = 1:numel(sig)
        if ~ismember(sig(k).col, T.Properties.VariableNames)
            warning('Missing column "%s" for eye "%s"; skipping channel.', sig(k).col, side);
            continue
        end

        ch = ch + 1;

        % base channel
        data{ch}.data = T{:, sig(k).col};
        data{ch}.header.chantype = sprintf('%s_%s', sig(k).name, side);

        % populate header fields from metadata
        data{ch}.header = fill_eye_channel_header(data{ch}.header, m, sig(k).name);
    end
end

end
