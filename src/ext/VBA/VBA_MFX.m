function [p_sub,o_sub,p_group,o_group] = VBA_MFX(y,u,f_fname,g_fname,dim,options,priors_group)
% VB treatment of mixed-effects analysis
% function [posterior,out] = VBA_MFX(y,u,f_fname,g_fname,dim,options)
% This function approach model inversion from an empirical Bayes
% perspective, whereby within-subject priors are iteratively refined and
% matched to the inferred parent population distribution.
%  Note: all subjects must use the same model
% IN:
%   - y: nsx1 cell array of observations, where ns is the number of
%   subjects in the group
%   - u:  nsx1 cell array of inputs
%   - f_fname/g_fname: evolution/observation function handles
%   - dim: structure containing the model dimensions.
%   - options: nsx1 cell array of options structure. Note: if specified
%   here, the priors on observation and evolution parameters (as well as
%   initial conditions) are useless, since they are replaced by empirical
%   Bayes priors. Priors on precision hyperparameters however, are not
%   treated as random effects drawn from a parent population distribution,
%   whose moment are inferred during MFX analysis.
%   - priors_group: structure containing the prior sufficient statistics on
%   the moments of the parent population distributions (for osbervation and
%   evolution parameters, as well as for initial conditions, if
%   applicable). See p_group subfields below.
% OUT:
%   - p_sub/o_sub: nsx1 cell arrays containng the VBA outputs of the
%   within-subject model inversions.
%   - p_group: structure containing the sufficient statistics of the
%   posterior over the moments of parent population distribution. Its
%   subfields are:
%       .muPhi/SigmaPhi: VB sufficient statistics (first 2 moments) of the
%       Gaussian posterior pdf over the population mean of observation
%       parameters.
%       .muTheta/SigmaTheta: [id] for evolution parameters.
%       .muX0/SigmaX0: [id] for initial conditions.
%       .a_vPhi/b_vPhi: VB sufficient statistics (scale and hape
%       parameters) of the Gamma posterior pdf over the population
%       precision of observation parameters.
%       .a_vTheta/b_vTheta: [id] for evolution parameters.
%       .a_vTheta/b_vTheta: [id] for initial conditions.
%   - o_group: output structure of the VBA_MFX approach. In particular, it
%   contains the following subfields:
%       .F: a vector of free energies (across VB iterations). Its last
%       entry (F(end)) provides the free energy lower bound to the MFX
%       model.
%       .it: the final number of VB iterations
%       .date: date vector for track keeping


ns = length(y); % # subjects
dim.ns = ns;
opt.dim = dim;
opt.g_fname = g_fname;
opt.f_fname = f_fname;
opt.verbose = 1;
o_group.tStart = tic;
o_group.options = opt;
[o_group.options] = VBA_displayMFX([],[],[],o_group,1,'off');

% 0- Check priors
% Default priors are used if priors are not explicitly provided through the
% priors_group structure. This means Gaussian(0,1) priors for the
% population mean of observation/evolution parameters and initial
% conditions, and Gamma(1,1) for the corresponding population precisions.
if dim.n_phi > 0
    try
        priors_group.muPhi;
    catch
        priors_group.muPhi = zeros(dim.n_phi,1);
    end
    try
        priors_group.SigmaPhi;
    catch
        priors_group.SigmaPhi = eye(dim.n_phi);
    end
    try
        priors_group.a_vPhi;
    catch
        priors_group.a_vPhi = 1;
    end
    try
        priors_group.b_vPhi;
    catch
        priors_group.b_vPhi = 1;
    end
    try
        priors_group.QPhi;
    catch
        priors_group.QPhi = eye(dim.n_phi);
    end
end
if dim.n_theta > 0
    try
        priors_group.muTheta;
    catch
        priors_group.muTheta = zeros(dim.n_theta,1);
    end
    try
        priors_group.SigmaTheta;
    catch
        priors_group.SigmaTheta = eye(dim.n_theta);
    end
    try
        priors_group.a_vTheta;
    catch
        priors_group.a_vTheta = 1;
    end
    try
        priors_group.b_vTheta;
    catch
        priors_group.b_vTheta = 1;
    end
    try
        priors_group.QTheta;
    catch
        priors_group.QTheta = eye(dim.n_theta);
    end
