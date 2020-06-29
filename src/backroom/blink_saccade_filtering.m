function [out_data_mat] = blink_saccade_filtering(data_mat, column_names, mask_chans, n_samples, fn_is_left)
    if nargin == 4
        fn_is_left = @(x) strcmp(x(end-1:end), '_l');
    end

    out_data_mat = expand_mask_chans(data_mat, column_names, mask_chans, n_samples);
    out_data_mat = set_blinks_saccades_to_nan(out_data_mat, column_names, mask_chans);
end

function data = expand_mask_chans(data, column_names, mask_chans, offset)
    for chan = mask_chans
        col_idx = find(strcmpi(column_names, chan{1}));
        data(:, col_idx) = expand_mask(data(:, col_idx), offset);
    end
end

function mask = expand_mask(mask, offset)
    diffmask = diff(mask);
    indices_to_expand_towards_left = find(diffmask == 1) + 1;
    indices_to_expand_towards_right = find(diffmask == (-1));

    for ii = 1:numel(indices_to_expand_towards_left)
        idx = indices_to_expand_towards_left(ii);
        begidx = max(1, idx - offset);
        endidx = max(1, idx - 1);
        mask(begidx : endidx) = true;
    end
    ndata = numel(mask);
    for ii = 1:numel(indices_to_expand_towards_right)
        idx = indices_to_expand_towards_right(ii);
        begidx = min(ndata, idx + 1);
        endidx = min(ndata, idx + offset);
        mask(begidx : endidx) = true;
    end
end
