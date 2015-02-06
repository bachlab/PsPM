function [sts, import, sourceinfo] = scr_get_biotrace(datafile, import)
% scr_get_biotrace is the main function for import of text-exported 
% Mindemedia BioTrace files
% FORMAT: [sts, import, sourceinfo] = scr_get_biotrace(datafile, import);
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_get_biotrace.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% v002 drb 04.08.2013 3.0 architecture
% v001 drb 22.02.2011

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sourceinfo = []; sts = -1;

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
return;




