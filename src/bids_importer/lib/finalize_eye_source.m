function [infos, data] = finalize_eye_source(infos, data, eye_data_cell)
%FINALIZE_EYE_SOURCE Finalize imported eye-tracking source metadata and headers.
%
%   [infos, data] = FINALIZE_EYE_SOURCE(infos, data, eye_data_cell)
%
%   Adds eye-related information under `infos.source.*` and performs basic
%   consistency checks on imported eye-tracking channels. In particular, it:
%
%     - Computes per-channel NaN ratios and stores them in
%       infos.source.chan_stats.
%     - Normalizes right/left eye metadata entries (via NORMALIZE_EYE_ENTRIES).
%     - Checks gaze range consistency across eyes and stores a preferred
%       gaze coordinate range in infos.source.gaze_coords.
%     - Stores pupil processing method (if provided by metadata) in
%       infos.source.elcl_proc.
%     - Derives which eyes were observed (left/right/both) and stores it in
%       infos.source.eyesObserved.
%     - Selects a "best eye" using NaN ratio (via EYE_WITH_SMALLER_NAN_RATIO)
%       and stores it in infos.source.best_eye.
%     - Ensures every channel header contains StartTime; if missing, sets it
%       to 0 for all channels. If StartTime exists, checks consistency across
%       channels and warns if they differ.
%
%   Inputs
%   ------
%   infos : struct
%       PsPM infos structure. This function initializes/overwrites
%       `infos.source` with a struct containing eye-related fields.
%
%   data : cell array
%       Cell array of imported channel structs. Each element is expected to
%       have at least:
%         - data{i}.data            : numeric vector/matrix (samples x 1)
%         - data{i}.header          : struct
%         - data{i}.header.StartTime (optional)
%
%   eye_data_cell : cell array
%       Collection of eye metadata entries from earlier import stages. This
%       is passed to NORMALIZE_EYE_ENTRIES, which is expected to return a
%       struct with fields:
%         - eyes.r : metadata struct for right eye (or [])
%         - eyes.l : metadata struct for left eye (or [])
%
%   Outputs
%   -------
%   infos : struct
%       Updated infos structure with `infos.source` populated. Common fields:
%         - infos.source.chan          : reserved for channel labels (currently {})
%         - infos.source.chan_stats    : {N x 1} cell array of structs, each with:
%                                        .nan_ratio = (#NaN samples) / (#samples)
%         - infos.source.gaze_coords   : gaze range struct (if available)
%         - infos.source.elcl_proc     : pupil fit / processing method (lowercase)
%         - infos.source.eyesObserved  : 'l', 'r', or 'lr'
%         - infos.source.best_eye      : best eye label (as returned by helper)
%         - infos.source.type          : fixed string, 'BIDS (json/tsv)'
%
%   data : cell array
%       Same cell array as input, potentially modified to include
%       data{i}.header.StartTime when missing.
%
%   Warnings
%   --------
%   - If `data` is empty, emits a warning and returns early.
%   - If both eyes provide GazeRange and they differ, warns.
%   - If StartTime exists but differs across channels, warns.
%
%   See also
%   --------
%   NORMALIZE_EYE_ENTRIES, EYE_WITH_SMALLER_NAN_RATIO

% Adds infos.source.* for eye channels and ensures StartTime exists.
if isempty(data)
    warning('No data for physio eye data was imported.');
    return
end

% --- chan_stats (nan_ratio) ---
infos.source = struct();
infos.source.chan = {};
infos.source.chan_stats = cell(numel(data),1);

for i = 1:numel(data)
    x = data{i}.data;
    n_data = size(x,1);
    n_inv  = sum(isnan(x));
    infos.source.chan_stats{i,1} = struct('nan_ratio', n_inv / max(n_data,1));
end

% --- normalize right/left metadata ---
eyes = normalize_eye_entries(eye_data_cell);  % from earlier (returns .r .l)

% --- gaze range consistency + store ---
if ~isempty(eyes.r) && ~isempty(eyes.l) && isfield(eyes.r,'GazeRange') && isfield(eyes.l,'GazeRange')
    if ~isequal(eyes.r.GazeRange, eyes.l.GazeRange)
        warning("GazeRange is not equal");
    end
end

% prefer right if present, else left
m = eyes.r; if isempty(m), m = eyes.l; end
if ~isempty(m) && isfield(m,'GazeRange')
    infos.source.gaze_coords = m.GazeRange;
end

% --- pupil processing method ---
if ~isempty(m)
    if isfield(m,'PupilFitMethod') && ~isempty(m.PupilFitMethod)
        infos.source.elcl_proc = lower(string(m.PupilFitMethod));
    elseif isfield(m,'ElclProc') && ~isempty(m.ElclProc)
        infos.source.elcl_proc = lower(string(m.ElclProc));
    end
end

% --- eyesObserved ---
% derive from available eyes (.r/.l), not from num_eyes
hasR = ~isempty(eyes.r);
hasL = ~isempty(eyes.l);
if hasR && hasL
    infos.source.eyesObserved = 'lr';
elseif hasR
    infos.source.eyesObserved = 'r';
elseif hasL
    infos.source.eyesObserved = 'l';
end

% --- best eye by nan ratio (your function) ---
infos.source.best_eye = eye_with_smaller_nan_ratio(data, infos.source.eyesObserved);
infos.source.type = 'BIDS (json/tsv)';

% --- StartTime consistency: ensure StartTime exists on all channels ---
if isfield(data{1}.header,'StartTime')
    st = cellfun(@(x) x.header.StartTime, data, 'UniformOutput', false);
    if ~isequal(st{:})
        warning('Not all data have the same StartTime. Please check the input data.');
    end
else
    for i = 1:numel(data)
        data{i}.header.StartTime = 0;
    end
end

end
