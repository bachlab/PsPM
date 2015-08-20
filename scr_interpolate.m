function [sts, outdata] = scr_interpolate(indata, options)
% SCR_INTERPOLATE
% 
% [sts, outdata] = scr_interpolate(indata, options)
% This function interpolates NaN values passed with the indata parameter.
% The behaviour of the function can furthermore be adjusted with the
% combination of different options.
%
%   indata: [struct/char/numeric] or [cell array of struct/char/numeric]
%           contains the data to be interpolated
%  
%   options: 
%       .overwrite:     defines if existing datafiles should be overwritten
%       .method:        defines the interpolation method see interp1() for
%                       possible interpolation methods
%       .channels       if pass should be the same size as indata and
%                       contains for each entry in indata the channel(s) to 
%                       be interpolated.
%       .newfile        if false the data will be added to the file where
%                       the data was loaded from. if true the data will be
%                       written to a new file prepended with 'i'.
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
% will return a cell of the same size as the indata
outdata = {};
sts = -1;

% check input arguments
% -------------------------------------------------------------------------
if nargin<1
    warning('ID:invalid_input', 'No data.\n'); 
    return;
end;

% set options ---
try options.overwrite; catch, options.overwrite = 0; end;
try options.method; catch, options.method = 'linear'; end;
try options.channels; catch, options.channels = {}; end;
try optinos.newfile; catch, options.newfile = false; end;

if numel(options.channels) > 0
    if numel(options.channels) ~= numel(indata)
        warning('ID:invalid_input', 'options.channels must have same size as indata');
    elseif (numel(options.channels) == 1) && ~iscell(options.channels)
        options.channels = {options.channels};
    end;
end;

% check data file argument --
if ischar(indata) || isstruct(indata) || isnumeric(indata)
    D = {indata};
elseif iscell(indata)
    D = indata;
else
    warning('ID:invalid_data', 'Data must be char, numeric or cell');
end;

outdata = cell(size(D));

% work on all data files
% -------------------------------------------------------------------------
for d=1:numel(D)
    % determine file names ---
    actual=D{d};
        
    % flag to decide what kind of data should be handled
    inline_flag = 0;
    
    % user output ---
    if ischar(actual)
        fprintf('Interpolating %s ... ', actual);
    else
        fprintf('Interpolating ... ');
        if isnumeric(actual)
            inline_flag = 1;
        end;
    end;
    
    % not inline data must be loaded first; check and get datafile ---
    if ~inline_flag
        % struct get checked if structure is okay; files get loaded
        [sts, infos, data] = scr_load_data(actual, 0);
        if any(sts == -1)
            warning('ID:invalid_input', 'Cannot load data from data');
            break;
        end;

        if numel(options.channels{d}) > 0
            % channels passed; try to get appropriate channels
            c = options.channels{d};
            chans = data{c};
        else
            % no channels passed; try to search appropriate channels
            c = cellfun(@(f) ~strcmpi(f.header.units, 'events'), data);
            chans = data{c};
        end;
    else
        chans = {actual};
    end
    
    % trim file ---
    for k = 1:numel(chans)
        if inline_flag
            dat = chans{k};
        else
            dat = chans{k}.data;
        end;
        
        x = 1:length(dat);
        v = dat;
        
        % add some other checks if you want to filter out more
        % data like this
        
        filt = isnan(v);
        xq = find(filt);
        
        % throw away data matching 'filt'
        
        x(xq) = [];
        v(xq) = [];
        vq = interp1(x, v, xq, options.method);
        dat(xq) = vq;
        
        if inline_flag
            chans{k} = dat;
        else
            chans{k}.data = dat;
        end;
    end;
    
    if ~inline_flag 
        clear savedata
        savedata.data = chans;
        savedata.infos = infos;
        
        if isstruct(actual)
            % check datastructure
            sts = scr_load_data(savedata, 'none');
            outdata{d} = savedata;
        else
            if options.newfile
                % save as a new file preprended with 'i'
                [pth, fn, ext] = fileparts(actual);
                newdatafile    = fullfile(pth, ['i', fn, ext]);
                savedata.infos.interpolatefile = newdatafile;
                savedata.options = options;
                sts = scr_load_data(newdatafile, savedata);
                
                outdata{d} = newdatafile;
            else
                % add to existing file 
                o.msg.prefix = 'Interpolated channel';
                [sts, infos] = scr_write_channel(actual, savedata, 'add', o);
                
                % added channel ids are in infos.channel
                outdata{d} = infos.channel;
            end;
        end;
    else
        outdata{d} = chans{1};
    end;
   
end;

sts = 1;


    
