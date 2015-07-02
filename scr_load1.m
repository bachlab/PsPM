function [sts, data, mdltype] = scr_load1(fn, action, savedata, options)
% FORMAT: [sts, data, mdltype] = scr_load1(datafile, action, savedata, options)
%           datafile: filename
%           action (default 'none'):
%                   'none':  check whether file is valid at all
%                   'stats': retrieve stats struct with fields .stats 
%                            and .names
%                   'cond':  for GLM - retrieve stats struct using only
%                            first regressor/basis function for each condition 
%                            for models with 2D stats structure - retrieve 
%                            mean parameter values per condition, based on 
%                            unique trial names
%                   'recon': (for GLM) retrieve stats struct using
%                            reconstructed responses (which are at the same
%                            time written into the glm struct as glm.recon)
%                   'con':   retrieve full con structure
%                   'all':   retrieve the full first level structure
%                   'savecon': add contrasts to file, use an additional
%                            input argument data that contains the contrasts
%                   'save':  check and save first levle model, use an additional
%                            input argument data that contains the model
%                            struct
%           data: for 'save' option - a struct containing the model as only
%                           field
%                 for 'savecon' option - contains the con structure                
%           options:        options.zscored 
%                               zscore data - substract the mean and divide
%                               by the standard deviation.
%                           
%                           for 'save' - options.overwrite 
%                           (default: user dialogue)
%
%           output
%           'data' - depending on option
%           'none', 'savecon', 'save':  none
%           'stats', 'recon', 'cond': data.stats, data.names, (and data.trlnames if existing)
%           'con':   con structure
%           'all':   full first level structure
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (WTCN, UZH)

% $Id: scr_load1.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% -------------------------------------------------------------------------
% DEVELOPERS NOTES: General structure of PsPM 1st level model files
% 
% each file contains one struct variable with the model
% allowed model names are specified in scr_init
% each model must contain the following fields:
%   .stats: a n x 1 vector (glm, for n regressors) or n x k matrix (dcm, 
%           sf; for k measures, n trials/epochs)
%   .names: a cell array corresponding to regressor names (glm) or measure 
%           names across trials/epochs (sf, dcm)
%   .trlnames for models with 2D stats structure (dcm, sf)
% optional fields:
%   .recon for reconstructed glm responses
%   .con for contrasts
% -------------------------------------------------------------------------


% initialise & user output
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sts = -1; data = struct; mdltype = 'no valid model';
errmsg = sprintf('Data file %s is not a valid SCRalyze file:\n', fn);
modalities = fieldnames(settings.modalities); % allowed modalities

% check input arguments & set defaults
% -------------------------------------------------------------------------
% check missing input --
if nargin < 1
    warning('No datafile specified'); return;
elseif nargin < 2
    action = 'none';
elseif any(strcmpi(action, {'save', 'savecon'})) && nargin < 3
    warning('Save failed, no data provided'); return; 
end;

% canonicalise file name
[pth, filename, ext] = fileparts(fn);
if isempty(ext)
    ext = '.mat';
end;
fn = fullfile(pth, [filename, ext]);
    

% check whether file exists --
if exist(fn, 'file')
    if strcmpi(action, 'save')
        if ~(nargin > 3 && options.overwrite)
            overwrite = menu(sprintf('File (%s) already exists. Overwrite?', fn), 'yes', 'no');
            if overwrite ~=2
                warning('Data not saved.\n'); return;
            end;
        end;
    end;
elseif ~strcmpi(action, 'save')
    warning('1st level file (%s) doesn''t exist', fn); return;
end;

%  set default zscored
if nargin <= 3 || ~isfield(options, 'zscored')
    options.zscored = 0;
end

% check whether file is a matlab file --
if ~strcmpi(action, 'save')
    try
        indata = load(fn);
    catch
        errmsg = [gerrmsg, 'Not a matlab data file.']; warning(errmsg); return;
    end;
else
    indata = savedata;
end;

% check for SCRalyze 1.x files --
if isfield('indata', 'dsm'), warning('ID:SCRalyze_1_file', 'SCRalyze 1.x compatibility is discontinued'); return; end;

% check for modality
if isfield(indata, 'modality') 
    modality = find(ismember(modalities, indata.modality));
    if isempty(modality)
        warning('No known modalitiy in this file'); return;
    else
        modality = modalities{modality};
        indata.modality = modality;
    end;
else
    % no modality field, use default modality
    modality = 'scr';
    indata.modality = modality;
end;

% update mdltypes
mdltypes = {settings.modalities.(modality).first};

% check file contents
% ------------------------------------------------------------------------
% check model type --
if isfield(indata, 'modeltype')
    mdltype = find(ismember(mdltypes, indata.modeltype));
    if isempty(mdltype)
        warning('%sNo known model type in this file', errmsg); return;
    else
        mdltype = mdltypes{mdltype};
        indata.modeltype = mdltype;
    end;
