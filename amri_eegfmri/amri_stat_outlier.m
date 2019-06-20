function [Y,I]=amri_stat_outlier(X)

%%    
% amri_stat_outlier: 
%
% Version
%   1.00

%% DISCLAIMER AND CONDITIONS FOR USE:
%     This software is distributed under the terms of the GNU General Public
%     License v3, dated 2007/06/29 (see http://www.gnu.org/licenses/gpl.html).
%     Use of this software is at the user's OWN RISK. Functionality is not
%     guaranteed by creator nor modifier(s), if any. This software may be freely
%     copied and distributed. The original header MUST stay part of the file and
%     modifications MUST be reported in the 'MODIFICATION HISTORY'-section,
%     including the modification date and the name of the modifier.

%% MODIFICATION HISTORY
%        16/11/2011 - JAdZ  - v1.00 included in amri_eegfmri_toolbox v0.1

X=X(:);
[Z,J]=sort(X);
L=length(X);
q1=Z(round(L/4));
q3=Z(round(L*3/4));
iq=q3-q1;

I=find(X<q1-3*iq | X>q3+3*iq);
Y=X(I);
