function [sts, outfile] = pspm_merge(infile1, infile2, reference, options)
% ● Description
%   pspm_merge merges two PsPM datafiles with different channels and writes
%   it to a file with the same name as the first file, prepended 'm'.
%   The data is aligned to file start or first marker. Data after the reference
%   are extended to the duration of the longer data file
% ● Format
%   [sts, outfile] = pspm_merge(infile1, infile2, reference, options)
% ● Arguments
%    infile1, infile2:  data file name(s) (char)
%           reference:  'marker' aligns with respect to first marker
%                       'file'   aligns with respect to file start
%   ┌─────────options:
%   ├──────.overwrite:  overwrite existing file by default
%   │                   [logical] (0 or 1)
%   │                   Default value: determined by pspm_overwrite.
%   └.marker_chan_num:  2 marker channel numbers - if undefined
%                       or 0, first marker channel of either file is used
% ● History
%   Introduced In PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (UZH, WTCN)
%   Maintained in 2022 by Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
    pspm_init;
end
sts = -1;
outfile = [];


%% Check input
% check missing input --
if nargin < 3
    warning('Not enough input'); return;
end

% check faulty input --
if ~ischar(reference) || ~ismember(reference, {'marker', 'file'})
    warning('Reference must be ''marker'' or ''file''.'); return;
end

% check options --
options = pspm_options(options, 'merge');
if options.invalid
    return
end

%% loop through data files
% read input files --
infile = {infile1, infile2};
infos = cell(2,1);
data = cell(2,1);
for iNum = 1:2
    [sts_load_data, infos, data] = pspm_load_data(infile{iNum});
    if sts_load_data ~= 1
        return;
    end
end
% for marker alignment, trim data before first marker --
if strcmpi(reference, 'marker')
    for iNum = 1:2
        trimdata.data = data{iNum}; trimdata.infos = infos;
        trimoptions.marker_chan_num = options.marker_chan_num(iNum);
        trimdata = pspm_trim(trimdata, 0, 'none', 'marker', trimoptions);
        data{iNum} = trimdata.data; infos{iNum} = trimdata.infos;
    end
end
% put together and cut away data from the end --
[sts_align_channels, data, duration] = pspm_align_channels([data{1}; data{2}]);
if sts_align_channels ~= 1
    return;
end
% collect infos --
oldinfos = infos; infos = struct([]);
infos(1).duration = duration;
try infos.sourcefile = {oldinfos{1}.importfile; oldinfos{2}.importfile}; end
try infos.importfile = {oldinfos{1}.importfile; oldinfos{2}.importfile}; end
try infos.importdate = {oldinfos{1}.importdate; oldinfos{2}.importdate}; end
try infos.recdate = {oldinfos{1}.recdate; oldinfos{2}.recdate}; end
try infos.rectime = {oldinfos{1}.rectime; oldinfos{2}.rectime}; end
infos.mergedate = date;
infos.mergedref = reference;
% create output file name and save data --
[pth, fn, ext] = fileparts(infile{1}{iFile});
outfile = fullfile(pth, ['m', fn, ext]);
infos.mergedfile = outfile;
outdata.data = data;
outdata.infos = infos;
options.overwrite = pspm_overwrite(outfile, options);
outdata.options = options;
sts_load_data = pspm_load_data(outfile, outdata);
if sts_load_data ~= 1, return; end

sts = 1;