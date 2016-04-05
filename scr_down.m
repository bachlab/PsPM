function [sts, newfile]=scr_down(datafile, newsr, chan, options)
%
% SCR_DOWN downsamples a SCRalyze dataset to the desired new sample rate
% this function applies anti-aliasing filtering at 1/2 of the new sample
% rate. The data will be written to a new file, the original name will be
% prepended with 'd'
%
% FORMAT:
% [STS, NEWFILE] = SCR_DOWN(datafile, newsr, chan, options)
%
% INPUT: 
%   datafile:   can be a name, or for convenience, a cell array of filenames
%   newfreq:    new frequency (must be >= 10 Hz)
%   chan:       channels to downsample (default: all channels)
%   options:    options.overwrite - overwrite existing files by default
%
% OUTPUT:
%   sts:        1 if the 
%   newfile:    a filename for the updated file, or cell array of filenames
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2010-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_down.m 714 2015-02-05 15:10:44Z tmoser $  
% $Rev: 714 $

global settings;
if isempty(settings), scr_init; end;
sts = -1;

% check input arguments
% -------------------------------------------------------------------------
if nargin<1
    errmsg='No data file'; warning('ID:invalid_input', errmsg); return;
elseif nargin<2
    errmsg='No frequency given'; warning('ID:invalid_input', errmsg); return;
elseif newsr < 10
    errmsg='This function does not support downsampling to frequencies below 10 Hz.';
    warning('ID:rate_below_minimum', errmsg);
    return;
end;
    
if nargin < 3 || isempty(chan)
    chan = 0;
elseif isnumeric(chan) && isvector(chan)
    if numel(chan) == 1 && chan < 0
        warning('ID:invalid_input', 'chan must be nonnegative'); return;
    elseif any(chan < 0)
        warning('ID:invalid_input', 'All elements of chan must be positive'); return;
    end
elseif ischar(chan)
    if strcmpi(chan, 'all')
        chan = 0;
    else
        warning('ID:invalid_input', 'Channel argument must be a number, or ''all''.'); return;
    end;
end;

if nargin == 4 && ~isstruct(options)
    warning('ID:invalid_input','options has to be a struct'); 
    return;
end
      
    
% set options
% -------------------------------------------------------------------------
try
    if options.overwrite ~= 1, options.overwrite = 0; end;
catch
    options.overwrite = 0;
end;


% convert datafile to cell for convenience
% -------------------------------------------------------------------------
if iscell(datafile)
    D=datafile;
else
    D={datafile};
end;
clear datafile

% work on all data files
% -------------------------------------------------------------------------
for d=1:numel(D)
    % determine file names
    datafile=D{d};
    
    % check and get datafile
    [sts infos data] = scr_load_data(datafile, 0);
    if sts == -1, continue; end;
    
    if any(chan > numel(data))
        warning('Datafile %s contains only %i channels. At least one selected channel is inexistent', datafile, numel(data)); return;
    end
    
    % set channels
    if chan == 0
        chan = 1:numel(data);
    end;
    
    % make outputfile
    [p f ex]=fileparts(datafile);
    newfile=fullfile(p, ['d', f, ex]);
    
    if exist(newfile)==2 && ~options.overwrite
        overwrite=menu(sprintf('New file (%s) already exists. Overwrite?', newfile), 'yes', 'no');
        %close gcf;
        if overwrite==2, return; end;
    end;
    
    % user output
    fprintf('Downsampling %s ... ', datafile);
    
    % downsample channel after channel
    for k = chan
        % leave event channels alone
        if strcmpi(data{k}.header.units, 'events')
            fprintf('\nNo downsampling for event channel %2.0f in datafile %s ...', k, datafile);
        else
            filt.sr = data{k}.header.sr;
            filt.lpfreq = newsr/2;
            filt.lporder = 1;
            filt.hpfreq = 'none';
            filt.hporder = 0;
            filt.direction = 'bi';
            filt.down = newsr;
            [sts, foo, sr] = scr_prepdata(data{k}.data, filt);
            data{k}.data = foo;
            data{k}.header.sr = sr;
        end;
    end;
    
    [pth nfn ext] = fileparts(newfile);
    infos.downsampledfile = [nfn ext];
    save(newfile, 'infos', 'data');
    Dout{d}=newfile;
  
end;

% user output
fprintf('  done.\n');

% if cell array of datafiles is being processed, return cell array of
% filenames
if d>1
    clear newdatafile
    newfile=Dout;
end;

sts = 1;

return;
