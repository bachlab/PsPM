function theta = pspm_get_rf(fn, events, outfile, channel, options)
% ● Description
%   pspm_get_rf estimates a response function from an event-related design
%   (e.g. for further use in a GLM analysis), using a regularisation as
%   third-order ODE and DCM machinery.
% ● Developer
%   the function returns an m-function for the RF, and the parameters of that
%   function
% ● Format
%   theta = pspm_get_rf(fn, events, outfile, channel, options)
% ● Arguments
%   *      fn : the file name of a PsPM data file
%   *  events : specified in seconds as either (1) a vector of onsets, or (2) an
%               SPM style onsets file with one event type, or (3) an epochs file
%               (see pspm_dcm or pspm_get_epochs).
%   * outfile : (optional) a file to write the response function to
%   * channel : (optional) data channel (default: look for first SCR channel) 
%   * options : [struct] to be passed on to pspm_dcm
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Updated in 2026 by Bernhard A. von Raußendorf

%% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
rf = []; %  in the m-function can be removed
theta = [];

%% check input
if nargin < 1
  warning('No data to work on.'); return;
elseif nargin < 2
  warning('No events specified'); return;
elseif nargin < 3
  outfile = '';
end
if isempty(outfile) || ~ischar(outfile)
  [pth infn ext] = fileparts(fn);
  outfile = fullfile(pth, ['RF_', infn, ext]);
end
if nargin < 4 || isempty(channel)
  channel = 'scr';
end
if nargin < 5 || isempty(options)
  options = struct();
end


%% call DCM
options = pspm_options(options, 'get_rf');
% options.getrf = 1;
%try options.nosave, catch, options.nosave = 1; end
if options.invalid
  warning('ID:invalid_input', 'Invalid options provided.')
  return;
end

% prepare timing for pspm_dcm -> maybe change!
if isnumeric(events)
  if isvector(events)
    events = {events(:)};
  else
    events = {events};
  end
end

model.datafile  = {fn};
model.timing    = {events};
model.channel   = channel;
model.modelfile = [tempname, '.mat'];

[dsts, dcm] = pspm_dcm(model, options);
if dsts < 1 || isempty(dcm)
  warning('ID:rf_estimation_failed', 'Response function estimation failed during DCM inversion.');  
  return;
end

% options.channel = channel;
% [foo dcm] = pspm_dcm(fn, '', events, options);


if iscell(dcm)
  dcm_rf = dcm{1};
else
  dcm_rf = dcm;
end

if numel(dcm_rf.prior.posterior) == 2
  % based on eSCR
  theta = dcm_rf.prior.posterior(2).muTheta(1:7)';
else
  % based on aSCR (i. e. updated RF)
  theta = dcm_rf.prior.posterior(3).muTheta(1:7)';
end

% if numel(dcm{1}.prior.posterior) == 2
%   % based on eSCR
%   theta = dcm{1}.prior.posterior(2).muTheta(1:7)';
% else
%   % based on aSCR (i. e. updated RF)
%   theta = dcm{1}.prior.posterior(3).muTheta(1:7)';
% end

%% write response function to file
if ~isempty(outfile) % should never be empty!
  [pth fn ext] = fileparts(outfile);
  c = clock; % timestamp
  job{1}  = sprintf('function [rf, theta] = %s(td)', fn);
  job{2}  = '%-----------------------------------------------------------------------';
  job{3}  = ['% Response function created by pspm_get_rf, ', date, sprintf('  %02.0f:%02.0f', c(4:5))];
  job{4}  = '%-----------------------------------------------------------------------';
  job{5}  = sprintf('theta = [%f %f %f %f %f %f %f];', theta);
  job{6}  = sprintf('ut(1, :) = td:td:90;');
  job{7}  = sprintf('ut(2, :) = 0;');
  job{8}  = sprintf('ut(3, :) = 1;');
  job{9}  = sprintf('ut(4, :) = 0;');
  job{10} = sprintf('ut(5, :) = 0;');
  job{11} = sprintf('ut(6, :) = 0;');
  job{12} = sprintf('Theta = [theta(1:4) 0 0 0 log(1)];');
  job{13} = sprintf('Xt = zeros(7, 1);');
  job{14} = sprintf('in.dt = td;');
  job{15} = sprintf('for k = 1:size(ut, 2)');
  job{16} = sprintf('   Xt(:, k + 1) = f_SCR(Xt(:, k), Theta, ut(:, k), in);');
  job{17} = sprintf('end');
  job{18} = sprintf('rf = Xt(1, :);');
  job{19} = sprintf('rf = rf/max(rf);');
  job{20} = sprintf('rf = rf(:);');
  % job = strvcat(job'); 
  % outfile = fullfile(pth, [fn, '.m']);
  % dlmwrite(outfile, job, 'delimiter', '');
  outfile = fullfile(pth, [fn, '.m']);

  [fid, errmsg] = fopen(outfile, 'w');
  if fid < 0
      warning('ID:cannot_write', 'Could not open output file for writing: %s. %s', outfile, errmsg);
      return;
  end
  fprintf(fid, '%s\n', job{:});
  fclose(fid);
end

sts = 1;
return

end
