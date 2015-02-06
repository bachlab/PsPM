function [sts, markerinfo] = scr_get_markerinfo(fn, options)
% scr_get_markerinfo extracts markerinfo from SCRalyze files that contain
% such information (typically after import of EEG-style data files, e. g.
% BrainVision or NeuroScan)
% 
% FORMAT:
% [sts, markerinfo] = scr_get_markerinfo(filename, options)
%          filename: name of SCR file, if empty, you will prompted for one
%          options.outfile: name of a file to write the markerinfo to
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_get_markerinfo.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

global settings;
if isempty(settings), scr_init; end;

% set output values
sts = -1; markerinfo = [];

% check input arguments
if nargin < 1 || isempty(fn)
    fn = spm_select(1, 'mat', 'Extract markers from which file?');
end;

% get file
[sts, infos, data] = scr_load_data(fn, 'events');
if sts == -1, return, end;

% check markers
if isempty(data{1}.data)
    sts = -1; 
    warning('File %s contains no event markers', fn);
    return;
end;

% -------------------------------------------------------------------------
% extract markers: find unique type/value combinations ...
markertype = data{1}.markerinfo.name;
markervalue = data{1}.markerinfo.value;
markerall = strcat(markertype', strsplit(num2str(markervalue')));
markerunique = unique(markerall);

% ... and write them into a struct
for k = 1:numel(markerunique)
    % find all elements
    indx = find(strcmpi(markerall, markerunique{k}));
    % and use first one to extract type and value information
    markerinfo(k).name = markertype{indx(1)};
    markerinfo(k).value = markervalue(indx(1));
    markerinfo(k).elements = indx';
end;

% if necessary, write into a file
if nargin > 1 && isfield(options, 'filename')
    save(options.filename, 'markerinfo');
end;

return;




