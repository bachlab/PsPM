function varargout = pspm_sf_dcm(scr, sr, options)
% ● Description
%   pspm_sf_dcm does dynamic causal modelling for SF of the skin conductance
%   uses f_SF and g_Id
%   the input data is assumed to be in mcS, and sampling rate in Hz
% ● Format
%   function out = pspm_sf_dcm(scr, sr, options)
% ● Output
%         out:  output
%          .n:  number of responses above threshold
%          .f:  frequency of responses above threshold in Hz
%         .ma:  mean amplitude of responses above threshold
%          .t:  timing of (all) responses
%          .a:  amplitude of (all) responses
%      .theta:  parameters used for f_SF
%  .threshold:  threshold
%         .if:  initial frequency for f_SF
%       .yhat:  fitted time series
%      .model:  information about the DCM inversion
% ● Arguments
%         scr:  skin conductance epoch (maximum size depends on computing
%               power, a sensible size is 60 s at 10 Hz)
%          sr:  sampling rate in Hz
%     options:  options structure
%  .threshold:  threshold for SN detection (default 0.1 mcS)
%      .theta:  a (1 x 5) vector of theta values for f_SF
%               (default: read from pspm_sf_theta)
%      .fresp:  frequency of responses to model (default 0.5 Hz)
%    .dispwin:  display progress window (default 1)
%  .dispsmallwin:
%               display intermediate windows (default 0);
%    .missing:  index of missing values to ignore
% .missingthresh: threshold value for controlling missing epochs (default 2s).
% ● References
%   Bach DR, Daunizeau J, Kuelzow N, Friston KJ, & Dolan RJ (2011). Dynamic
%   causal modelling of spontaneous fluctuations in skin conductance.
%   Psychophysiology, 48, 252-57.
% ● History
%   Introduced In PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
tstart = tic;
%% 2 Check input arguments
if nargin < 2 || ~isnumeric(sr) || numel(sr) > 1
  errmsg = sprintf('No valid sample rate given.');
elseif (sr < 1) || (sr > 1e5)
  errmsg = sprintf('Sample rate out of range.');
elseif exist('osr', 'var') && osr ~= sr
  errmsg = sprintf('Sample rate of theta file is different from sample rate of data.');
elseif nargin < 1 || ~isnumeric(scr)
  errmsg = 'No data.';
elseif ~any(size(scr) == 1)
  errmsg = 'Input SCR is not a vector';
else
  scr = scr(:);
end
if exist('errmsg', 'var') == 1
  warning(errmsg);
  out = [];
  return;
end
%% 3 Sorting options
options = pspm_options(options, 'sf_dcm');
if options.invalid
  return
end
options.DisplayWin = options.dispwin;
options.GnFigs = options.dispsmallwin;
fresp = options.fresp;
threshold = options.threshold;
try
  theta = options.theta;
catch
  [theta, ~] = pspm_sf_theta;
end
%% 4 Invert model
phi   = [0 0];
% 4.1 DAVB settings
g_fname = 'g_Id';
f_fname = 'f_SF';
dim.n_phi   =  numel(phi);
dim.n       =  3;
priors.SigmaX0 = [1e-8 0 0; 0 1e2 0; 0 0 1e2];
priors.a_sigma = 1e5;
priors.b_sigma = 1e1;
priors.a_alpha = Inf;
priors.b_alpha = 0;
% 4.2 initialise priors in correct dimensions
priors.iQy = cell(numel(scr), 1);
priors.iQx = cell(numel(scr), 1);
for k = 1:numel(scr)  % default priors on noise covariance
  priors.iQy{k} = 1;
  priors.iQx{k} = eye(dim.n);
