function [sts, data, duration]=scr_align_channels(data, induration)
% scr_align_channels is an import functions that checks recording length
% for all channels of a data file and aligns them
% if a duration argument is stated, all channels will be aligned to this
% duration
%
% FORMAT:
%       [sts, data, duration]=scr_align_channels(inputdata, induration)
%      
%  
%__________________________________________________________________________
% PsPM 3.1
% (C) 2008-2016 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $ Id: $
% $ Rev $


% initialise status
% -------------------------------------------------------------------------
sts = -1;
global settings;
if isempty(settings), scr_init; end;


% check input arguments
% -------------------------------------------------------------------------
if nargin < 2, induration = 0; end;


for k = 1:numel(data)
    if strcmp(data{k}.header.units, 'events')
        if isempty(data{k}.data)
            duration(k) = 0;
        else
            duration(k) = max(data{k}.data);
        end;
    else
        duration(k) = numel(data{k}.data)/double(data{k}.header.sr);
    end;
end;

duration = max([duration, induration]);

for k = 1:numel(data)
    if ~strcmp(data{k}.header.units, 'events')
        followingtime = duration - numel(data{k}.data)/data{k}.header.sr;
        if followingtime > 0
            data{k}.data = [data{k}.data; zeros(round(followingtime*data{k}.header.sr), 1)];
            if followingtime > .1 
                fprintf('\nData recordings in %s channel were non-existent %0.2f s before the last recording in one or more other channel(s).\nThis gap was padded with zeros.', data{k}.header.chantype, followingtime);
            end;
        end;
    end;
end;

sts = 1;
return;

