function [sts, infos] = scr_find_sounds(file, options)
%SCR_FIND_SOUNDS finds and if required analyzes sound events in a pspm file.
% A sound is accepted as event if it is longer than 10 ms and events are
% recognized as different if they are at least 50 ms appart.
% [sts, infos] = scr_find_sounds(file,options)
%   Arguments
%       file : path and filename of the pspm file holding the sound
%       options : struct with following possible values
%           addchannel : [true/FALSE] adds a marker channel to the original
%               file with the onset time of the detected sound events and
%               the duration of the sound event (in markerinfo)
%           channeloutput : ['all'/'corrected'] (default: 'all') defines
%               whether all sound markers or only sound markers which have
%               been assigned to a marker from the trigger channel should
%               be added as channel to the original file. 'corrected'
%               requires enabled diagnostics, but does not force it (the
%               option will otherwise not work).
%           diagnostics : [TRUE/false] computes the delay between trigger
%               and displays the mean delay and standard deviation and
%               removes triggers which could not be assigned to a trigger
%               from existing trigger channel.
%           maxdelay : [integer] Size of the window in seconds in which 
%               scr_find_sounds will accept sounds to belong to a marker.
%               default is 3s.
%           plot : [true/FALSE] displays a histogramm of the 
%               delays found and a plot with the detected sound, the
%               trigger and the onset of the sound events. These are color
%               coded for delay, from green (smallest delay) to red
%               (longest). Forces the 'diagnostics' option to true.
%           resample : [integer] spline interpolates the sound by the 
%               factor specified. (1 for no interpolation, by default). 
%               Caution must be used when using this option. It should only
%               be used when following conditions are met :
%                   1. all frequencies are well below the Nyquist frequency
%                   2. the signal is sinusoidal or composed of multiple sin
%                   waves all respecting condition 1
%               Resampling will restore more or less the original signal
%               and lead to more accurate timings.
%           sndchannel : [integer] number of the channel holding the sound.
%               By default first 'snd' channel.
%           threshold : [0...1] percent of the max of the power in the
%               signal that will be accepted as a sound event. Default is
%               0.1.
%           trigchannel : [integer] number of the channel holding the 
%               triggers. By default first 'marker' channel.
%   Outputs
%       sts : 1 on successfull completion, -1 otherwise
%       info: struct()
%           .snd_markers : vector of begining of sound sound events
%           .delays : vector of delays between markers and detected sounds. 
%                Only available with option 'diagnostics' turned on.
%           .channel: number of added chan, when options.addchannel == true
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Samuel Gerster (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;

sts = -1;
% Check argument
if ~exist(file,'file')
    warning('ID:file_not_found', 'File %s was not found. Aborted.',file); return;
end

fprintf('Processing sound in file %s\n',file);

% Process options
try options.addchannel; catch, options.addchannel = false; end;
try options.diagnostics; catch, options.diagnostics = true; end;
try options.maxdelay; catch, options.maxdelay = 3; end;
try options.plot; catch, options.plot = false; end;
try options.resample; catch, options.resample = 1; end;
try options.sndchannel; catch, options.sndchannel = 0; end;
try options.threshold; catch, options.threshold = 0.1; end;
try options.trigchannel; catch, options.trigchannel = 0; end;
try options.channeloutput; catch; options.channeloutput = 'all'; end;

if options.plot
    options.diagnostics = true;
end

if ~isnumeric(options.resample) || mod(options.resample,1) || options.resample<1
    warning('ID:invalid_input', 'Option resample is not an integer or negative.'); return;
elseif ~isnumeric(options.maxdelay) || options.maxdelay < 0
    warning('ID:invalid_input', 'Option maxdelay is not a number or negative.'); return;
elseif ~isnumeric(options.threshold) || options.threshold < 0
    warning('ID:invalid_input', 'Option threshold is not a number or negative.'); return;
elseif ~isnumeric(options.sndchannel) || mod(options.sndchannel,1) || options.sndchannel < 0
    warning('ID:invalid_input', 'Option sndchannel is not an integer.'); return;
elseif ~isnumeric(options.trigchannel) || mod(options.trigchannel,1) || options.trigchannel < 0
    warning('ID:invalid_input', 'Option trichannel is not an integer.'); return;
elseif ~islogical(options.addchannel) && ~isnumeric(options.addchannel)
    warning('ID:invalid_input', 'Option addchannel is not numeric or logical'); return;
elseif ~islogical(options.diagnostics) && ~isnumeric(options.diagnostics)
    warning('ID:invalid_input', 'Option diagnostics is not numeric or logical'); return;
elseif ~islogical(options.plot) && ~isnumeric(options.plot)
    warning('ID:invalid_input', 'Option plot is not numeric or logical'); return;
elseif ~strcmpi(options.channeloutput, 'all') && ~strcmpi(options.channeloutput, 'corrected')
    warning('ID:invalid_input', 'Option channeloutput must be either ''all'' or ''corrected''.');
    return;
end

% call it outinfos not to get confused
outinfos = struct();

% Load Data
[sts, ininfo, indata] = scr_load_data(file);
if sts == -1
    warning('ID:invalid_input', 'Failed loading file %s.', file); return;
end;

%% Sound
% Check for existence of sound channel
if ~options.sndchannel
    sndi = find(strcmpi(cellfun(@(x) x.header.chantype,indata,'un',0),'snd'),1);
    if ~any(sndi)
        warning('ID:no_sound_chan', 'No sound channel found. Aborted'); sts=-1; return;
    end
    snd = indata{sndi};
elseif options.sndchannel > numel(indata)
    warning('ID:out_of_range', 'Option sndchannel is out of the data range.'); return;
else
    snd = indata{options.sndchannel};
end;

% Process Sound
snd.data = snd.data-mean(snd.data);
snd.data = snd.data/(max(snd.data));
tsnd = (0:length(snd.data)-1)'/snd.header.sr;

if options.resample>1
    % Interpolate data to restore sin like wave for more precision
    t = (0:1/options.resample:length(snd.data)-1)'/snd.header.sr;
    snd_pow = interp1(tsnd,snd.data,t,'spline').^2;
else
    t = tsnd;
    snd_pow = snd.data.^2;
end;
% Apply simple bidirectional square filter
mask = ones(round(.01*snd.header.sr),1)/round(.01*snd.header.sr);
snd_pow = conv(snd_pow,mask);
snd_pow = sqrt(snd_pow(1:end-length(mask)+1).*snd_pow(length(mask):end));

%% Find sound events
thresh = max(snd_pow)*options.threshold;
snd_pres(snd_pow>thresh) = 1;
snd_pres(snd_pow<=thresh) = 0;
% Convert detected sounds into events. If pulses are separated by less than
% 50ms, combine into one event.
mask = ones(round(0.05*snd.header.sr*options.resample),1);
n_pad = length(mask)-1;
c = conv(snd_pres,mask)>0;
snd_pres = (c(1:end-n_pad) & c(n_pad+1:end));
% Find rising and falling edges
snd_re = t(conv([1,-1],snd_pres(1:end-1)+0)>0);
% Find falling edges
snd_fe = t(conv([1,-1],snd_pres(1:end-1)+0)<0);
if numel(snd_re) ~= 0 && numel(snd_fe) ~= 0
    % Start with a rising and end with a falling edge
    if snd_re(1)>snd_fe(1)
        snd_re = snd_re(2:end);
    end
    if snd_fe(end) < snd_re(end)
        snd_fe = snd_fe(1:end-1);
    end
end
% Discard sounds shorter than 10ms
noevent_i = find((snd_fe-snd_re)<0.01);
snd_re(noevent_i)=[];
snd_fe(noevent_i)=[];

% keep current snd_re for channeloutput 'all'
snd_re_all = snd_re;
snd_fe_all = snd_fe;

%% Triggers
if options.diagnostics
    % Check for existence of marker channel
    if ~options.trigchannel
        mkri = find(strcmpi(cellfun(@(x) x.header.chantype,indata,'un',0),'marker'),1);
        if ~any(mkri)
            warning('ID:no_marker_chan', 'No marker channel found. Aborted'); sts=-1; return;
        end
    elseif options.trigchannel > numel(indata)
        warning('ID:out_of_range', 'Option trigchannel is out of the data range.'); return;     
    else
        mkri=options.trigchannel;
    end
    mkr = indata{mkri};

    %% Estimate delays from trigger to sound
    delays = nan(length(mkr.data),1);
    snd_markers = nan(length(mkr.data),1);
    for i=1:length(mkr.data)
        tr = snd_re(find(snd_re>mkr.data(i),1));
        delay = tr-mkr.data(i);
        if delay<options.maxdelay
            delays(i) = delay;
            snd_markers(i)=tr;
        end
    end
    delays(isnan(delays)) = [];
    snd_markers(isnan(snd_markers)) = [];
    % Discard any sound event not related to a trigger
    snd_fe = snd_fe(dsearchn(snd_re,snd_markers));
    snd_re = snd_re(dsearchn(snd_re,snd_markers));
    %% Display some diagnostics
    fprintf('%4d sound events associated with a marker found\nMean Delay : %5.1f ms\nStd dev    : %5.1f ms\n',...
        length(snd_markers),mean(delays)*1000,std(delays)*1000);
    
    outinfos.delays = delays;
    outinfos.snd_markers = snd_markers;
end

%% Save as new channel
if options.addchannel
    % Save the new channel
    if strcmpi(options.channeloutput, 'all')
        snd_events.data = snd_re_all;
        snd_events.markerinfo.value = snd_fe_all-snd_re_all;
    else
        snd_events.data = snd_re;
        snd_events.markerinfo.value = snd_fe-snd_re;
    end;
    
    % marker channels have sr = 1 (because marker events are specified in
    % seconds)
    snd_events.header.sr = 1;
    snd_events.header.chantype = 'marker';
    snd_events.header.units ='events';
    [sts, ininfos] = scr_write_channel(file, snd_events, 'add');
    outinfos.channel = ininfos.channel;
end

%% Plot Option
if options.plot
    figure
    histogram(delays*1000,10)
    title('Trigger to sound delays')
    xlabel('t [ms]')
    if options.resample
        % downsample for plot
        t = t(1:options.resample:end);
        snd_pres = snd_pres(1:options.resample:end);
    end
    figure
    plot(t,snd_pres)
    hold on
    scatter(mkr.data,ones(size(mkr.data))*.1,'k')
    for i = 1:length(delays)
        scatter(snd_re(i),.2,500,[(delays(i)-min(delays))/range(delays),1-(delays(i)-min(delays))/range(delays),0],'.')
    end
    xlabel('t [s]')
    legend('Detected sound','Trigger','Sound onset')
    hold off
end

infos = outinfos;
sts=1;

end