end
if dim.n >0
    try
        priors_group.muX0;
    catch
        priors_group.muX0 = zeros(dim.n,1);
    end
    try
        priors_group.SigmaX0;
    catch
        priors_group.SigmaX0 = eye(dim.n);
    end
    try
        priors_group.a_vX0;
    catch
        priors_group.a_vX0 = 1;
    end
    try
        priors_group.b_vX0;
    catch
        priors_group.b_vX0 = 1;
    end
    try
        priors_group.QX0;
    catch
        priors_group.QX0 = eye(dim.n);
    end
end

if isempty(u)
    for i=1:ns
        u{i} = [];
    end
end

% 1- Initialization
% Here, we simply initialize the posterior on the population's mean and
% precision over observation/evolution parameters and initial conditions
% using their prior.
fprintf(1,['VBA treatment of MFX analysis: initialization...'])
for i=1:ns
    if dim.n_phi > 0
        p_group.muPhi = priors_group.muPhi;
        p_group.SigmaPhi = priors_group.SigmaPhi;
        iV_phi = VBA_inv(priors_group.SigmaPhi);
        p_group.a_vPhi = priors_group.a_vPhi;
        p_group.b_vPhi = priors_group.b_vPhi;
        iQ_phi = VBA_inv(priors_group.QPhi);
        ind.phi_ffx = find(diag(priors_group.QPhi)==0);
        ind.phi_in = find(diag(priors_group.SigmaPhi)~=0);
    end
    if dim.n_theta > 0
        p_group.muTheta = priors_group.muTheta;
        p_group.SigmaTheta = priors_group.SigmaTheta;
        iV_theta = VBA_inv(priors_group.SigmaTheta);
        p_group.a_vTheta = priors_group.a_vTheta;
        p_group.b_vTheta = priors_group.b_vTheta;
        iQ_theta = VBA_inv(priors_group.QTheta);
        ind.theta_ffx = find(diag(priors_group.QTheta)==0);
        ind.theta_in = find(diag(priors_group.SigmaTheta)~=0);
    end
    if dim.n >0
        p_group.muX0 = priors_group.muX0;
        p_group.SigmaX0 = priors_group.SigmaX0;
        iV_x0 = VBA_inv(priors_group.SigmaX0);
        p_group.a_vX0 = priors_group.a_vX0;
        p_group.b_vX0 = priors_group.b_vX0;
        iQ_x0 = VBA_inv(priors_group.QX0);
        ind.x0_ffx = find(diag(priors_group.QX0)==0);
        ind.x0_in = find(diag(priors_group.SigmaX0)~=0);
    end
end


% 2- evaluate within-subject free energies under the prior
p_sub = cell(ns,1);
o_sub = cell(ns,1);
if opt.verbose
    fprintf(1,'%6.2f %%',0)
end
for i=1:ns
    if opt.verbose
        fprintf(1,repmat('\b',1,8))
        fprintf(1,'%6.2f %%',floor(100*i/ns))
    end
    % define within-subject priors
    if dim.n_phi > 0
        options{i}.priors.muPhi = p_group.muPhi;
        options{i}.priors.SigmaPhi = (p_group.b_vPhi./p_group.a_vPhi).*priors_group.QPhi;
        if ~isempty(ind.phi_ffx)
            options{i}.priors.muPhi(ind.phi_ffx) = priors_group.muPhi(ind.phi_ffx);
            options{i}.priors.SigmaPhi(ind.phi_ffx,ind.phi_ffx) = ns*priors_group.SigmaPhi(ind.phi_ffx,ind.phi_ffx);
        end
    end
    if dim.n_theta > 0
        options{i}.priors.muTheta = p_group.muTheta;
        options{i}.priors.SigmaTheta = (p_group.b_vTheta./p_group.a_vTheta).*priors_group.QTheta;
        if ~isempty(ind.theta_ffx)
            options{i}.priors.muTheta(ind.theta_ffx) = priors_group.muTheta(ind.theta_ffx);
            options{i}.priors.SigmaTheta(ind.theta_ffx,ind.theta_ffx) = ns*priors_group.SigmaTheta(ind.theta_ffx,ind.theta_ffx);
        end
    end
    if dim.n >0
        options{i}.priors.muX0 = p_group.muX0;
        options{i}.priors.SigmaX0 = (p_group.b_vX0./p_group.a_vX0).*priors_group.QX0;
        if ~isempty(ind.x0_ffx)
            options{i}.priors.muX0(ind.x0_ffx) = priors_group.muX0(ind.x0_ffx);
            options{i}.priors.SigmaX0(ind.x0_ffx,ind.x0_ffx) = ns*priors_group.SigmaX0(ind.x0_ffx,ind.x0_ffx);
        end
    end
    % VBA model inversion
    options{i}.MaxIter = 0;
    [p_sub{i},o_sub{i}] = VBA_NLStateSpaceModel(y{i},u{i},f_fname,g_fname,dim,options{i});
    % store options for future inversions
    options{i} = o_sub{i}.options;
    options{i}.MaxIter = 32;
