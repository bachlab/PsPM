function data_mat = set_blinks_saccades_to_nan(data_mat, column_names, mask_chans, fn_is_left)
    % set_blinks_saccades_to_nan sets data rows corresponding to blink/saccade periods to NaN values.
    % This is performed for each eye separately. The function assumes that channel names for blink
    % channels contain 'blink' in them. Similarly, channel names for saccade channels must contain
    % 'saccade'.
    %
    % Inputs
    % ------
    % data_mat: Matrix containing both data and blink/saccade columns. All the columns in data_mat
    %           are assumed to belong to either left or to right eye. Example columns are pupil_l,
    %           gaze_x_r, etc.
    % column_names: Name of each column in the input data_mat.
    % mask_chans: Names of blink and saccade channels.
    %
    % Optional Inputs
    % ---------------
    % fn_is_left: Function that takes a LOWERCASED channel name as input and returns true if the channel
    %             name belongs to left eye. Otherwise, it returns false. By default, this function checks
    %             if the channel name ends with '_l'.
    %
    % Output
    % ------
    % data_mat: Same data matrix data_mat except that
    % 
    %   - all elements in left data columns (except blink/saccade) that correspond to left
    %     blink or saccade rows are set to NaN
    %
    %   - all elements in right data columns (except blink/saccade) that correspond to right
    %     blink or saccade rows are set to NaN
    if nargin == 3
        fn_is_left = @(x) strcmp(x(end-1:end), '_l');
    end

    column_names = cellfun(@(x) lower(x), column_names, 'uni', 0);
    mask_chans = cellfun(@(x) lower(x), mask_chans, 'uni', 0);

    col_ids = [];
    for chan = mask_chans
        idx = find(strcmpi(column_names, chan{1}));
        if ~isempty(idx)
            col_ids(end + 1) = idx;
        end
    end
    maskmat_left = [];
    maskmat_right = [];
    for i = 1:numel(col_ids)
        idx = col_ids(i);
        chan = mask_chans{i};
        if fn_is_left(chan)
            maskmat_left(:, end + 1) = data_mat(:, idx);
        else
            maskmat_right(:, end + 1) = data_mat(:, idx);
        end
    end
    maskmat_left = logical(maskmat_left);
    maskmat_right = logical(maskmat_right);

    left_data_cols = cell2mat(cellfun(@(x) fn_is_left(x), column_names, 'uni', 0));
    right_data_cols = cell2mat(cellfun(@(x) ~fn_is_left(x), column_names, 'uni', 0));
    left_data_cols = left_data_cols & ~contains(column_names, 'blink') & ~contains(column_names, 'saccade');
    right_data_cols = right_data_cols & ~contains(column_names, 'blink') & ~contains(column_names, 'saccade');
    for i = 1:size(maskmat_left, 2)
        data_mat(maskmat_left(:, i), left_data_cols) = NaN;
    end
    for i = 1:size(maskmat_right, 2)
        data_mat(maskmat_right(:, i), right_data_cols) = NaN;
    end
end
