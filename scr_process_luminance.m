function [sts, out] = scr_process_luminance(ldata, sr, options)
% function to process raw luminance data and transfer it into two nuisance
% regressors (dilation and constriction) for glm
%
% [sts, out] = scr_process_luminance(ldata, sr, options)
%   Inputs:
%       ldata:      luminance data as (cell of) 1x1 double
%       sr:         sample rate in Hz of the input data
%       options:    struct with optional settings
%           .transfer   params for the transfer function
%           
%           .bf         settings for the basis functions
%               .duration       duration of the basis functions in s
%               .offset         offset in s
%               .dilation       options for the dilation basis function
%                   .fhandle        function handle to the dilation
%                                   response function
%               .constriction       
%                   .fhandle        function handle to the constriction
%                                   response function
%           .fn         filename; if specified out.reg will be saved to
%                       a file with filename options.fn into the 
%                       variable 'R'
%
%           .overwrite  [true/FALSE] specifies if file specified with
%                       options.fn should be overwritten or not.
%
%           .dont_ask_overwrite [true/FALSE] specifies if user should be
%                               asked whether file should be overwritten 
%                               or not. Only when file specified with 
%                               options.fn already exists and 
%                               options.overwrite == false
%           
% 
%   Outputs:
%           sts:    status
%           out:    struct with output parameters
%               .reg:    2x1 Array of two nuisance regressors
%               .file:   returns filename where the nuisance data has been
%                        saved to
%__________________________________________________________________________
% PsPM 3.1
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sts = -1;

% ensure parameters are correct
% -------------------------------------------------------------------------
if nargin < 1
    warning('ID:invalid_input', 'Missing input data.'); return;
elseif isempty(ldata)
    warning('ID:invalid_input', 'Empty luminance data.'); return;
elseif ~isnumeric(ldata) && ~iscell(ldata)
    warning('ID:invalid_input', 'Luminance data has to be numeric.'); return;
elseif nargin < 2
    warning('ID:invalid_input', 'Missing sample rate.'); return;
elseif ~isnumeric(sr)
    warning('ID:invalid_input', 'Sample rate must be numeric.'); return;
end;

% check options
if nargin < 3
    options = struct();
end;

% setup default values

if ~isfield(options, 'transfer')
    % [A, B, C]
    options.transfer = [30.8093436443031,-1.02893596973461,-0.465448527907005];
end;

if ~isfield(options, 'bf')
    options.bf = struct();
end;

if ~isfield(options.bf, 'duration')
    options.bf.duration = 20;
end;

if ~isfield(options.bf, 'offset')
    options.bf.offset = 0.2;
end;

if ~isfield(options.bf, 'dilation')
    options.bf.dilation = struct();
end;

if ~isfield(options.bf, 'constriction')
    options.bf.constriction = struct();
end;

if ~isfield(options.bf.dilation, 'fhandle')
    options.bf.dilation.fhandle = @scr_bf_ldrf_gm;
end;

if ~isfield(options.bf.constriction, 'fhandle')
    options.bf.constriction.fhandle = @scr_bf_lcrf_gm;
end;
    
if ~isa(options.bf.constriction.fhandle, 'function_handle')
    warning('ID:invalid_input', ['options.bf.constriction.fhandle has', ...
        ' to be a valid function handle.']); return;
elseif ~isa(options.bf.dilation.fhandle, 'function_handle')
    warning('ID:invalid_input', ['options.bf.dilation.fhandle has', ...
        ' to be a valid function handle.']); return;
end;

% if one is not a cell
if ~(iscell(ldata) && iscell(sr))
    % if both are not cells
    if ~iscell(ldata) && ~iscell(sr)
        ldata = {ldata};
        sr = {sr};
    else
        warning('ID:invalid_input', 'If either ldata or sr is a cell the other has to be a cell too.'); return;
    end;
end;

% cycle through data 
[w, h] = size(ldata);
for i = 1:w
    for j = 1:h
        % initialise data variables
        % -----------------------------------------------------------------
        lumd = ldata{i,j};
        s = size(lumd);
        if (s(1) ~= 1 && s(2) ~= 1) || ~isnumeric(lumd)
            warning('ID:invalid_data', ['Luminance data is not numeric', ...
                'and not 1xn ldata{%i,%i}'], [i,j]); 
            return;
        elseif s(1) < s(2)
            % transpose data
            lumd = lumd';
            s = size(lumd);
        end;
        
        lsr = sr{i,j};
        n_bf = options.duration*lsr;
        
        lumd = [repmat(lumd(1),n_bf,1);lumd];
                
        % transfer data
        transd = zeros(numel(lumd), 1);
        % event data
        eventd = zeros(numel(lumd), 1);
        % regressor data
        regd = zeros(numel(lumd)-n_bf, 2);
        
        % calculate duration in s
        dur = (numel(lumd)-n_bf)/lsr;

        % transfer luminance data into steady state data
        % -----------------------------------------------------------------

        p = options.transfer;
        a = p(1);
        b = p(2);
        c = p(3);
        transd = -(a * exp(lumd * c) + b);

        % find changes
        % -----------------------------------------------------------------
        
        % find events of increasing luminance
        ev = diff(lumd) > 0;
        ev(end+1) = 0;
        
        eventd = +ev;
        
        % create regressor 1 (bf1)
        % -----------------------------------------------------------------        
        o = struct();
        o.offset = options.offset;
        o.duration = options.duration;
        
        bf1d = zeros(n_bf, 1);
        bf1d(:) = feval(options.bf.dilation.fhandle, lsr^-1, o);
      
                
        % create regressor 2 (bf2)
        % -----------------------------------------------------------------
        % bf2: constriction      
        bf2d = zeros(n_bf, 1);
        bf2d(:) = feval(options.bf.constriction.fhandle, lsr^-1, o);
        
        % scale data max(abs(.)) should be 1 and min(.) should be 0
        % -----------------------------------------------------------------
        bf1d = bf1d - min(bf1d);
        bf2d = bf2d - min(bf2d);
        
        bf1d = bf1d/max(abs(bf1d));
        bf2d = bf2d/max(abs(bf2d));
        
        % convolve ready state with bf's
        % -----------------------------------------------------------------
        tmp_reg1 = conv(transd, bf1d);
        tmp_reg2 = conv(eventd, bf2d);
        
        regd(:, 1) = tmp_reg1((n_bf+1):(dur*lsr+n_bf))*(-1);
        regd(:, 2) = tmp_reg2((n_bf+1):(dur*lsr+n_bf))*(-1);
        
        reg{i,j} = regd;
    end;
    
end;

if size(reg) == [1 1]
    reg = reg{1};
end;

out.reg = reg;

sts = 1;

