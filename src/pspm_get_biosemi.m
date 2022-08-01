function [sts, import, sourceinfo] = pspm_get_biosemi(datafile, import)
% ● Description
%   pspm_get_biosemi is the main function for import of BioSemi bdf files
%   this function uses fieldtrip fileio functions
% ● Format
%   [sts, import, sourceinfo] = pspm_get_biosemi(datafile, import);
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
addpath(pspm_path('Import','fieldtrip','fileio'));
sourceinfo = [];

% get external file, using fieldtrip
% -------------------------------------------------------------------------
hdr = ft_read_header(datafile);
indata = ft_read_data(datafile);
try mrk = ft_read_event(datafile); catch, mrk = []; end;

% extract individual channels
% -------------------------------------------------------------------------
for k = 1:numel(import)

  if strcmpi(settings.chantypes(import{k}.typeno).data, 'wave')
    % channel number ---
    if import{k}.channel > 0
      chan = import{k}.channel;
    else
      chan = pspm_find_channel(hdr.label, import{k}.type);
      if chan < 1, return; end;
    end;

    if chan > size(indata, 1), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;

    sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, hdr.label{chan});

    % sample rate ---
    import{k}.sr = hdr.Fs;

    % get data ---
    import{k}.data = indata(chan, :);

  else                % event channels
    % time unit
    import{k}.sr = 1./hdr.Fs;

    if ~isempty(mrk)
      import{k}.data = [mrk(:).sample];
      import{k}.marker = 'timestamps';
      import{k}.markerinfo.value = [mrk(:).value];
      import{k}.markerinfo.name = {mrk(:).type};
    else
      import{k}.data = [];
      import{k}.marker = 'timestamps';
      import{k}.markerinfo.value = [];
      import{k}.markerinfo.name = [];
    end;
  end;

end;

% clear path and return
% -------------------------------------------------------------------------
rmpath(pspm_path('Import','fieldtrip','fileio'));
sts = 1;
return