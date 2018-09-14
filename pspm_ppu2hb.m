function [ sts, outinfo ] = pspm_ppu2hb( fn,chan,options )
%pspm_ppu2hb Converts a pulse oxymeter channel to heartbeats and adds it as
%a new channel
%   First a template is generated from non ambiguous heartbeats. The ppu
%   signal is then cross correlated with the template and maximas are
%   identified as heartbeat maximas and a heartbeat channel is then
%   generated from these.
%   Format: [ sts, outinfo ] = pspm_ppu2hb( fn,chan,options )
%   Inputs :
%       fn : file name with path
%       chan : ppu channel number
%       options : struct with following possible fields
%           diagnostics : [true/FALSE] displays some debugging information
%           replace     : [true/FALSE] replace existing heartbeat channel.
%                         If multiple channels are present, replaces last.
%           lsm         : [integer] large spikes mode compensates for
%                         large spikes while generating template by
%                         removing the [integer] largest percentile of 
%                         spikes from consideration
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Samuel Gerster (University of Zurich), Tobias Moser (University of Zurich)

% $Id$
% $Rev$


% initialise
% -------------------------------------------------------------------------
sts = -1;
outinfo = struct();
global settings;
if isempty(settings), pspm_init; end

%% check input
% -------------------------------------------------------------------------
if nargin < 1
    warning('ID:invalid_input', 'No input. Don''t know what to do.'); return;
elseif ~ischar(fn)
    warning('ID:invalid_input', 'Need file name string as first input.'); return;
elseif nargin < 2 || isempty(chan)
    chan = 'ppu';
elseif ~isnumeric(chan) && ~strcmp(chan,'ppu')
        warning('ID:invalid_input', 'Channel number must be numeric'); return;
end

%%% Process options
% Display diagnostic plots? default is "false"
try if ~islogical(options.diagnostics),options.diagnostics = false;end
    catch, options.diagnostics = false; end
% Replace existing heartbeat channel? default is "false"
try if ~islogical(options.replace),options.replace = false;end
    catch, options.replace = false; end
try if ~isnumeric(options.lsm),options.lsm = 0;end
    catch, options.lsm = 0; end

%% user output
% -------------------------------------------------------------------------
fprintf('Heartbeat detection for %s ... \n', fn);

% get data
% -------------------------------------------------------------------------
[nsts, ~, data] = pspm_load_data(fn, chan);
if nsts == -1, return; end
if numel(data) > 1
    fprintf('There is more than one PPU channel in the data file. Only the first of these will be analysed.');
    data = data(1);
end
% Check that channel is ppu 
if ~strcmp(data{1,1}.header.chantype,'ppu')
    warning('ID:not_allowed_channeltype', 'Specified channel is not a PPU channel. Don''t know what to do!')
    return;
end

%% Large spikes mode
%--------------------------------------------------------------------------
ppu = data{1}.data;
% large spike mode
if options.lsm
    fprintf('Entering large spikes mode. This might take some time.');
    % Look for all peaks lower than 200 bpm (multiple of two in heart rate
    %  to compensate for absolute value and therefore twice as mani maxima)
    [pks,pis] = findpeaks(abs(ppu),...
                        'MinPeakDistance',30/200*data{1}.header.sr);
    % Ensure at least one spike is removed by adapting quantil to realistic
    % values, given number of detected spikes
    q = floor(length(pks)*(1-options.lsm/100))/length(pks);
    % define large spikes index as last lsm percentile (or as adapted above)
    lsi = pks>quantile(pks,q);
    %define a minimum peak prominence 2/3 of non large spikes range (more
    %or less)
    minProm = max(pks(~lsi))*2/3;
    % save indexes of large spikes for later removal while generating
    % template
    lsi = pis(lsi);
    fprintf('   done.\n');
else 
    minProm = range(ppu)/3;
end

%% Create template
%--------------------------------------------------------------------------
fprintf('Creating template. This might take some time.');
% Find prominent peaks for a max heart rate of 200 bpm
[~,pis] = findpeaks(data{1}.data,...
                    'MinPeakDistance',60/200*data{1}.header.sr,...
                    'MinPeakProminence',minProm);

if options.lsm
    % Remove large spikes from  
    [~,lsi_in_pis,~] = intersect(pis,lsi);
    pis(lsi_in_pis) = [];
end

% handle possible errors
if isempty(pis),warning('ID:NoPulse', 'No pulse found, nothing done.');return;end

% get pulse period lower limit (assumed onset) as 30% of smalest period 
% before detected peaks
min_pulse_period = min(diff(pis));
period_index_lower_bound = floor(pis(2:end-1)-.3*min_pulse_period);
fprintf('...');

% Create template from mean of peak time-locked ppu pulse periods
pulses = cell2mat(arrayfun(@(x) data{1}.data(x:x+min_pulse_period),period_index_lower_bound','un',0));
template = mean(pulses,2);
fprintf('done.\n');

% handle diagnostic plots relevant to template building
if options.diagnostics
    t_template = (0:length(template)-1)'/data{1}.header.sr;
    t_pulses = repmat(t_template,1,length(pis)-2);
    figure
    plot(t_pulses,pulses,'--')
    set(gca,'NextPlot','add')
    plot(t_template,template,'k','lineWidth',3)
    xlabel('time [s]')
    ylabel('Amplitude')
    title('Generated ppu template (bk) and pulses used (colored)')
end

%% Cross correlate the signal with the template and find peaks
%--------------------------------------------------------------------------
fprintf('Applying template.');
ppu_corr = xcorr(data{1}.data,template)/sum(template);
% Truncate ppu_xcorr and realigne it so the max correlation corresponds to
% templates peak and not beginning of template.
ppu_corr = ppu_corr(length(data{1}.data)-floor(.3*min_pulse_period):end-floor(.3*min_pulse_period));
if options.diagnostics
    t_ppu = (0:length(data{1}.data)-1)'/data{1}.header.sr;
    figure
    if length(t_ppu) ~= length(ppu_corr)
        length(t_ppu)
    end
    plot(t_ppu,ppu_corr,t_ppu,data{1}.data)
    xlabel('time [s]')
    ylabel('Amplitude')
    title('ppu cross-corelated with template and ppu')
    legend('ppu (X) template','ppu')
end
% Get peaks that are at least one template width appart. These are the best
% correlation points.
[~,hb] = findpeaks(ppu_corr/max(ppu_corr),...
                   data{1}.header.sr,...
                   'MinPeakdistance',min_pulse_period/data{1}.header.sr);
fprintf('   done.\n');

%% Prepare output and save
%--------------------------------------------------------------------------
% save data
fprintf('Saving data.');
msg = sprintf('Heart beat detection from ppu with cross correlation HB-timeseries added to data on %s', date);

newdata.data = hb(:);
newdata.header.sr = 1;
newdata.header.units = 'events';
newdata.header.chantype = 'hb';

write_options = struct();
write_options.msg = msg;

% Replace last existing channel or save as new channel
if options.replace
    write_action = 'replace';
else
    write_action = 'add';
end;

% Replace last existing channel or save as new channel
[nsts, nout] = pspm_write_channel(fn,newdata,write_action, write_options);    

% user output
fprintf('  done.\n');
if nsts ~= -1,
    sts = 1;
    outinfo.channel = nout.channel;
end;

return;

end
