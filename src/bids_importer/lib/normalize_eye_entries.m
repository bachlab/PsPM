function eyes = normalize_eye_entries(eye_data_cell)
% Returns struct with fields .r and .l containing the chosen metadata entry for each eye.

eyes = struct('r', [], 'l', []);

for i = 1:numel(eye_data_cell)
    e = eye_data_cell{i};

    if ~isstruct(e) || ~isfield(e, 'RecordedEye') || isempty(e.RecordedEye)
        warning('Eye entry %d missing RecordedEye; skipping.', i);
        continue
    end

    side = lower(string(e.RecordedEye));
    if side == "right"
        if isempty(eyes.r)
            eyes.r = e;
        else
            warning('Multiple right-eye entries found; keeping the first.');
        end
    elseif side == "left"
        if isempty(eyes.l)
            eyes.l = e;
        else
            warning('Multiple left-eye entries found; keeping the first.');
        end
    else
        warning('Unknown RecordedEye "%s" in entry %d; skipping.', side, i);
    end
end

% If RecordedEye wasn’t reliable but there is exactly 1 entry, use it for both
if isempty(eyes.r) && isempty(eyes.l) && numel(eye_data_cell) == 1
    warning('RecordedEye not usable; using the only entry as both r and l.');
    eyes.r = eye_data_cell{1};
    eyes.l = eye_data_cell{1};
elseif numel(eye_data_cell) == 1
    % single-eye case: mirror onto missing side (so downstream doesn’t crash)
    if isempty(eyes.r) && ~isempty(eyes.l), eyes.r = eyes.l; end
    if isempty(eyes.l) && ~isempty(eyes.r), eyes.l = eyes.r; end
end

end