end
F(1) = MFX_F(p_sub,o_sub,p_group,priors_group,dim,ind);
o_group.F = F;
o_group.it = 0;
o_group.ind = ind;
if opt.verbose
    fprintf(1,repmat('\b',1,8))
    fprintf(' OK.')
    fprintf('\n')
end
[o_group.options] = VBA_displayMFX(p_sub,o_sub,p_group,o_group,0,'off');



% 3- VB: iterate until convergence...
% We now update the within-subject effects as well as respective population
% moments according to the mean-field VB scheme. This effectively
% iteratively replaces the priors over within-subject effects by the VB
% estimate of the group mean and precision. The free energy of the ensuing
% MFX procedure is computed for tracking algorithmic convergence.
stop = 0;
it = 1;
fprintf(1,['Main VB inversion...'])
while ~stop
    
    % perform within-subject model inversions
    for i=1:ns
        
        
        try
            set(o_group.options.display.ho,'string',['VB iteration #',num2str(it),': within-subject model inversions (',num2str(floor(100*(i-1)/ns)),'%)'])
        end
        
        % re-define within-subject priors
        if dim.n_phi > 0
            options{i}.priors.muPhi = p_group.muPhi;
            options{i}.priors.SigmaPhi = (p_group.b_vPhi./p_group.a_vPhi).*priors_group.QPhi;
            if ~isempty(ind.phi_ffx)
                options{i}.priors.muPhi(ind.phi_ffx) = priors_group.muPhi(ind.phi_ffx);
                options{i}.priors.SigmaPhi(ind.phi_ffx,ind.phi_ffx) = ns*priors_group.SigmaPhi(ind.phi_ffx,ind.phi_ffx);
            end
        end
        if dim.n_theta > 0
            options{i}.priors.muTheta = p_group.muTheta;
            options{i}.priors.SigmaTheta = (p_group.b_vTheta./p_group.a_vTheta).*priors_group.QTheta;
            if ~isempty(ind.theta_ffx)
                options{i}.priors.muTheta(ind.theta_ffx) = priors_group.muTheta(ind.theta_ffx);
                options{i}.priors.SigmaTheta(ind.theta_ffx,ind.theta_ffx) = ns*priors_group.SigmaTheta(ind.theta_ffx,ind.theta_ffx);
            end
        end
        if dim.n >0
            options{i}.priors.muX0 = p_group.muX0;
            options{i}.priors.SigmaX0 = (p_group.b_vX0./p_group.a_vX0).*priors_group.QX0;
            if ~isempty(ind.x0_ffx)
                options{i}.priors.muX0(ind.x0_ffx) = priors_group.muX0(ind.x0_ffx);
                options{i}.priors.SigmaX0(ind.x0_ffx,ind.x0_ffx) = ns*priors_group.SigmaX0(ind.x0_ffx,ind.x0_ffx);
            end
        end
        
