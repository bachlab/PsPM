function filtering = pspm_cfg_filtering
% Updated 26-Feb-2024 by Teddy

%% Standard items
datafile                 = pspm_cfg_selector_datafile;
chan_nr                  = pspm_cfg_selector_channel('any');
FilterButter             = pspm_cfg_selector_filter('none');

%% Leaky integrator
tau               = cfg_entry;
tau.name          = 'Time constant';
tau.tag           = 'tau';
tau.strtype       = 'r';
tau.num           = [1 1];
tau.help          = {'Time constant in seconds.'};

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
nr_time_pt.help          = {'Number of time points over which the median is taken.'};
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
filtertype.help          = {['Currently, median and Butterworth ',...
                           'filters and a leaky integrator are implemented. A median filter is ' ...
                           'recommended for short spikes, generated ' ...
                           'for example in MRI scanners by gradient ' ...
                           'switching. A butterworth filter is already applied ' ...
                           'in most psychophysiological models; check there to see whether ' ...
                           'an additional filtering is meaningful. A leaky integrater is often used for EMG or neural data.']};
%% Overwrite file
overwrite                = cfg_menu;
overwrite.name           = 'Overwrite Existing File';
overwrite.tag            = 'overwrite';
overwrite.val            = {false};
overwrite.labels         = {'No', 'Yes'};
overwrite.values         = {false, true};
overwrite.help           = {'Overwrite if a file with the same name has existed?'};
%% Executable branch
filtering             = cfg_exbranch;
filtering.name        = 'Data filtering';
filtering.tag         = 'filtering';
filtering.val         = {datafile,chan_nr,filtertype,overwrite};
filtering.prog        = @pspm_cfg_run_filtering;
filtering.vout        = @pspm_cfg_vout_outchannel;
filtering.help        = {['This module offers several basic filtering functions. ',...
                           'Currently, a median filter and a butterworth low pass ' ...
                           'filter are implemented. The median filter is useful to ' ...
                           'remove short "spikes" in the data, for example from gradient ' ...
                           'switching in MRI. The Butterworth filter can be used to get ' ...
                           'rid of high frequency noise that is not sufficiently ',...
                           'filtered away by the filters implemented on-the-fly during ',...
                           'first level modelling.']};

