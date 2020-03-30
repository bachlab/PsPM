%% 
% amri_sig_corr
%    returns a p-by-p matrix containing the pairwise linear correlation 
%    coefficient between each pair of columns in the n-by-p matrix X.
%
% Usage
%   R = amri_sig_corr(A);
%   r = amri_sig_corr(a,b);
%   [R,D] = amri_sig_corr(A);
%
% Inputs
%   A: n-by-p data matrix
%   a: n-by-1 input vector
%   b: n-by-1 input vector
%
% Output
%   R: p-by-p correlation matrix
%   D: demeaned and normalized data matrix
%   r: correlation coefficient
%
% Version 
%  1.01

%% DISCLAIMER AND CONDITIONS FOR USE:
%     This software is distributed under the terms of the GNU General Public
%     License v3, dated 2007/06/29 (see http://www.gnu.org/licenses/gpl.html).
%     Use of this software is at the user's OWN RISK. Functionality is not
%     guaranteed by creator nor modifier(s), if any. This software may be freely
%     copied and distributed. The original header MUST stay part of the file and
%     modifications MUST be reported in the 'MODIFICATION HISTORY'-section,
%     including the modification date and the name of the modifier.

%% MODIFICATION HISTORY
% 1.01 - 07/06/2010 - ZMLIU - compute correlation between two input vectors
%        16/11/2011 - JAdZ  - v1.01 included in amri_eegfmri_toolbox v0.1

function [R,D] = amri_sig_corr(A,B)

if nargin<1
    eval('help amri_sig_corr');
    return
end

if nargin==2
    A=A(:);
    B=B(:);
    if length(A)~=length(B)
        error('amri_sig_corr(): input vectors must be of the same length');
    end
    cc=corrcoef(A,B);
    R=cc(1,2);
    return
end

p=size(A,2);
for i=1:p
    A(:,i)=A(:,i)-mean(A(:,i));
    nn = norm(A(:,i));
    if nn>0
        A(:,i)=A(:,i)/nn;
    end
end
R=A'*A;
if nargout>=2
   D = A;
end
