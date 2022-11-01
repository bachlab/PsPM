function [sts, markerinfo] = pspm_get_markerinfo(fn, options)
% �? Description
%   pspm_get_markerinfo extracts markerinfo from PsPM files that contain
%   such information (typically after import of EEG-style data files, e.g.
%   BrainVision or NeuroScan)
% �? Format
%   [sts, markerinfo] = pspm_get_markerinfo(filename, options)
% �? Arguments
%       filename: [char]
%                 name of PsPM file
%                 if empty, you will be prompted for one
%   ┌────options:
%   ├.markerchan: [double]
%   │             channel id of the marker channel;
%   │             default value: -1, meaning to use the first found marker 
%   │             channel
%   ├──.filename: [char]
%   │             name of a file to write the markerinfo to;
%   │             default value: empty, meaning no file will be written
%   └──overwrite: [logical] (0 or 1)
%                 Define whether to overwrite existing output files or not.
%                 Default value: determined by pspm_overwrite.
% �? Output
%            sts: [double]
%                 default value: -1 if unsuccessful
%     markerinfo: [struct]
%     ├────.name: [char]
%     ├───.value:
%     └─.element:
% �? History
%   Introduced in PsPM 6.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
markerinfo = [];
%% get info
if nargin <= 1
  options = struct();
end
options = pspm_options(options, 'get_markerinfo');
% check input arguments
if nargin < 1 || isempty(fn)
  fn = spm_select(1, 'mat', 'Extract markers from which file?');
end
if options.markerchan == -1
  options.markerchan = 'events';
end
% get file
[bsts, ~, data] = pspm_load_data(fn, options.markerchan);
if bsts == -1, return, end
% check markers
if isempty(data{1}.data)
  sts = -1;
  warning('File (%s) contains no event markers', fn);
  return;
end
%% extract markers: find unique type/value combinations ...
markertype = data{1}.markerinfo.name;
markervalue = data{1}.markerinfo.value;
markerall = strcat(markertype', regexp(num2str(markervalue'), '\s+', 'split'));
markerunique = unique(markerall);
% ... and write them into a struct
for k = 1:numel(markerunique)
  % find all elements
  indx = find(strcmpi(markerall, markerunique{k}));
  % and use first one to extract type and value information
  markerinfo(k).name = markertype{indx(1)};
  markerinfo(k).value = markervalue(indx(1));
  markerinfo(k).elements = indx';
end
% if necessary, write into a file
outfn = options.filename;
if ~isempty(outfn)
  if pspm_overwrite(outfn, options)
    save(outfn, 'markerinfo');
  end
end
