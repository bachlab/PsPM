function out = pspm_sf_dcm(scr, sr, opt)
% ● Description
%   pspm_sf_dcm does dynamic causal modelling for SF of the skin conductance
%   uses f_SF and g_Id
%   the input data is assumed to be in mcS, and sampling rate in Hz
% ● Format
%   function out = pspm_sf_dcm(scr, sr, opt)
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
% ● References
%   Bach DR, Daunizeau J, Kuelzow N, Friston KJ, & Dolan RJ (2011). Dynamic
%   causal modelling of spontaneous fluctuations in skin conductance.
%   Psychophysiology, 48, 252-57.
% ● Version History
%   Introduced In PsPM 3.0
% ● Written By
%   (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
tstart = tic;

% check input arguments
%==========================================================================
if nargin < 2 || ~isnumeric(sr) || numel(sr) > 1
  errmsg = sprintf('No valid sample rate given.');
elseif (sr < 1) || (sr > 1e5)
  errmsg = sprintf('Sample rate out of range.');
elseif exist('osr') && osr ~= sr
  errmsg = sprintf('Sample rate of theta file is different from sample rate of data.');
elseif nargin < 1 || ~isnumeric(scr)
  errmsg = 'No data.';
elseif ~any(size(scr) == 1)
  errmsg = 'Input SCR is not a vector';
else
  scr = scr(:);
end;

if exist('errmsg') == 1, warning(errmsg); out = []; return; end;


% options
% ------------------------------------------------------------------------
try
  fresp = opt.fresp;
catch
  fresp = 0.5;
end;
try
  theta = opt.theta;
catch
  [theta, osr] = pspm_sf_theta;
end;
try
  threshold = opt.threshold;
catch
  threshold = 0.1;
end;
try
  options.DisplayWin = opt.dispwin;
catch
  options.DisplayWin = 1;
end;
try
  options.GnFigs = opt.dispsmallwin;
catch
  options.GnFigs = 0;
end;


% invert model
% =======================================================================

phi   = [0 0];

% DAVB settings
g_fname = 'g_Id';
f_fname = 'f_SF';
dim.n_phi   =  numel(phi);
dim.n       =  3;
priors.SigmaX0 = [1e-8 0 0; 0 1e2 0; 0 0 1e2];
priors.a_sigma = 1e5;
priors.b_sigma = 1e1;
priors.a_alpha = Inf;
priors.b_alpha = 0;
% initialise priors in correct dimensions
priors.iQy = cell(numel(scr), 1);
priors.iQx = cell(numel(scr), 1);
for k = 1:numel(scr)  % default priors on noise covariance
  priors.iQy{k} = 1;
  priors.iQx{k} = eye(dim.n);
end;
options.inG.ind = 1;
options.inF.dt = 1/sr;


% prepare data
y = scr;
y = y - min(y);

% determine initial conditions
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
for k = (4:2:(2 * nresp + 3)), priors.SigmaTheta(k, k) = 1e-2;end;
for k = (5:2:(2 * nresp + 4)), priors.SigmaTheta(k, k) = 1e2; end;
priors.muPhi = phi';
priors.SigmaPhi = zeros(dim.n_phi);
priors.SigmaX0 = 1e-8*eye(dim.n);
options.priors = priors;

% estimate parameters
c = clock;
fprintf(['\n\nEstimating model parameters for f_SF ... \t%02.0f:%02.0f:%02.0f', ...
  '\n=========================================================\n'], c(4:6));
[posterior, output] = VBA_NLStateSpaceModel(y(:)',u,f_fname,g_fname,dim,options);

% extract parameters
% =======================================================================
for i=1:length(output)
  output(i).options = rmfield(output(i).options, 'hf');
end;
t = posterior.muTheta(4:2:end);
a = exp(posterior.muTheta(5:2:end) - theta(5));   % rescale
ex = find(t < -2 | t > (numel(scr)/sr - 1)); % find SA responses the SCR peak of which is outside episode
t(ex) = []; a(ex) = [];
out.t = t - theta(4);                             % subtract conduction delay
out.a = a;
out.n = numel(find(a > threshold));
out.f = out.n/(numel(scr)/sr);
out.ma = mean(a(a > threshold));
out.theta = theta;
out.if = fresp;
out.threshold = threshold;
out.yhat = posterior.muX(1, :);
out.model.posterior = posterior;
out.model.output = output;
out.model.u = u;
out.model.y = y(:)';
out.time = toc(tstart);
% =======================================================================

