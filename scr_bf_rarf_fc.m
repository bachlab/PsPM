function [bs, x] = scr_bf_rarf_fc(varargin)
% SCR_BF_RARF_FC
% Description: 
%
% FORMAT: [bs, x] = SCR_BF_RARF_FC(td, bf_type) 
%     OR: [bs, x] = SCR_BF_RARF_FC([td, bf_type]) 
%
% ARGUMENTS:
%           td:         The time the response function should have.   
%           bf_type:    Which type of response function should be generated
%                           1: first type response function is generated
%                           (default) = gamma_early + gamma_late
%                           2: second type response function is generated
%                           = gamma_early + gamma_early'
%
% REFERENCE
% 
%________________________________________________________________________
% PsPM 3.1
% (C) 2016 G Castegnetti, Tobias Moser (University of Zurich)

% initialise
global settings
if isempty(settings), scr_init; end;

% check input arguments
if nargin==0
    errmsg='No sampling interval stated'; warning('ID:invalid_input', errmsg); return;
end;

td = varargin{1}(1);
if numel(varargin{1}) == 1 && nargin == 1
    bf_type = 1;
elseif numel(varargin{1}) == 2
    bf_type = varargin{1}(2);
else
    bf_type = varargin{2}(1);
end;

if td > 30
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
end;

% define paramters
% -------------------------------------------------------------------------
% order: k, G, n0
% can use any amplitude, since glm resizes them
amp = 1;

p_early = [2.57e7, 3.124e-4, -8.02e3 -amp];
p_late = [3.41 1.11 7.58 amp];


% fix value of bf_type
% -------------------------------------------------------------------------
if (bf_type<1)||(bf_type>2)
    bf_type = 1; 
end;

x = (0:td:30-td)';

x0_e = p_early(3);
b_e = p_early(2);
a_e = p_early(1);
A_e = p_early(4);

x0_l = p_late(3);
b_l = p_late(2);
a_l = p_late(1);
A_l = p_late(4);

g_early = A_e * gampdf(x-x0_e, a_e, b_e);
g_late = A_l * gampdf(x-x0_l, a_l, b_l);

if bf_type == 1
    bs = [g_early g_late];
else
    bs = [g_early(1:end-1) diff(g_early)];
end;

% orthogonalise
bs = spm_orth(bs);