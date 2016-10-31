function [chandata, chanhead] = pspm_spike_convert(filename)
% SCR_SPIKE_CONVERT imports Spike 2 data in the SON format into matlab data
%
% FORMAT:
% [data info] = pspm_spike_convert(filename)
% 
% RETURNS:
% cell arrays for channel data and header
% 
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: pspm_spike_convert.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;
% -------------------------------------------------------------------------
% SCRalyze2, 30.7.2008

warning off;
fid=fopen(filename);
chanlist=SONChanList(fid);

% preallocate memory for speed
chandata=cell(numel(chanlist), 1);

errorflag=[];
% read channels
for chan=1:numel(chanlist)
    try [chandata{chan} chanhead{chan}]=SONGetChannel(fid, chanlist(chan).number, 'milliseconds');
    catch errorflag(chan)=1; chandata{chan}=[]; chanhead{chan}.title=''; end;
end;
fclose(fid);

% delete empty channels
if ~isempty(errorflag)
    ind=find(errorflag);
    for chan=ind(end:-1:1)
        chandata(chan)=[];
        chanhead(chan)=[];
    end;
end;
        
warning on;
    