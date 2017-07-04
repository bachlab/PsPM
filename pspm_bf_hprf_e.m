function [bf, x, b] = pspm_bf_hprf_e(varargin)
% pspm_bf_hprf constructs the heart period response function consisting of 
% modified Gaussian functions
%
% FORMAT: [bf, x, b] = pspm_bf_hprf_e(td, b) or pspm_bf_hprf_e([td, b])
%
% with  td = time resolution in s and 
%       b  = number of basis functions (default 1:6)
%
% basis functions will be orthogonalized using spm_orth by default. Onsets
% pspm_glm must be shifted by 5 s to account for the pre-event epoch.
%
% put in values 1:6 for b in order to get following basis functions:
%
% 1:    BF 1    -   mu 1 s, sigma 1.9 s (contains pre event epoch of -5s)
% 2:    BF 2    -   mu 5.2 s, sigma 1.9 s
% 3:    BF 3    -   mu 7.2 s, sigma 1.5 s
% 4:    BF 4    -   mu 7.2 s, sigma 4 s
% 5:    BF 5    -   mu 12.6 s, sigma 2 s
% 6:    BF 6    -   mu 23.9 s, sigma 4.1 s
%
% -------------------------------------------------------------------------
%
% REFERENCE
% 
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Philipp C Paulus & Dominik R Bach
% (Technische Universitaet Dresden, University of Zurich)

% $Id$
% $Rev$

% input checks 
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;

if nargin < 1
   errmsg='No sampling interval stated'; warning('ID:invalid_input', errmsg); return;
end;

varargin=cell2mat(varargin);

if length(varargin)==1
    b=1:6;
elseif varargin(end)<=6 && varargin(end)~=0
    b=varargin(2:end);
    b=sort(b,'ascend');
else
    errmsg='your input for ''b'' is not supported. Choose value(s) between 1 and 6.'; 
    warning(errmsg); b=[]; bf=[]; return
end

% -------------------------------------------------------------------------
% initialise
td = varargin(1);

if td > 50    
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
end;

x = (0:td:50-td);
bf=[];


% -------------------------------------------------------------------------
% normpdf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%              ATTENTION µ +ts !!                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ts=5;

n(1,:)=[1 5.2 7.2 7.2 12.6 23.9]+ts;
n(2,:)=[1.9 1.9 1.5 4 2 4.1];
% -------------------------------------------------------------------------
% get normpdf functions
for in_b=1:length(b)
    mu = n(1,b(in_b));
    sigma = n(2,b(in_b));
    
    % use own function (no stats toolbox needed)
    bf(:, in_b) = 1./(sigma*sqrt(2*pi)).*exp((-(x-mu).^2)./(2*(sigma^2)));
end
% shift by 5s
% -------------------------------------------------------------------------
x = x-ts;
% -------------------------------------------------------------------------
% orthogonalize
bf=spm_orth(bf);

% normalise
bf = bf./repmat((max(bf) - min(bf)), size(bf, 1), 1);

% done.