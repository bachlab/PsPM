function [sts, data]=pspm_get_scr(import)
% pspm_get_scr is a common function for importing scr data
%
% FORMAT:
%       [sts, data]=pspm_get_scr(import)
%          import: import job structure with mandatory fields
%                   .sr
%                   .data
%                   .transfer - transfer parameters, either a struct with
%                   fields .Rs, .c, .offset, .recsys, or a file containing
%                   variables 'Rs' 'c', 'offset', 'recsys'
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% check transfer parameters
if isfield(import, 'transfer')
  transferparams = import.transfer;
else
  transferparams = 'none';
end;

clear c Rs offset recsys

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
  try
    recsys=transferparams.recsys;
  catch
    recsys='conductance';
  end;
  dataunits = 'uS';
elseif ischar(transferparams)
  if strcmp(transferparams, 'none')
    c=1; Rs=0; offset=0; recsys='conductance';
  elseif exist(transferparams)==2
    load(transferparams);
    if ~exist('c'), warning('ID:no_conversion_constant', '/nNo conversion constant given'); return; end;
    if ~exist('Rs'), Rs=0; end;
    if ~exist('offset'), offset=0; end;
    if ~exist('recsys'), recsys='conductance'; end;
    dataunits = 'uS';
  else
    warning('ID:nonexistent_file', '/nTransfer file doesn''t exist'); return;
  end;
else
  warning('/nWrong format for transfer parameters'); return;
end;

% convert data
inputdata = double(import.data);
data.data = pspm_transfer_function(inputdata, c, Rs, offset, recsys);
data.data = data.data(:);

% add header
data.header.chantype = 'scr';
data.header.units = dataunits;
data.header.sr = import.sr;
data.header.transfer = struct('Rs', Rs, 'offset', offset, 'c', c, 'recsys', recsys);

% check status
sts = 1;

return