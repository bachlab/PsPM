function [sts, data_cell] = pspm_load_single_chan(fn, channel, which_of_many, desired_type_substr)
    % Internal PsPM function. Use at your own risk.
    %
    % Load a single channel from a given datafile.
    %
    % fn: filename
    % channel: channel type
    % which_of_many: What to do if multiple channels are loaded when type is chan. Pass 'first' or 'last'.
    % desired_type_substr: Substring in the desired channel type.
    %
    % sts: Status
    % data_cell: Cell array with single element, containing the loaded PsPM channel.
    %
    % -----------------------------------------------
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    which_of_many = lower(which_of_many);
    assert(ismember(which_of_many, {'first', 'last'}));

    sts = -1;
    [lsts, infos, data_cell] = pspm_load_data(fn, channel);
    if lsts ~= 1; return; end;
    if numel(data_cell) > 1
        warning('ID:multiple_channels', ['There is more than one channel'...
            ' with type %s in the data file.\n'...
            ' We will process only the %s one.\n'], channel, which_of_many);
        if strcmp(which_of_many, 'first')
            data_cell = data_cell(1);
        else
            data_cell = data_cell(end);
        end
    end
    channeltype = data_cell{1}.header.channeltype;
    if ~contains(channeltype, desired_type_substr)
        warning('ID:invalid_input', sprintf('Loaded channeltype %s does not correspond to a %s channel', channeltype, desired_type_substr));
        return;
    end
    sts = 1;
end