end
options.inG.ind = 1;
options.inF.dt = 1/sr;
% 4.3 prepare data
y = scr;
y = y - min(y);
% 4.4 determine initial conditions
x0 = y(1:3);
X0(1, 1)   = mean(x0);
X0(2, 1)   = mean(diff(x0));
X0(3, 1)   = diff(diff(x0));
priors.muX0 = X0;
nresp = floor(fresp * numel(y)/sr) + 1;
u = [];
u(1, :) = (1:numel(y))/sr;
u(2, :) = nresp;
priors.muTheta = theta(1:3)';
priors.muTheta(4:2:(2 * nresp + 3)) = 1/fresp * (0:(nresp-1));
priors.muTheta(5:2:(2 * nresp + 4)) = -10;
dim.n_theta = numel(priors.muTheta);    % nb of evolution parameters
priors.SigmaTheta = zeros(dim.n_theta);
for k = (4:2:(2 * nresp + 3)), priors.SigmaTheta(k, k) = 1e-2;end
for k = (5:2:(2 * nresp + 4)), priors.SigmaTheta(k, k) = 1e2; end
priors.muPhi = phi';
priors.SigmaPhi = zeros(dim.n_phi);
priors.SigmaX0 = 1e-8*eye(dim.n);
options.priors = priors;
% 4.5 estimate parameters
c = clock;
fprintf(['\n\nEstimating model parameters for f_SF ... \t%02.0f:%02.0f:%02.0f', ...
  '\n=========================================================\n'], c(4:6));
if isfield(options, 'missing')
  ymissing = options.missing;
else
  ymissing = isnan(y);
end
ymissing_start = find(diff(ymissing)==1);
ymissing_end = find(diff(ymissing)==-1);
if length(ymissing_start) > length(ymissing_end)
  ymissing_end = [ymissing_end, length(ymissing_end)];
elseif length(ymissing_start) < length(ymissing_end)
  ymissing_start = [1, ymissing_start];
end
miss_epoch = [ymissing_start(:),ymissing_end(:)];
flag_missing_too_long = 0;
if any(diff(miss_epoch, 1, 2)/sr > options.missingthresh)
  warning_message = ['Imported data includes too long miss epoches (over ',...
    num2str(options.missingthresh), 's), thus estimation has been skipped.'];
  warning('ID:missing_data', warning_message);
  flag_missing_too_long = 1;
end
options.isYout = ymissing(:)';
%% 5 Extract parameters
[posterior, output] = VBA_NLStateSpaceModel(y(:)',u,f_fname,g_fname,dim,options);
for i = 1:length(output)
  output(i).options = rmfield(output(i).options, 'hf');
end
t = posterior.muTheta(4:2:end);
a = exp(posterior.muTheta(5:2:end) - theta(5));   % rescale
ex = find(t < -2 | t > (numel(scr)/sr - 1)); % find SA responses the SCR peak of which is outside episode
t(ex) = []; a(ex) = [];
%% 6 Outputs
if ~flag_missing_too_long
  out.t               = t - theta(4);                             % subtract conduction delay
  out.a               = a;
  out.n               = numel(find(a > threshold));
  out.f               = out.n/(numel(scr)/sr);
  out.ma              = mean(a(a > threshold));
  out.theta           = theta;
  out.if              = fresp;
  out.threshold       = threshold;
  out.yhat            = posterior.muX(1, :);
  out.model.posterior = posterior;
  out.model.output    = output;
  out.model.u         = u;
  out.model.y         = y(:)';
  out.time            = toc(tstart);
else
  out.t               = NaN;
  out.a               = NaN;
  out.n               = NaN;
  out.f               = NaN;
  out.ma              = NaN;
  out.theta           = NaN;
  out.if              = NaN;
  out.threshold       = NaN;
  out.yhat            = NaN;
  out.model.posterior = NaN;
  out.model.output    = NaN;
  out.model.u         = NaN;
  out.model.y         = NaN;
  out.time            = NaN;
  out.warning         = warning_message;
end
sts = 1;
switch nargout
  case 1
    varargout{1} = out;
  case 2
    varargout{1} = sts;
    varargout{2} = out;
end
return
