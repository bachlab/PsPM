function filtering = pspm_cfg_filtering
% Updated 26-Feb-2024 by Teddy

%% Standard items
datafile                 = pspm_cfg_selector_datafile;
chan_nr                  = pspm_cfg_selector_channel('any');
chan_action              = pspm_cfg_selector_channel_action;
FilterButter             = pspm_cfg_selector_filter('none');


%% Leaky integrator
tau               = cfg_entry;
tau.name          = 'Time constant';
tau.tag           = 'tau';
tau.strtype       = 'r';
tau.num           = [1 1];
tau.help          = pspm_cfg_help_format('pspm_pp', 'tau');

FilterLeaky             = cfg_branch;
FilterLeaky.name        = 'Leaky Integrator';
FilterLeaky.tag         = 'leaky_integrator';
FilterLeaky.val         = {tau};
FilterLeaky.help        = {''};

%% Medianfilter
nr_time_pt               = cfg_entry;
nr_time_pt.name          = 'Number of Time Points';
nr_time_pt.tag           = 'nr_time_pt';
nr_time_pt.strtype       = 'i';
nr_time_pt.num           = [1 1];
nr_time_pt.help          = pspm_cfg_help_format('pspm_pp', 'n');

% Medianfilter
FilterMedian             = cfg_branch;
FilterMedian.name        = 'Median Filter';
FilterMedian.tag         = 'median';
FilterMedian.val         = {nr_time_pt};
FilterMedian.help        = {''};

filtertype               = cfg_choice;
filtertype.name          = 'Filter Type';
filtertype.tag           = 'filtertype';
filtertype.values        = {FilterMedian,FilterButter,FilterLeaky};
filtertype.help          = {};

%% Executable branch
filtering             = cfg_exbranch;
filtering.name        = 'Data filtering';
filtering.tag         = 'filtering';

filtering.val         = {datafile,chan_nr, chan_action, filtertype};
filtering.prog        = @pspm_cfg_run_filtering;
filtering.vout        = @pspm_cfg_vout_outchannel;
filtering.help        = pspm_cfg_help_format('pspm_pp');

