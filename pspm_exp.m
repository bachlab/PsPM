function sts = pspm_exp(modelfile, target, statstype, delim)
% pspm_exp exports first level statistics from one or several first-level
% models. The output is organised as a matrix with rows for observations
% (first-level models) and columns for statistics (must be the same for all
% models)
%
% FORMAT:   pspm_exp(modelfile, target, statstype)
%
% mandatory argument
% modelfile: a filename, or cell array of filenames
%
% optional arguments
% target: 'screen' (default), or a name of an output text file
% statstype: 'param', 'cond', 'recon'
%   'param': export all parameter estimates (default)
%   'cond':  GLM - contrasts formulated in terms of conditions,
%            automatically detects number of basis functions and
%            uses only the first one (i.e. without derivatives)
%            other models - contrasts based on unique trial names
%   'recon': export all conditions in a GLM,
%            reconstructs estimated response from all basis functions
%            and export the peak of the estimated response
% delim:     delimiter for output file (default: tab)
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2009-2015 Dominik R Bach (WTCN, UZH)

% $Id$
% $Rev$


% initialise
% ------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;
sts = -1;

% check input arguments
% ------------------------------------------------------------------------
if nargin < 1
    errmsg=sprintf('No model file(s) specified'); 
    warning('ID:invalid_input',errmsg); 
    return;
elseif nargin < 2
    target='screen';
end;
if nargin < 3
    statstype = 'param';
end;
if nargin < 4
    delim = '\t';
end;

% check model file argument (actual files are checked below) --
if ischar(modelfile)
    modelfile = {modelfile};
elseif ~iscell(modelfile)
    warning('ID:invalid_input', 'Model file must be a cell array of char, or char.'); 
    return;
end;

% check target --
if ~ischar(target)
    warning('ID:invalid_input', 'Target must be a char'); 
    return;
elseif strcmp(target, 'screen')
    fid = 1;
else
    % check file extension
    [pth, filename, ext]=fileparts(target);
    if isempty(ext)
        target=fullfile(pth, [filename, '.txt']);
    end;
    % check whether file exists
    if exist(target, 'file') == 2
        overwrite=menu(sprintf('Output file (%s) already exists. Overwrite?', target), 'yes', 'no');
        if overwrite == 2, warning('Nothing written to file.'); return; end;
    end;
    % open or create file for reading and writing, discard contents
    fid = fopen(target, 'w+');
    if fid == -1, warning('Output file (%s) could not be opened.', target); return; end;
end;

% check statstype --
if ~ischar(statstype)
    warning('Stats type must be a char'); 
    return;
elseif strcmpi(statstype, 'param')
    statstype = 'stats';
elseif ~strcmpi(statstype, {'cond', 'recon'})
    warning('ID:invalid_input', 'Unknown Stats type (%s)', statstype); 
    return;
end;

% check delimiter --
if ~ischar(delim)
    warning('ID:invalid_input', 'Delimiter must be a char'); return;
end;

% get data
% -------------------------------------------------------------------------
% load & check data --
usenames = 1;
for iFile = 1:numel(modelfile)
    [lsts, data(iFile), modeltype{iFile}] = pspm_load1(modelfile{iFile}, statstype);
    if lsts == -1, return; end;
    if iFile > 1
        if ~strcmpi(modeltype{iFile}, modeltype{1})
            warning('First level files must use the same model (File 1: %s, File %2.0f: %s)', ...
                modeltype{1}, iFile, modeltype{iFile}); return;
        elseif ~(ndims(data(iFile).stats) == ndims(data(1).stats)) || ...
                ~all(size(data(iFile).stats) == size(data(1).stats))
            warning('First level files must have the same structure (File 1 vs. File %2.0f)', iFile);
            return;
        elseif ~(numel(data(iFile).names) == numel(data(1).names)) || ...
                ~all(strcmpi(data(iFile).names, data(1).names));
            usenames = 0;
        end;
    end;
end;

% create output data --
for iFile = 1:numel(data)
    outdata(iFile, :) = data(iFile).stats(:);
end;

% create output names --
if ~usenames
    outnames = {'Model files have different parameter names - name output suppressed.'};
elseif strcmpi(modeltype{1}, 'GLM')
    outnames = data(1).names;
else
    if strcmpi(statstype, 'stats')
        trlnames = data(1).trlnames;
    elseif strcmpi(statstype, 'cond')
        trlnames = data(1).condnames;
    end;
    % combine with measure names
    cName = 1;
    for iMsr = 1:size(data(1).stats, 2)
        for iTrl = 1:size(data(1).stats, 1)
            outnames{cName} = sprintf('%s - %s', trlnames{iTrl}, data(1).names{iMsr});
            cName = cName + 1;
        end;
    end;
end;

% create stats description --
if strcmpi(statstype, 'stats')
    statstypechar = 'All parameter estimates';
elseif strcmpi(statstype, 'cond') && strcmpi(modeltype{1}, 'GLM')
    statstypechar = 'Canonical parameter estimate per condition';
elseif strcmpi(statstype, 'cond') && strcmpi(modeltype{1}, 'DCM')
    statstypechar = 'Average parameter estimate per condition';
elseif strcmpi(statstype, 'recon')
    statstypechar = 'Reconstructed response amplitude per condition';
else
    warning('No valid data type'); return;
end;


% output --
% header -
fprintf(fid, 'Statistics for models of type ''%s'' (statistics type: %s) \n', modeltype{1}, statstypechar);
% variable names -
for iName = 1:numel(outnames)
    fprintf(fid, sprintf('%s%s', outnames{iName}, delim));
end;
fprintf(fid, '\n');
% data -
for iRow = 1:size(outdata, 1)
    for iCol = 1:size(outdata, 2)
        fprintf(fid, sprintf('%8.8f%s', outdata(iRow, iCol), delim));
    end;
    fprintf(fid, '\n');
end;
fprintf(fid, '\n');
% close file -
if fid ~= 1
    fclose(fid);
end;

% return --
sts = 1;
return;






