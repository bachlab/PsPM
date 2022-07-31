function [sts, import, sourceinfo] = pspm_get_biograph(datafile, import)
% ● Description
%   pspm_get_biograph is the main function for import of text-exported
%   BioGraph Infiniti files
% ● Format
%   [sts, import, sourceinfo] = pspm_get_biograph(datafile, import);
% ● Introduced In
%   PsPM 3.0
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
bio.data = textscan(fid, '%n%n', 'Delimiter', ',', 'HeaderLines', 9);
fclose(fid);

% extract individual channel
% -------------------------------------------------------------------------
if strcmpi(settings.chantypes(import{1}.typeno).data, 'events')
  if isempty(strfind(bio.header{1}{1}, 'Interval Data Export'))
    fprintf('\n');
    warning('Please use ''Interval Data Export'' for channels of type ''%s''', ...
      import{1}.type); return
  end;
  import{1}.marker = 'timestamps';
  import{1}.sr = 1; % time stamps are in seconds
  import{1}.data = bio.data{1};
else
  if isempty(strfind(bio.header{1}{1}, 'Export Channel Data'))
    fprintf('\n');
    warning('Please use ''Export Channel Data'' for channels of type ''%s''', ...
      import{1}.type); return
  end;
  import{1}.sr = str2num(cell2mat(regexp(bio.header{1}{1}, '\d', 'match')));
  import{1}.data = bio.data{2};
  % check sample rate --
  fid = fopen(datafile);
  str = textscan(fid, '%s', 1, 'HeaderLines', 2);
  fclose(fid);
  str = str{1}{1};
  pos = strfind(str, '.'); % position of the the decimal point

  if isempty(pos)
    threshold = import{1}.sr;
  elseif numel(pos) > 1
    warning('Time stamp column not recognised.'); return
  else
    threshold = import{1}.sr * 10^-(length(str) - pos); %length(str) - pos = no. of decimal places
  end

  % diff(timestamps) < sr^-1 + abs(error)
  % --> abs(1-diff(timestamps)) < threshold, with threshold = sr * abs(error)
  if any(abs(1-import{1}.sr*diff(bio.data{1})) > threshold)
    warning('Sample rate in header line and timestamps in first column do not match.'); return;
  end;

end;

sts = 1;
return