function [sts, out] = pspm_pipeline_fc_scr(fn, onsets, isi, varargin)
% PSPM_PIPELINE_FC_SCR  Run PsPM DCM pipeline for fear-conditioned SCR
%
% ● Description
%   Runs a standard PsPM pipeline for fear-conditioned skin conductance
%   responses (SCR), based on the methods described in:
%   de Vries et al. (2026, in preparation).
%
%   The function supports single or multiple sessions/files. All inputs are
%   internally normalised to cell arrays and processed per session.
%
% ● Format
%   [sts, out] = pspm_pipeline_fc_scr(fn, onsets, isi);
%       - Uses default method: '2026_long_uni'
%       - No missing data
%       - No normalization, no file saving, no overwrite
%
%   [sts, out] = pspm_pipeline_fc_scr(fn, onsets, isi, 'method', '2026_short');
%       - Use the short-ISI model
%       - Unidirectional filtering
%       - Suitable for short CS–US intervals (~3.5 s)
%
%   [sts, out] = pspm_pipeline_fc_scr(fn, onsets, isi, 'missing', missing_file);
%       - Exclude artefact/missing segments defined in missing_file
%       - Useful for handling signal dropouts or invalid epochs
%
%   [sts, out] = pspm_pipeline_fc_scr(fn, onsets, isi, 'normalize', 1);
%       - Enable normalization during model inversion
%       - Results are returned in original data units
%
%   [sts, out] = pspm_pipeline_fc_scr(fn, onsets, isi, ...
%       'method', '2026_long_bi', ...
%       'normalize', 1, ...
%       'keepfile', 1, ...
%       'overwrite', 1);
%       - Use long-ISI model with bidirectional filtering
%       - Enable normalization
%       - Save model file to disk
%       - Overwrite existing model files if present
%
% ● Arguments
%  * fn:       - PsPM data file (string/char) or cell array of files
%
%  * onsets:   - CS onset times (in seconds)
%               • numeric vector, or cell array of vectors (one per session)
%
%  * isi:      - CS–US interval (in seconds)
%               • scalar (applied to all trials)
%               • vector (same length as onsets per session)
%               • or cell array (one entry per session)
%
%  * method:   - (optional) Processing method (string)
%               Default: '2026_long_uni'
%               • '2026_short'
%               • '2026_long_uni'
%               • '2026_long_bi'
%
%               Interpretation:
%               - 'short' vs 'long' refers to ISI regime
%               - 'uni' / 'bi' refers to filter direction
%
%  * missing:   - (optional) Missing/artefact epochs file(s), or []
%               • string/char, cell array, or []
%               • if empty, no missing data are applied
%
%  * normalize:- (optional) logical or 0/1
%               Normalize data during inversion (default: 0)
%
%  * keepfile: - (optional) logical or 0/1
%               Save model file to disk (default: 0)
%
%  * overwrite:- (optional) logical or 0/1
%               Overwrite existing model files (default: 0)
%
% ● Outputs
%  * sts:       - Status flag returned by pspm_dcm
%               > 0 indicates success
%
%  * out:       - Trial-wise conditioned response estimates
%               • short ISI: amplitude estimates
%               • long ISI: combined amplitude × dispersion estimates
%
% ● Notes
%   - All inputs are internally converted to cell arrays for consistency.
%   - ISI must be scalar or match the number of trials per session.
%   - Number of sessions must match across fn, onsets, and missing.
%
% ● History
%   Introduced in PsPM 7.2
%
% ● Reference
%   de Vries et al. (2026). In preparation.


%% Initialise. 
% most of the checks are performed in downstream functions and give
% expressive warnings
global settings
if isempty(settings)
    pspm_init;
end
sts = -1;
out = [];

% set default args
p = inputParser;
addParameter(p, 'method', '2026_long_uni',  @(x) ischar(x) );
addParameter(p, 'missing', [],  @(x) isempty(x)   || ischar(x) || iscell(x));
addParameter(p, 'normalize', 0, @(x) (islogical(x) || isnumeric(x)) && isscalar(x) && ismember(x, [0 1]));
addParameter(p, 'keepfile',  0, @(x) (islogical(x) || isnumeric(x)) && isscalar(x) && ismember(x, [0 1]));
addParameter(p, 'overwrite', 0, @(x) (islogical(x) || isnumeric(x)) && isscalar(x) && ismember(x, [0 1]));
parse(p, varargin{:});

