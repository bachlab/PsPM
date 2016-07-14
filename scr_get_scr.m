function [sts, data]=scr_get_scr(import)
% SCR_GET_SCR is a common function for importing scr data
%
% FORMAT:
%       [sts, data]=scr_get_scr(import)
%          import: import job structure with mandatory fields 
%                   .sr 
%                   .data
%                   .transfer - transfer parameters, either a struct with
%                   fields .Rs, .c, .offset, or a file containing variables
%                   'Rs' 'c', 'offset'
%  
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_get_scr.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sts = -1;

% check transfer parameters
if isfield(import, 'transfer')
    transferparams = import.transfer;
else
    transferparams = 'none';
end;

clear c Rs offset
if isfield(import, 'units')
    dataunits = import.units;
else
    dataunits='unknown';
end

if isstruct(transferparams)
    try 
        c=transferparams.c; 
    catch
        warning('ID:no_conversion_constant', '/nNo conversion constant given'); return;
    end;
    try 
        Rs=transferparams.Rs; 
    catch 
        Rs=0; end;
    try 
        offset=transferparams.offset; 
    catch
        offset=0; 
    end;
    dataunits = 'uS';
elseif ischar(transferparams)
    if strcmp(transferparams, 'none')
        c=1; Rs=0; offset=0;
    elseif exist(transferparams)==2
        load(transferparams);
        if ~exist('c'), warning('ID:no_conversion_constant', '/nNo conversion constant given'); return; end;
        if ~exist('Rs'), Rs=0; end;
        if ~exist('offset'), offset=0; end;
        dataunits = 'uS';
    else
        warning('ID:nonexistent_file', '/nTransfer file doesn''t exist'); return;
    end;
else
    warning('/nWrong format for transfer parameters'); return;
end;

% convert data
inputdata = double(import.data);
data.data = scr_transfer_function(inputdata, c, Rs, offset);
data.data = data.data(:);

% add header
data.header.chantype = 'scr';
data.header.units = dataunits;
data.header.sr = import.sr;
data.header.transfer = struct('Rs', Rs, 'offset', offset, 'c', c);

% check status
sts = 1;

return;










