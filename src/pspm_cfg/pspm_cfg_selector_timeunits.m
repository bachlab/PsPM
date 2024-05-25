function timeunits = pspm_cfg_selector_timeunits(varargin)

%% General items
mrk_chan            = pspm_cfg_selector_channel('Marker');

%% Specific items
% Timeunits
seconds         = cfg_const;
seconds.name    = 'Seconds';
seconds.tag     = 'seconds';
seconds.val     = {'seconds'};
seconds.help    = {''};

samples         = cfg_const;
samples.name    = 'Samples';
samples.tag     = 'samples';
samples.val     = {'samples'};
samples.help    = {''};

markers         = cfg_branch;
markers.name    = 'Markers';
markers.tag     = 'markers';
markers.val     = {mrk_chan};
markers.help    = {''};

whole         = cfg_const;
whole.name    = 'Whole';
whole.tag     = 'whole';
whole.val     = {'whole'};
whole.help    = {'Choose whole file for analysis.'};

timeunits         = cfg_choice;
timeunits.name    = 'Time Units';
timeunits.tag     = 'timeunits';

if nargin > 0 && strcmpi(varargin{1}, 'sf')
    timeunits.values  = {seconds, samples, markers, whole};
else
    timeunits.values = {seconds, samples, markers};
end

timeunits.help    = {['Indicate the time units on which the timing specification ' ...
    'is based. Time units can be ''seconds'', index of ''markers'', or index ' ...
    'of data ''samples''.']};