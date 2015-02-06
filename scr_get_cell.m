function [data, sts] = scr_get_cell(inputdata, import)
% scr_get_cell handles dataformats that return a cell array of channel data
% ('txt', 'mat')
% FORMAT: [infos data sts] = scr_get_cell(inputdata, import);
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_get_cell.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% v003 drb 09.05.2013 corrected hr/hb/trigger
% v002 drb 22.05.2010 changed heart beat import
% v001 drb 16.09.2009

global settings;
if isempty(settings), scr_init; end;

for k = 1:numel(import)
    if import{k}.channel > numel(inputdata)
        warning('Import column %02.0f (required by import job %02.0f) not contained in data (only %02.0f columns)', import{k}.channel, k, mumel(inputdata));
        sts = -1; return;
    else
        switch import{k}.type
            case {'scr'}
                if ~isfield(import{k}, 'sr'), warning('No sampling rate given'), sts = -1; return; end;
                [data{k}, sts] = scr_get_scr(inputdata{import{k}.channel}, import{k});
            case {'hr'}
                [data{k}, sts] = scr_get_hr(inputdata{import{k}.channel}, import{k});
            case {'hb'}
                [data{k}, sts] = scr_get_hb(inputdata{import{k}.channel}, import{k});
            case {'resp'}
                if ~isfield(import{k}, 'sr'), warning('No sampling rate given'), sts = -1; return; end;
                [data{k}, sts] = scr_get_resp(inputdata{import{k}.channel}, import{k});
            case {'trigger'}
                try import{k}.trigger; catch, import{k}.trigger = 'continuous'; end;
                [data{k}, sts] = scr_get_trigger(inputdata{import{k}.channel}, import{k});
        end;
    end;
end;
    
return;    






