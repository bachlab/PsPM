function out = pspm_cfg_channel_selector(channame, varargin)
% Generates a standardised channel selector GUI entry

% check input
if nargin == 0 
    channame = '';
end

%% parse channel selection from matlabbatch
if strcmpi(channame, 'run')
    job = varargin{1};
    if isfield(job, 'chan_default')
        out = job.chan_default;
    elseif isfield(job, 'chan_nr')
        out = job.chan_nr;
    else
        out = 0;
    end

    if ischar(out)
        if strcmpi(out, num2str(int64(str2num(out))))
            out = str2num(out);
        end
    end

%% gather channel selection in matlabbatch  
% numerical or string definition
elseif strcmpi(channame, 'any')
    out         = cfg_entry;
    out.name    = 'Channel specification';
    out.tag     = 'chan_nr';
    out.strtype = 's';
    out.help    = {sprintf('Specify %s channel number or channel type (e.g., "scr", "ecg" or another type accepted by PsPM.', channame)};

% numerical or string definition or default
elseif strcmpi(channame, 'pupil')
    chan_default      = cfg_const;
    chan_default.name = 'Default channel';
    chan_default.tag  = 'chan_def';
    chan_default.val  = {'pupil'};
    chan_default.help = {['First existing option out of the following: ', ...
        '(1) L-R-combined pupil, (2) non-lateralised pupil, (3) best ', ...
        'eye pupil, (4) any pupil channel. If there are multiple ', ...
        'channels in the first existing option, only last one will be ', ...
        'processed.']};

    chan_nr         = cfg_entry;
    chan_nr.name    = 'Channel specification';
    chan_nr.tag     = 'chan_nr';
    chan_nr.strtype = 's';
    chan_nr.help    = {'Specify channel number or channel type (e.g., "pupil_l", "pupil_c" or another type accepted by PsPM.'};

    out = cfg_choice;
    out.name    = 'Channel';
    out.tag     = 'chan';
    out.val     = {chan_default};
    out.values  = {chan_default, chan_nr};
    out.help    = {sprintf('Specification of %s channel (default: follow precedence order).', lower(channame))};

% numerical definition
elseif isempty(channame)
    out         = cfg_entry;
    out.name    = 'Channel number';
    out.tag     = 'chan_nr';
    out.strtype = 'i';
    out.num     = [1 1];
    out.help    = {sprintf('Specify %s channel number.', channame)};


% numerical definition or default 
else
    if strcmpi(channame, 'marker')
        pos_str = 'First';
    else
        pos_str = 'Last';
    end

    chan_default      = cfg_const;
    chan_default.name = 'Default channel';
    chan_default.tag  = 'chan_def';
    chan_default.val  = {0};
    chan_default.help = {sprintf('%s %s channel.', pos_str, channame)};

    chan_nr         = cfg_entry;
    chan_nr.name    = 'Channel number';
    chan_nr.tag     = 'chan_nr';
    chan_nr.strtype = 'i';
    chan_nr.num     = [1 1];
    chan_nr.help    = {sprintf('Specify %s channel number.', channame)};

    out = cfg_choice;
    out.name    = 'Channel';
    out.tag     = 'chan';
    out.val     = {chan_default};
    out.values  = {chan_default, chan_nr};
    out.help    = {sprintf('Number of %s channel (default: %s %s channel).', channame, lower(pos_str), channame)};
end

