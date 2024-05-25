function filter = pspm_cfg_selector_filter(default, varargin)

% pspm_cfg_selector_filter creates a Matlabbatch filter object. If no
% default is given, the item structure will contain no default either
% if the first argument is 'run', then the filter object will be parsed

% run job -----------------------------------------------------------------
if nargin > 1 && ischar(default) && strcmpi(default, 'run')
    job = varargin{1};
    if isfield(job, 'edit')
        job = job.edit;
    elseif isfield(job, 'def')
        filter = 'none';
        return;
    end

  % lowpass
  if isfield(job.lowpass,'disable')
    filter.lpfreq = NaN;
    filter.lporder = 1;
  else
    filter.lpfreq = job.data_options.filter.edit.lowpass.enable.freq;
    filter.lporder = job.data_options.filter.edit.lowpass.enable.order;
  end
  % highpass
  if isfield(job.data_options.filter.edit.highpass,'disable')
    filter.hpfreq = NaN;
    filter.hporder = 1;
  else
    filter.hpfreq = job.data_options.filter.edit.highpass.enable.freq;
    filter.hporder = job.data_options.filter.edit.highpass.enable.order;
  end
  filter.down = job.data_options.filter.edit.down; % sampling rate
  filter.direction = job.data_options.filter.edit.direction; % sampling rate
  return
end

% create job
% -------------------------------------------------------------------------
if nargin < 1 || ~isstruct(default)
    default = struct();
end

% Filter
disable        = cfg_const;
disable.name   = 'Disable';
disable.tag    = 'disable';
disable.val    = {0};
disable.help   = {''};

% Low pass
lpfreq         = cfg_entry;
lpfreq.name    = 'Cutoff Frequency';
lpfreq.tag     = 'freq';
lpfreq.strtype = 'r';
if isfield(default,'lpfreq')
    lpfreq.val = {default.lpfreq};
end
lpfreq.num     = [1 1];
lpfreq.help    = {'Specify the low-pass filter cutoff in Hz.'};

lporder         = cfg_entry;
lporder.name    = 'Filter Order';
lporder.tag     = 'order';
lporder.strtype = 'i';
if isfield(default,'lporder')
    lporder.val = {default.lporder};
end
lporder.num     = [1 1];
lporder.help    = {'Specify the low-pass filter order.'};

enable_lp        = cfg_branch;
enable_lp.name   = 'Enable';
enable_lp.tag    = 'enable';
enable_lp.val    = {lpfreq, lporder};
enable_lp.help   = {''};

lowpass        = cfg_choice;
lowpass.name   = 'Low-Pass Filter';
lowpass.tag    = 'lowpass';
lowpass.val    = {enable_lp};
lowpass.values = {enable_lp, disable};
lowpass.help   = {''};

% High pass
hpfreq         = cfg_entry;
hpfreq.name    = 'Cutoff Frequency';
hpfreq.tag     = 'freq';
hpfreq.strtype = 'r';
if isfield(default,'hpfreq')
    hpfreq.val = {default.hpfreq};
end
hpfreq.num     = [1 1];
hpfreq.help    = {'Specify the high-pass filter cutoff in Hz.'};

hporder         = cfg_entry;
hporder.name    = 'Filter Order';
hporder.tag     = 'order';
hporder.strtype = 'i';
if isfield(default,'hporder')
    hporder.val = {default.hporder};
end
hporder.num     = [1 1];
hporder.help    = {'Specify the high-pass filter order.'};

enable_hp        = cfg_branch;
enable_hp.name   = 'Enable';
enable_hp.tag    = 'enable';
enable_hp.val    = {hpfreq, hporder};
enable_hp.help   = {''};

highpass        = cfg_choice;
highpass.name   = 'High-Pass Filter';
highpass.tag    = 'highpass';
highpass.val    = {enable_hp};
highpass.values = {enable_hp, disable};
highpass.help   = {''};

% Sampling rate
down         = cfg_entry;
down.name    = 'New Sampling Rate';
down.tag     = 'down';
down.strtype = 'r';
if isfield(default,'down')
    down.val = {default.down};
end
down.num     = [1 1];
down.help    = {'Specify the sampling rate in Hz to down sample SCR data. Enter NaN to leave the sampling rate unchanged.'};

% Filter direction
direction         = cfg_menu;
direction.name    = 'Filter Direction';
direction.tag     = 'direction';
direction.val     = {'bi'};
direction.labels  = {'Unidirectional', 'Bidirectional'};
direction.values  = {'uni', 'bi'};
direction.help    = {['A unidirectional filter is applied twice in the forward direction. ' ...
    'A ''bidirectional'' filter is applied once in the forward direction and once in the ' ...
    'backward direction to correct the temporal shift due to filtering in forward direction.']};

filter_edit.val    = {lowpass, highpass, down, direction};
filter_edit        = cfg_branch;
filter_edit.name   = 'Edit Settings';
filter_edit.tag    = 'edit';
filter_edit.val    = {lowpass, highpass, down, direction};

if isempty(fieldnames(default))
    filter_edit.help   = {'Specify Butterworth filter.'};
    filter = filter_edit;
else
    filter_edit.help   = {'Create your own filter (discouraged).'};
    filter_def        = cfg_const;
    filter_def.name   = 'Default';
    filter_def.tag    = 'def';
    filter_def.val    = {0};
    filter_def.help   = {['Default settings for the Butterworth bandpass filter.']};

    filter        = cfg_choice;
    filter.name   = 'Filter Settings';
    filter.tag    = 'filter';
    filter.val    = {filter_def};
    filter.values = {filter_def, filter_edit};
    filter.help   = {'Specify how to filter the data.'};
end