function [sts, glm] = scr_glm_recon(modelfile)
% this function reconstructs the estimated responses and measures its peak.
% Reconstructed responses are written into the field glm.resp, and 
% reconstructed response peaks into the field glm.recon in original GLM file
%
% FORMAT: [sts, glm] = SCR_GLM_RECON(GLMFILE)
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_glm_recon.m 702 2015-01-22 15:06:14Z tmoser $
% $Rev: 702 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sts = -1;

% get GLM & basis functions
% -------------------------------------------------------------------------
[sts, glm] = scr_load1(modelfile, 'all', 'glm');
if sts ~= 1, return; end;
bs = glm.bf.X;
bfno = glm.bf.bfno;
bfdur = size(bs, 1);

% for ra_fc with bf.arg == 1 take regressor difference
% -------------------------------------------------------------------------
if strcmpi('ra_fc', glm.modelspec) && glm.bf.args == 1
    regdiff = 1;
else
    regdiff = 0;
end;

% find all non-nuisance regressors 
% -------------------------------------------------------------------------
n_nuis = sum(cellfun(@(c) ~isempty(c), regexpi(glm.names, '^R[0-9]*$', 'match')));
regno = (numel(glm.names) - (glm.interceptno+n_nuis))/bfno;
if regno ~= floor(regno), warning('Mismatch in basis functions and regressor number.'); return; end;

% reconstruct responses
% -------------------------------------------------------------------------
resp = NaN(bfdur, regno);
recon = cell(regno, 1);
condname = {};
for k = 1:regno
    condname{k} = glm.names{((k - 1) * bfno + 1)};
    foo = strfind(condname{k}, ', bf');
    condname{k} = [condname{k}(1:(foo-1)), ' recon']; clear foo;
    resp(:, k) = bs * glm.stats(((k - 1) * bfno + 1):(k * bfno));
    if regdiff
        recon{k, 1} = diff(glm.stats(((k - 1) * bfno + 1):(k * bfno)));
    else
        [~, bar] = max(abs(resp(:, k)));
        recon{k, 1} = resp(bar, k);
    end;
end;

% save
% -------------------------------------------------------------------------
glm.recon = recon;
glm.resp  = resp;
glm.reconnames = condname(:);
save(modelfile, 'glm');
