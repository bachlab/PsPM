function [theta, sr] = pspm_sf_theta
% ● Description
%   pspm_sf_theta returns parameter values for skin conductance response function 
%   f_SF
%   Estimated on 29-Jul-2009
%   theta1, theta2, theta3: ODE parameters
%   theta4: delay parameter, should be the same as for aSCR model as there is
%   no explicit knowledge of SN bursts so it cannot be empirically determined
%   this was corrected on 12.05.2014
%   theta 5: scaling parameter in log space, was slightly adapted on
%   12.05.2014 such that an input with unit amplitude elicits a response with
%   exactly unit amplitude, see pspm_f_amplitude_check.m
% ● Introduced In
%   PsPM 3.0
% ● Written By
%   (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

theta = [0.923581    3.921034    2.159389    1.5339    1.6411756741];
sr = 10;