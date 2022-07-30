function [sts, import, sourceinfo] = pspm_get_biotrace(datafile, import)
% pspm_get_biotrace is the main function for import of text-exported
% Mindemedia BioTrace files
% FORMAT: [sts, import, sourceinfo] = pspm_get_biotrace(datafile, import);
%__________________________________________________________________________
% PsPM 3.0
% ● Written By
%   (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];

% get data
% -------------------------------------------------------------------------
fid = fopen(datafile);
bio.header = textscan(fid, '%s', 'Delimiter', '|');
fclose(fid);
fid = fopen(datafile);
bio.data   = textscan(fid, '%n%s', 'Delimiter', '\t', 'HeaderLines', 14);
fclose(fid);

% extract individual channels
% -------------------------------------------------------------------------
% check sample rate ---
if isempty(strfind(bio.header{1}{1}, 'RAW'))
  warning('Unrecognised data format\n.'); return
else
  foo = regexp(bio.header{1}{7}, '\s', 'split');
  sr = str2num(foo{3});
end;

% retrieve recording channel, date and time ---
foo = regexp(bio.header{1}{9}, ':', 'split');
sourceinfo.chan{1} = foo{2};
foo = regexp(bio.header{1}{4}, '\s', 'split');
sourceinfo.date = foo{2};
foo = regexp(bio.header{1}{5}, '\s', 'split');
sourceinfo.time = foo{2};

% loop through import jobs ---
for k = 1:numel(import)
  if strcmpi(import{k}.type, 'marker')
    foo = char(bio.data{end});
    import{k}.data = find(foo(:, 1) ~= ' ');
    import{k}.sr = 1/sr;
    import{k}.marker = 'timestamp';
    import{k}.markerinfo.name = bio.data{end}{import{k}.data};
  else
    import{k}.data = bio.data{1};
    import{k}.sr = sr;
  end;
end;

sts = 1;
return