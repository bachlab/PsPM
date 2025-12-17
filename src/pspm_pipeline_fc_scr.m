function [sts, out] = pspm_pipeline_fc_scr(fn, missing, onsets, isi, method, normalize, keepfile)
% ● Description
% This function runs a standard PsPM pipeline for fear-conditioned SCR,
% based on the winning methods from the paper de Vries et al. (2026) in
% preparation. 
% ● Format
% [sts, out] = pspm_pipeline_fc_scr(fn, missing, onsets, soa, method,  norm, keepfile)
% ● Arguments
% * fn: a PsPM data file name, or cell array of file names
% * missing: a PsPM epoch file name (set to [] if no missing file), or cell
%   array of epoch file names
% * onsets: onset times of all CS (vector), or cell array of onset times
% * isi: CS-US interval in s (scalar or vector, in the latter case must be
%        defined for all trials, or cell array)
% * method: one of '2026_short', '2026_long_uni', '2026_long_bi'. Here, 
%          'long/short' refer to the isi in de Vries et al. (which was 
%           3.5 s for 'short', and > 6 s for 'long'), and 'uni/bi' refers 
%          to unidirectional or bidirectional filtering (where bidirectional 
%          filtering was slightly better for long ISI in the tested
%          data sets but can be suboptimal with long inter-trial intervals.
%          For short ISI, unidirectional filtering was always better).
% * normalize: [optional] Normalise data. Data are normalised during inversion 
%         but results are transformed back into raw data units. Default: 0.
% * keepfile: [optional] Save model file for diagnostic purposes. Default: 0.
% 
% ● Outputs
% * out: trial-by-trial estimate of the conditioned response.
% ● History
% Introduced in PsPM 7.2
% ● References
% [1] de Vries et al. (2026) forthcoming.

%% Initialise. 
% most of the checks are performed in downstream functions and give
% expressive warnings
global settings
if isempty(settings)
    pspm_init;
end
sts = -1;
out = [];

if nargin < 5
    warning('Don''t know what to do');
    return
end

if nargin < 6
    normalize = 0;
end

if nargin < 7
    keepfile = 0;
end

%% Parse options and setup timings
if ~iscell(fn)
    onsets = {onsets};
    isi    = {isi};
end

for i_sn = 1:numel(onsets)
    timing{i_sn}{1} = onsets{i_sn}(:) + isi{i_sn}(:);
    if ismember(method, {'2026_short'})
        % flex-fix
        timing{i_sn}{2} = [onsets{i_sn}(:); onsets{i_sn}(:) + isi{i_sn}(:)];
    elseif ismember(method, {'2026_long_uni', '2026_long_bi'})
        % flex-flex-fix with halved ISI
        timing{i_sn}{2} = [onsets{i_sn}(:), onsets{i_sn}(:) + isi{i_sn}(:)/2];
        timing{i_sn}{3} = [onsets{i_sn}(:) + isi{i_sn}(:)/2, onsets{i_sn}(:) + isi{i_sn}(:)];
    else
        warning('Unknown method');
        return
    end
end

if ~iscell(fn)
    timing = timing{1};
end

%% Setup model
% set (dummy) filename
[pth, fn_model, ext] = fileparts(fn);
model_fn = fullfile(pth, ['mdl_', fn_model, ext]);

model = struct( ...
    'datafile', fn, ...
    'missing', missing, ...
    'modelfile', model_fn, ...
    'norm', normalize);
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
options = struct('overwrite', 0, 'nosave', 1-keepfile);

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