%         % bypass VBA initialization (to be fixed!)
%         in.posterior = p_sub{i};
%         in.out.options = options{i};
%         in.out.dim = o_sub{i}.dim;
%         in.out.suffStat = o_sub{i}.suffStat;
%         in.out.u = o_sub{i}.u;
        
        
        % VBA model inversion
        [p_sub{i},o_sub{i}] = VBA_NLStateSpaceModel(y{i},u{i},f_fname,g_fname,dim,options{i});%,in);
        
        % store sufficient statistics
        if dim.n_phi > 0
            mphi(:,i) = p_sub{i}.muPhi;
            Vphi{i} = p_sub{i}.SigmaPhi;
        end
        if dim.n_theta > 0
            mtheta(:,i) = p_sub{i}.muTheta;
            Vtheta{i} = p_sub{i}.SigmaTheta;
        end
        if dim.n >0
            mx0(:,i) = p_sub{i}.muX0;
            Vx0{i} = p_sub{i}.SigmaX0;
        end
        
    end
    
    try
        set(o_group.options.display.ho,'string',['Updating moments of parent distribution...'])
    end
    
    % update modements of the parent population distribution
    if dim.n_phi > 0
        [p_group.muPhi,p_group.SigmaPhi,p_group.a_vPhi,p_group.b_vPhi] = ...
            MFX_VBupdate(...
            priors_group.muPhi,...
            iV_phi,...
            iQ_phi,...
            mphi,...
            Vphi,...
            p_group.a_vPhi,...
            p_group.b_vPhi,...
            priors_group.a_vPhi,...
            priors_group.b_vPhi,...
            ind.phi_ffx,...
            ind.phi_in);
    end
    if dim.n_theta > 0
        [p_group.muTheta,p_group.SigmaTheta,p_group.a_vTheta,p_group.b_vTheta] = ...
            MFX_VBupdate(...
            priors_group.muTheta,...
            iV_theta,...
            iQ_theta,...
            mtheta,...
            Vtheta,...
            p_group.a_vTheta,...
            p_group.b_vTheta,...
            priors_group.a_vTheta,...
            priors_group.b_vTheta,...
            ind.theta_ffx,...
            ind.theta_in);
    end
    if dim.n >0
        [p_group.muX0,p_group.SigmaX0,p_group.a_vX0,p_group.b_vX0] = ...
            MFX_VBupdate(...
            priors_group.muX0,...
            iV_x0,...
            iQ_x0,...
            mx0,...
            Vx0,...
            p_group.a_vX0,...
            p_group.b_vX0,...
            priors_group.a_vX0,...
            priors_group.b_vX0,...
            ind.x0_ffx,...
            ind.x0_in);
    end
    
    F(it+1) = MFX_F(p_sub,o_sub,p_group,priors_group,dim,ind);
    
    o_group.F = F;
    o_group.it = it;
        
    if it == 1
        % store initial within-subject VBA model inversion
        o_group.initVBA.p_sub = p_sub;
        o_group.initVBA.o_sub = o_sub;
        [o_group.options] = VBA_displayMFX(p_sub,o_sub,p_group,o_group,0,'off');
    else
        [o_group.options] = VBA_displayMFX(p_sub,o_sub,p_group,o_group);
    end

    dF = F(it+1) - F(it);
    if abs(dF) <= 1e-2;
        stop = 1;
    end
    it = it +1;
    
end
fprintf([' done.','\n'])
o_group.date = clock;
o_group.dt = toc(o_group.tStart);
o_group.options.binomial = o_sub{1}.options.binomial;
for i=1:ns
    o_group.within_fit.F(i) = o_sub{i}.F(end);
    o_group.within_fit.R2(i) = o_sub{i}.fit.R2;
    o_group.within_fit.LLH0(i) = VBA_LMEH0(o_sub{i}.y,o_sub{i}.options);
end
try
    if floor(o_group.dt./60) == 0
        timeString = [num2str(floor(o_group.dt)),' sec'];
    else
        timeString = [num2str(floor(o_group.dt./60)),' min'];
    end
    set(o_group.options.display.ho,'string',['VB treatment of MFX analysis complete (took ~',timeString,').'])
end
try
    str = VBA_summaryMFX(o_group);
    VBA_disp(str,opt)
end
o_group.options.display = [];

% subfunctions

