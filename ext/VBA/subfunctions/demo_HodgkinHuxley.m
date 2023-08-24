% Hodgkin-Huxley demo
% The script first simulates the response of a Hodgkin-Huxley (HH)
% neuron to spiky input current. It then inverts a HH-neuron model,
% without the input current info. Practically speaking, this means
% deconvolving the HH-neuron response to estimate its input.
% [see demo_fitzhugh.m]

clear variables
close all

% Choose basic settings for simulations
n_t             = 5e2;
decim           = 2;
deltat          = 7e-2/decim;         % 10Hz sampling rate
f_fname         = @f_HH;
g_fname         = @g_Id;

% Input to the HH system
u       = 1e2*(randn(1,n_t)>2);
% u = 5e1*randn(1,n_t);
figure,plot(u)


% Build priors for model inversion
priors.muX0 = [0;0;-2.8843;-0.7645];
priors.SigmaX0 = 1e0*eye(4);
priors.muTheta = [1;0*ones(4,1)];
priors.SigmaTheta = 1e0*eye(5);
priors.SigmaTheta(2,2) = 0;
priors.a_alpha      = 1e0;
priors.b_alpha      = 1e0;
priors.a_sigma      = 1e0;
priors.b_sigma      = 1e0;
for t = 1:n_t
    dq              = 1e4*ones(4,1);
    dq(1)           = 1e-2;
    priors.iQx{t}   = diag(dq);
end

% Build options structure for temporal integration of SDE
inF.delta_t     = deltat;
inF.a           = 0.5;
inG.ind         = 1;
options.priors = priors;
options.backwardLag = 2;
options.inF     = inF;
options.inG     = inG;

options.decim   = decim;
dim.n_theta         = 5;
dim.n_phi           = 0;
dim.n               = 4;

% Build time series of hidden states and observations
alpha   = Inf;
sigma   = 1e1;
theta   = [1;0;0*randn(3,1)];
phi     = [];
x0 = [0;0;-2.8843;-0.7645];
[y,x,x0,eta,e] = simulateNLSS(n_t,f_fname,g_fname,theta,phi,u,alpha,sigma,options,x0);

% display time series of hidden states and observations
displaySimulations(y,x,eta,e)



% Call inversion routine
[posterior,out] = VBA_NLStateSpaceModel(y,zeros(1,n_t),f_fname,g_fname,dim,options);


%------------ Display results ------------------%
displayResults(posterior,out,y,x,x0,theta,phi,alpha,sigma);



