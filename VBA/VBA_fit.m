function fit = VBA_fit(posterior,out)
% derives standard model fit accuracy metrics
% function fit = VBA_fit(posterior,out)
% IN:
%   - posterior/out: output structures of VBA_NLStateSpaceModel.m
% OUT:
%   - fit: structure, containing the following fields:
%       .LL: log-likelihood of the model
%       .AIC: Akaike Information Criterion
%       .BIC: Bayesian Informaion Criterion
%       .R2: if data is continuous, R2 = coefficient of determination
%       (fraction of explained variance). If data is binary, R2 = balanced
%       classification accuracy (fraction of correctly predicted outcomes).

suffStat = out.suffStat;

% Log-likelihood
if ~out.options.binomial
    v = posterior.b_sigma./posterior.a_sigma;
    fit.LL = -0.5*out.suffStat.dy2/v;
    fit.ny = 0;
    for t=1:out.dim.n_t
        ldq = VBA_logDet(out.options.priors.iQy{t}/v);
        fit.ny = fit.ny + length(find(diag(out.options.priors.iQy{t})~=0));
        fit.LL = fit.LL + 0.5*ldq;
    end
    fit.LL = fit.LL - 0.5*fit.ny*log(2*pi);
else
    fit.LL = out.suffStat.logL;
    fit.ny = sum(1-out.options.isYout(:));
end

% AIC/BIC
fit.np = 0;
if out.dim.n_phi > 0
    indIn = out.options.params2update.phi;
    fit.np = fit.np + length(indIn);
end
if out.dim.n_theta > 0
    indIn = out.options.params2update.theta;
    fit.np = fit.np + length(indIn);
end
if out.dim.n > 0  && ~isinf(out.options.priors.a_alpha) && ~isequal(out.options.priors.b_alpha,0)
    for t=1:out.dim.n_t
        indIn = out.options.params2update.x{t};
        fit.np = fit.np + length(indIn);
    end
end
fit.AIC = fit.LL - fit.np;
fit.BIC = fit.LL - 0.5*fit.np*log(fit.ny);


if ~out.options.binomial
    % coefficient of determination
    SS_tot = sum((out.y(:)-mean(out.y(:))).^2);
    SS_err = sum((out.y(:)-suffStat.gx(:)).^2);
    fit.R2 = 1-(SS_err/SS_tot);
else
    % balanced accuracy
    bg = out.suffStat.gx>.5; % binarized model predictions
    tp = sum(vec(out.y).*vec(bg)); % true positives
    fp = sum(vec(1-out.y).*vec(bg)); % false positives
    fn = sum(vec(out.y).*vec(1-bg)); % false positives
    tn = sum(vec(1-out.y).*vec(1-bg)); %true negatives
    P = tp + fn;
    N = tn + fp;
    fit.R2 = 0.5*(tp./P + tn./N);
    fit.acc = (tp+tn)./(P+N);
end
