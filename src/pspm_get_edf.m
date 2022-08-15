function [sts, import, sourceinfo] = pspm_get_edf(datafile, import)
% ● Description
%   pspm_get_edf is the main function for import of EDF files.
%   This function uses fieldtrip fileio functions.
% ● Format
%   [sts, import, sourceinfo] = pspm_get_edf(datafile, import);
% ● Arguments
%   datafile:
%     import:  
% ● Copyright
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Tobias Moser (University of Zurich)
%   Maintained in 2022 by Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','fieldtrip','fileio'));

% get data
% -------------------------------------------------------------------------
w_state = warning('query');
warning('off', 'all'); % unfortunately the warning is not issued with an ID
hdr = ft_read_header(datafile);
indata = ft_read_data(datafile);
try mrk = ft_read_event(datafile, 'detectflank', []); catch, mrk = []; end;
warning(w_state);


% convert 3 dim to 2 dim (collapse all trials into continuous data)
if numel(size(indata)) == 3,
  indata = indata(:,:);
end;

% extract individual channels
% -------------------------------------------------------------------------
% loop through import jobs
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
      import{k}.markerinfo.value = {mrk(:).value};
      import{k}.markerinfo.name = {mrk(:).type};
    else
      warning('ID:channel_not_contained_in_file', ...
        'Marker channel not contained in file %s.\n', datafile); return;
    end;
  end;

end;

% clear path and return
% -------------------------------------------------------------------------
rmpath(pspm_path('Import','fieldtrip','fileio'));
sts = 1;
return;
