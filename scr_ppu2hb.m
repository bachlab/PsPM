function [ sts, outinfo ] = scr_ppu2hb( fn,chan,options )
%PSPM_PPU2HB Converts a pulse oxymeter channel to heartbeats and adds it as
%a new channel
%   First a template is generated from non ambiguous heartbeats. The ppu
%   signal is then cross correlated with the template and maximas are
%   identified as heartbeat maximas and a heartbeat channel is then
%   generated from these.
%   Inputs :
%       fn : file name with path
%       chan : ppu channel number
%       options : struct with following possible fields
%           diagnostics : [true/FALSE] displays some debugging information
%           replace     : [true/FALSE] replace existing heartbeat channel.
%                         If multiple channels are present, replaces last.
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
if isempty(settings), scr_init; end;

%% check input
% -------------------------------------------------------------------------
if nargin < 1
    warning('ID:invalid_input', 'No input. Don''t know what to do.'); return;
elseif ~ischar(fn)
    warning('ID:invalid_input', 'Need file name string as first input.'); return;
elseif nargin < 2
    chan = 'ppu';
elseif ~isnumeric(chan) && ~strcmp(chan,'ppu')
        warning('ID:invalid_input', 'Channel number must be numeric'); return;
end;

%%% Process options
% Display diagnostic plots? default is "false"
try if ~islogical(options.diagnostics),options.diagnostics = false;end;
    catch, options.diagnostics = false; end;
% Replace existing heartbeat channel? default is "false"
try if ~islogical(options.replace),options.replace = false;end;
    catch, options.replace = false; end;

%% user output
% -------------------------------------------------------------------------
fprintf('Heartbeat detection for %s ... \n', fn);

% get data
% -------------------------------------------------------------------------
[nsts, infos, data] = scr_load_data(fn, chan);
if nsts == -1, return; end;
if numel(data) > 1
    fprintf('There is more than one PPU channel in the data file. Only the first of these will be analysed.');
    data = data(1);
end;

if ~any(strcmp(data{1,1}.header.chantype,{'ppu'})) 
    warning('ID:not_allowed_channeltype', 'Specified channel is not a PPU channel. Don''t know what to do!')
    return;
end

%% Create template
%--------------------------------------------------------------------------
% Find prominent peaks for a max heart rate of 200 bpm
[~,pi] = findpeaks(data{1}.data,...
                    'MinPeakDistance',60/200*data{1}.header.sr,...
                    'MinPeakProminence',range(data{1}.data/3));
if isempty(pi)
    warning('ID:NoPulse', 'No pulse found, nothing done.'); return;
end

% get pulse epochs lower limit
d = min(diff(pi));
epochs_l = floor(pi(2:end-1)-.3*d);

%Create template from mean of peak time-locked ppu pulse epochs
pulses = cell2mat(arrayfun(@(x) data{1}.data(x:x+d),epochs_l','un',0));
template = mean(pulses,2);
if options.diagnostics
    t_template = (0:length(template)-1)'/data{1}.header.sr;
    t_pulses = repmat(t_template,1,length(pi)-2);
    figure
    plot(t_pulses,pulses,'--',t_template,template,'k','lineWidth',2)
end

%% Cross correlate the signal with the template and find peaks
%--------------------------------------------------------------------------
ppu_corr = xcorr(data{1}.data,template)/sum(template);
% Truncate ppu_xcorr and realigne it so the max correlation corresponds to
% templates peak and not beginning of template.
ppu_corr = ppu_corr(length(data{1}.data)-floor(.3*d):end-floor(.3*d));
if options.diagnostics
    t_ppu = (0:length(data{1}.data)-1)'/data{1}.header.sr;
    figure
    if length(t_ppu) ~= length(ppu_corr)
        length(t_ppu)
    end
    plot(t_ppu,ppu_corr,t_ppu,data{1}.data)
end
% Get peaks that are at least one template width appart. These are the best
% correlation points.
[~,hb] = findpeaks(ppu_corr/max(ppu_corr),data{1}.header.sr,'MinPeakdistance',d/data{1}.header.sr);

%% Prepare output and save
%--------------------------------------------------------------------------
% save data
msg = sprintf('Heart beat detection from ppu with cross correlation HB-timeseries added to data on %s', date);

newdata.data = hb(:);
newdata.header.sr = 1;
newdata.header.units = 'events';
newdata.header.chantype = 'hb';

write_options = struct();
write_options.msg = msg;

if options.replace
    write_action = 'replace';
else
    write_action = 'add';
end;

% Replace last existing channel or save as new channel
[nsts, nout] = scr_write_channel(fn,newdata,write_action, write_options);    

% user output
fprintf('  done.\n');
if nsts ~= -1,
    sts = 1;
    outinfo.channel = nout.channel;
end;

return;

end


























