function timeunits = pspm_cfg_selector_timeunits(varargin)
% Time units selector. 
% timeunits = pspm_cfg_selector_timeunits(): seconds, samples, markers
% (with selection of marker channel)
% timeunits = pspm_cfg_selector_timeunits('sf', epochs): seconds, samples,
% markers, whole; with epochs selector if time units is not 'whole'
% 

%% parse input
if nargin > 0 && strcmpi(varargin{1}, 'sf')
    sf = 1;
    epochs = varargin{2};
else
    sf = 0;
end

%% General items
mrk_chan            = pspm_cfg_selector_channel('Marker');

%% Specific items
% Timeunits

if sf
    seconds         = cfg_branch;
    samples         = cfg_branch;
    markers         = cfg_branch;
    whole           = cfg_const;
    whole.name      = 'Whole';
    whole.tag       = 'whole';
    whole.val       = {'whole'};
    whole.help      = {'Choose whole file for analysis.'};
else
    seconds         = cfg_const;
    samples         = cfg_const;
    markers         = cfg_branch;
end

seconds.name    = 'Seconds';
seconds.tag     = 'seconds';
seconds.val     = {'seconds'};
seconds.help    = {''};

samples.name    = 'Samples';
samples.tag     = 'samples';
samples.val     = {'samples'};
samples.help    = {''};

markers.name    = 'Markers';
markers.tag     = 'markers';
markers.val     = {mrk_chan};
markers.help    = {''};

timeunits         = cfg_choice;
timeunits.name    = 'Time Units';
timeunits.tag     = 'timeunits';

if sf
    seconds.val = {epochs};
    samples.val = {epochs};
    markers.val = {epochs, mrk_chan};
    timeunits.values  = {seconds, samples, markers, whole};
else
    timeunits.values = {seconds, samples, markers};
end

timeunits.help    = {['Indicate the time units on which the timing specification ' ...
    'is based. Time units can be ''seconds'', index of ''markers'', or index ' ...
    'of data ''samples''.']};