method    = p.Results.method;
missing   = p.Results.missing;
normalize = p.Results.normalize;
keepfile  = p.Results.keepfile;
overwrite = p.Results.overwrite;

%% Parse inputs
if ~iscell(fn)
    fn = {fn};
end

if ~iscell(onsets)
    onsets = {onsets};
end

if isempty(missing)
    missing = cell(size(fn));
elseif ~iscell(missing)
    missing = {missing};
end

if ~iscell(isi)
    isi = {isi};
end

% input consistency checks
n_sn = numel(fn);

if numel(onsets) ~= n_sn
    error('Number of onset vectors must match number of data files.');
end

if numel(missing) ~= n_sn
    error('Number of missing files must match number of data files.');
end

if ~(numel(isi) == 1 || numel(isi) == n_sn)
    error('ISI must be scalar/vector for all sessions or one entry per data file.');
end

%% sort out trial-wise inputs
timing = cell(size(fn));

for i_sn = 1:n_sn
    this_onsets = onsets{i_sn}(:);

    if numel(isi) == 1
        this_isi = isi{1};
    else
        this_isi = isi{i_sn};
    end

    if isscalar(this_isi)
        this_isi = repmat(this_isi, size(this_onsets));
    else
        this_isi = this_isi(:);
    end

    if numel(this_isi) ~= numel(this_onsets)
        error('ISI must be scalar or match the number of onsets for session %d.', i_sn);
    end

    timing{i_sn}{1} = this_onsets + this_isi;

    if strcmpi(method, '2026_short')
        % flex-fix
        timing{i_sn}{2} = [this_onsets, this_onsets + this_isi];

    elseif ismember(method, {'2026_long_uni', '2026_long_bi'})
        % flex-flex-fix with halved ISI
        timing{i_sn}{2} = [this_onsets, this_onsets + this_isi/2];
        timing{i_sn}{3} = [this_onsets + this_isi/2, this_onsets + this_isi];

    else
        error('Unknown method "%s". Use 2026_short, 2026_long_uni, or 2026_long_bi.', method);
    end
end

%% Setup model
% set (dummy) filename
% One DCM model file for all sessions together
[pth_i, fn_m_i, ~] = fileparts(fn{1});

if numel(fn) == 1
    model_fn = fullfile(pth_i, ['mdl1_', fn_m_i, '.mat']);
else
    model_fn = fullfile(pth_i, ['mdl1_', fn_m_i, '_multi.mat']);
end

model = struct( ...
    'modelfile', model_fn, ...
    'norm', normalize ...
);

model.datafile = fn;
model.missing = missing;
model.timing = timing;

if strcmpi(method, '2026_short')
    model.constrained = 1;
    % filter
    model.filter = settings.dcm{1}.filter;
    model.filter.direction = 'uni';
elseif strcmpi(method, '2026_long_uni')
    % this is a hidden option in pspm_dcm_inv (upper bound in s)
    model.constrained_upper = 1; 
    % filter
    model.filter = settings.dcm{1}.filter;
    model.filter.direction = 'uni';
elseif strcmpi(method, '2026_long_bi')
    % default model
end

%% Setup options
options = struct( ...
    'overwrite', overwrite, ...
    'nosave', 1 - keepfile ...
);

%% Run DCM
[sts, dcm] = pspm_dcm(model, options);

%% Construct readout for short and long SOA
if sts > 0
    % find amplitude and dispersion estimates
    amp_indx = find(contains(dcm.names, 'amplitude'));
    disp_indx = find(contains(dcm.names, 'dispersion'));

    if startsWith(method, '2026_short')
        out = dcm.stats(:, amp_indx);
    elseif startsWith(method, '2026_long')
        out = dcm.stats(:, amp_indx(1)) .* dcm.stats(:, disp_indx(1)) + ... % a x c for each response, then summed
              dcm.stats(:, amp_indx(2)) .* dcm.stats(:, disp_indx(2)); 
    end
end
end