function [m,V,a,b] = MFX_VBupdate(m0,iV0,iQ,ms,Vs,a,b,a0,b0,indffx,indIn)
ns = length(ms);
n = length(m0);
sm = 0;
sv = 0;
wsm = 0;
sP = 0;
indrfx = setdiff(1:n,indffx);
indrfx = intersect(indrfx,indIn);
indffx = intersect(indffx,indIn);
iQ = iQ(indrfx,indrfx);
for i=1:ns
    % RFX
    sm = sm + ms(indrfx,i);
    e = ms(indrfx,i)-m0(indrfx);
    sv = sv + trace(iQ*Vs{i}(indrfx,indrfx)) + e'*iQ*e;
    % FFX
    tmp = VBA_inv(Vs{i});
    wsm = wsm + tmp*ms(:,i);
    sP = sP + tmp;
end
% RFX
Ealpha = a./b;
V = zeros(n,n);
m = m0;
V(indrfx,indrfx) = VBA_inv(iV0(indrfx,indrfx)+ns*Ealpha*iQ);
m(indrfx) = V(indrfx,indrfx)*(iV0(indrfx,indrfx)*m0(indrfx)+Ealpha*iQ*sm);
a = a0 + 0.5*ns*(n-length(indffx));
b = b0 + 0.5*(sv+ns*trace(iQ*V(indrfx,indrfx)));
% FFX
if ~isempty(indffx)
    tmp = VBA_inv(sP);
    V(indffx,indffx) = tmp(indffx,indffx);
    m(indffx) = V(indffx,indffx)*wsm(indffx);
end



function [F] = MFX_F(p_sub,o_sub,p_group,priors_group,dim,ind)
% free energy computation
F = 0;
ns = length(p_sub);
for i=1:ns
    F = F + o_sub{i}.F;
end
if dim.n_phi > 0
    F = F + FreeEnergy_var(ns,...
        p_group.muPhi,p_group.SigmaPhi,...
        priors_group.muPhi,priors_group.SigmaPhi,...
        p_group.a_vPhi,p_group.b_vPhi,...
        priors_group.a_vPhi,priors_group.b_vPhi,...
        ind.phi_ffx,ind.phi_in);
end
if dim.n_theta > 0
    F = F + FreeEnergy_var(ns,...
        p_group.muTheta,p_group.SigmaTheta,...
        priors_group.muTheta,priors_group.SigmaTheta,...
        p_group.a_vTheta,p_group.b_vTheta,...
        priors_group.a_vTheta,priors_group.b_vTheta,...
        ind.theta_ffx,ind.theta_in);
end
if dim.n > 0
    F = F + FreeEnergy_var(ns,...
        p_group.muX0,p_group.SigmaX0,...
        priors_group.muX0,priors_group.SigmaX0,...
        p_group.a_vX0,p_group.b_vX0,...
        priors_group.a_vX0,priors_group.b_vX0,...
        ind.x0_ffx,ind.x0_in);
end


function F = FreeEnergy_var(ns,mu,V,mu0,V0,a,b,a0,b0,indffx,indIn)
% group-level variable-specific free energy correction term
Ealpha = a./b;
n = length(mu);
indrfx = setdiff(1:n,indffx);
indrfx = intersect(indrfx,indIn);
n = length(indrfx);
e = mu(indrfx) - mu0(indrfx);
iv0 = VBA_inv(V0(indrfx,indrfx));
F = (a0-1).*(psi(a)-log(b)) - (0.5*ns*trace(V(indrfx,indrfx))+b0)*Ealpha + a0*log(b0) + gammaln(b0) ...
    - 0.5*n*log(2*pi) - 0.5*VBA_logDet(V0(indrfx,indrfx)) - 0.5*e'*iv0*e - 0.5*trace(iv0*V(indrfx,indrfx)) ...
    + entropyGamma(a,b) + entropyGaussian(V(indrfx,indrfx)) ...
    + 0.5*(ns-1).*length(indffx).*log(2*pi);


function S = entropyGamma(a,b)
S = a - log(b) + gammaln(a) + (1-a)*psi(a);

function S = entropyGaussian(V)
n = size(V,1);
S = 0.5*n*(1+log(2*pi)) + 0.5*VBA_logDet(V);
