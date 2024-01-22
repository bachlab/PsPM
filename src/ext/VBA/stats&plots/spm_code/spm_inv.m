function X = spm_inv(A,TOL)
% inverse for ill-conditioned matrices
% FORMAT X = spm_inv(A,TOL)
%
% A   - matrix
% X   - inverse
%
% TOL - tolerance: default = max(eps(norm(A,'inf'))*max(m,n),exp(-32))
%
% This routine simply adds a small diagonal matrix to A and calls inv.m
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_inv.m 378 2016-11-07 13:17:49Z tmoser $
 
% check A 
%--------------------------------------------------------------------------
[m,n] = size(A);
if isempty(A), X = sparse(n,m); return, end
 
% tolerance
%--------------------------------------------------------------------------
if nargin == 1
    TOL  = max(eps(norm(A,'inf'))*max(m,n),exp(-32)); 
end

% inverse
%--------------------------------------------------------------------------
X     = inv(A + speye(m,n)*TOL);
