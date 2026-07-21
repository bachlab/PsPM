function hdr = fill_eye_channel_header(hdr, m, kind)
%FILL_EYE_CHANNEL_HEADER Populate an eye-tracking channel header from BIDS metadata.
%
%   hdr = FILL_EYE_CHANNEL_HEADER(hdr, m, kind)
%
%   Updates fields in the channel header struct `hdr` based on the provided
%   metadata struct `m` and the requested channel `kind`.
%
%   This helper is intended for eye-tracking channels such as pupil size and
%   gaze coordinates. It copies common metadata (e.g., sampling frequency)
%   and then fills channel-specific fields (units, description, range).
%
%   Inputs
%   ------
%   hdr  : struct
%       Channel header to be updated. The function may set/overwrite:
%         - hdr.sr          : sampling rate (Hz)
%         - m.StartTime (numeric scalar)
%         - hdr.Description : channel description (text)
%         - hdr.units       : physical units (string)
%         - hdr.range       : valid data range [min max]
%       The function may also read:
%         - hdr.chantype    : used to resolve gaze coordinate units
%
%   m    : struct
%       Metadata structure, typically parsed from a BIDS sidecar JSON (or
%       equivalent). The function uses the following optional fields:
%         - m.SamplingFrequency (numeric)
%         - m.pupil_size.Description (char/string)
%         - m.pupil_size.Units (char/string)
%         - m.GazeRange.xmin, m.GazeRange.xmax (numeric)
%         - m.GazeRange.ymin, m.GazeRange.ymax (numeric)
%
%   kind : char | string
%       Channel type selector. Supported values:
%         - 'pupil'  : pupil size channel
%         - 'gaze_x' : horizontal gaze coordinate channel
%         - 'gaze_y' : vertical gaze coordinate channel
%
%   Behavior
%   --------
%   1) If m.SamplingFrequency exists and is non-empty, sets hdr.sr.
%   2) For 'pupil':
%        - If m.pupil_size.Description exists, sets hdr.Description.
%        - If m.pupil_size.Units exists, sets hdr.units.
%   3) For 'gaze_x' and 'gaze_y':
%        - Sets hdr.units using get_gaze_units(...), based on metadata and
%          hdr.chantype.
%        - If m.GazeRange contains the corresponding min/max fields, sets
%          hdr.range to [min max].
%
%   Outputs
%   -------
%   hdr : struct
%       Updated channel header struct.
%
%   See also
%   --------
%   GET_GAZE_UNITS
%
%   Notes
%   -----
%   - Missing metadata fields are silently ignored (no error is thrown).
%   - For gaze channels, hdr.chantype should be set before calling this
%     function, as it is passed into GET_GAZE_UNITS to resolve units.

% kind is 'pupil' or 'gaze_x' or 'gaze_y'

% sampling rate for everything if available
if isfield(m, 'SamplingFrequency') && ~isempty(m.SamplingFrequency)
    hdr.sr = m.SamplingFrequency;
end

% StartTime was already validated in get_eyetrack_data
hdr.StartTime = double(m.StartTime);

switch kind
    case 'pupil'
        % description + units from pupil_size metadata if present
        if isfield(m, 'pupil_size')
            if isfield(m.pupil_size, 'Description') && ~isempty(m.pupil_size.Description)
                hdr.Description = m.pupil_size.Description;
            end
            if isfield(m.pupil_size, 'Units') && ~isempty(m.pupil_size.Units)
                hdr.units = m.pupil_size.Units;
            end
        end

    case 'gaze_x'
        hdr.units = get_gaze_units(m, 'x_coordinate', hdr.chantype);
        if isfield(m, 'GazeRange') && isfield(m.GazeRange, 'xmin') && isfield(m.GazeRange, 'xmax')
            hdr.range = [m.GazeRange.xmin, m.GazeRange.xmax];
        end

    case 'gaze_y'
        hdr.units = get_gaze_units(m, 'y_coordinate', hdr.chantype);
        if isfield(m, 'GazeRange') && isfield(m.GazeRange, 'ymin') && isfield(m.GazeRange, 'ymax')
            hdr.range = [m.GazeRange.ymin, m.GazeRange.ymax];
        end
end

end
