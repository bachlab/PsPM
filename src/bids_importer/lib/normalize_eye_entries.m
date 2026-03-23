function eyes = normalize_eye_entries(eye_data_cell)

    eyes = struct('r', [], 'l', []);

    for i = 1:numel(eye_data_cell)
        entry = eye_data_cell{i};

        if ~isstruct(entry) || ~isfield(entry, 'meta') || ~isstruct(entry.meta)
            warning('Eye entry %d missing metadata; skipping.', i);
            continue
        end

        meta = entry.meta;

        if ~isfield(meta, 'RecordedEye') || isempty(meta.RecordedEye)
            warning('Eye entry %d missing RecordedEye; skipping.', i);
            continue
        end

        switch lower(string(meta.RecordedEye))
            case "right"
                eyes.r = entry;
            case "left"
                eyes.l = entry;
            otherwise
                warning('Eye entry %d has unknown RecordedEye: %s', i, string(meta.RecordedEye));
        end
    end
end