else
    warning('ID:obsolete_function', ['Modelfile has no field ''modeltype'' defined.', ...
        ' Falling back to determining modeltype from fieldnames.', ...
        ' This backward compatibility will be removed in future versions of PsPM.']);
    % field modeltype is not defined; falling back to old and obsolete
    % behaviour - must be removed in future (present is 24.04.2015)
    mdltype = find(ismember(mdltypes, fieldnames(indata)));
    if isempty(mdltype)
        warning('%sNo known model type in this file', errmsg); return;
    elseif numel(mdltype) > 1
        warning('%sMore than one model type in this file', errmsg); return;
    else
        mdltype = mdltypes{mdltype};
        indata.modeltype = mdltype;
    end;
end;



% check model content --
if ~isfield(indata.(mdltype), 'modelfile')
    warning('%sNo file name contained in model structure.', errmsg); return;
elseif ~isfield(indata.(mdltype), 'stats')
    warning('%sNo stats contained in file.', errmsg); return;
elseif ~isfield(indata.(mdltype), 'names')
    warning('%sNo names contained in file.', errmsg); return;
elseif ~strcmpi(mdltype, 'glm') && ~isfield(indata.(mdltype), 'trlnames')
        warning('%sNo trial names contained in file.', errmsg); return;
elseif strcmpi(mdltype, 'glm') && size(indata.(mdltype).stats, 1) ~= numel(indata.(mdltype).stats)
        warning('%sGLM stats should be a n x 1 vector.', errmsg); return;
elseif strcmpi(mdltype, 'glm') && numel(indata.(mdltype).names) ~= numel(indata.(mdltype).stats)
        warning('%sNumbers of names and parameters do not match.', errmsg); return;
elseif ~strcmpi(mdltype, 'glm') && numel(indata.(mdltype).names) ~= size(indata.(mdltype).stats, 2)
        warning('%sNumbers of names and parameters do not match.', errmsg); return;
elseif ~strcmpi(mdltype, 'glm') && numel(indata.(mdltype).trlnames) ~= size(indata.(mdltype).stats,1)
        warning('%sNumbers of trial names and parameters do not match.', errmsg); return;
end;

% check optional fields --
if ~isfield(indata.(mdltype), 'con')
    conflag = 0;
else
    conflag = 1;
end;
if ~isfield(indata.(mdltype), 'recon')
    reconflag = 0;
else
    reconflag = 1;
end;

% if not glm
% create condition names --
if ~strcmpi(mdltype, 'glm')
    indata.(mdltype).condnames = unique(indata.(mdltype).trlnames);
end;

% retrieve file contents
% -------------------------------------------------------------------------

if options.zscored
    if strcmpi(mdltype, 'dcm') && ...
        (strcmpi(action, 'cond') || strcmpi(action, 'stats'))
        
        indata.(mdltype).stats = zscore(indata.(mdltype).stats);
        data.zscored = 1;
    else
        data.zscored = 0;
        warning(['Z-scoring only available for non-linear models and action ''stats'' or ''cond''. ',...
                'Not z-scoring data!']);
    end
end

switch action
    case 'none'
        data = [];
    case 'stats'
        data.stats = indata.(mdltype).stats;
        data.names = indata.(mdltype).names;
        if ~strcmpi(mdltype, 'glm')
            data.trlnames = indata.(mdltype).trlnames;
            data.condnames = indata.(mdltype).condnames;
        end;
    case 'cond'
        if strcmpi(mdltype, 'glm')
            condindx = 1:(indata.glm.bf.bfno):(numel(indata.glm.stats)-indata.glm.interceptno);
            data.stats = indata.glm.stats(condindx);
            data.names = indata.glm.names(condindx);
            clear condindx
        else
            for iCond = 1:numel(indata.(mdltype).condnames)
                condindx = strcmpi(indata.(mdltype).condnames{iCond}, indata.(mdltype).trlnames);
                data.stats(iCond, :) = mean(indata.dcm.stats(condindx, :), 1);
            end;
            data.names = indata.(mdltype).names;
            data.trlnames = indata.(mdltype).trlnames;
            data.condnames = indata.(mdltype).condnames;
        end;
    case 'recon'
        if strcmpi(mdltype, 'glm')
            if ~reconflag
                [sts, indata.glm] = scr_glm_recon(fn);
                if sts ~= 1, warning('GLM reconstruction not successful.'); return; end;
            end;
            data.stats = indata.glm.recon;
            data.names = indata.glm.reconnames;
        else
            warning('%s. ''recon'' option only defined for GLM files', errmsg);
        end;
    case 'con'
        if conflag
            data = indata.(mdltype).con;
        else
            data = [];
        end;
    case 'all'
        data = indata.(mdltype);
    case 'savecon'
        indata.(mdltype).con = savedata;
        save(fn, '-struct', 'indata', mdltype, 'modeltype');
    case 'save'
        save(fn, '-struct', 'indata', mdltype, 'modeltype');
    otherwise
        warning('Unknown action. Just checking file. File is valid.'); return;
end;


% set status and return
sts = 1;
          









