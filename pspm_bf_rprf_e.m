function [bs, x] = pspm_bf_rprf_e(varargin)
% ● Description
% ● Format
%   [bs, x] = pspm_bf_rprf_e(td, bf_type)
%   [bs, x] = pspm_bf_rprf_e([td, bf_type])
% ● Arguments
%        td:  The time the response function should have.
%   bf_type:  0: (default) returns the response function only
%             1: returns the response function and the time derivative
% ● Reference
%   Dominik R. Bach, Samuel Gerster, Athina Tzovara, Giuseppe Castegnetti,
%   A linear model for event-related respiration responses,
%   Journal of Neuroscience Methods, Volume 270, 1 September 2016, Pages 147-155,
%   ISSN 0165-0270, doi:10.1016/j.jneumeth.2016.06.001.
% ● History
%   Introduced in PsPM 3.1
%   Written in 2016 by Tobias Moser (University of Zurich)
%   Maintained in 2022 by Teddy Chao (UCL)

%% initialise
global settings
if isempty(settings), pspm_init; end;
%% check input arguments
if nargin==0
  errmsg='No sampling interval stated'; warning('ID:invalid_input', errmsg); return;
end;
%% load arguments/parameters
td = varargin{1}(1);
if numel(varargin{1}) == 1 && nargin == 1
  bf_type = 0;
elseif numel(varargin{1}) == 2
  bf_type = varargin{1}(2);
else
  bf_type = varargin{2}(1);
end;
%% fix value of bf_type
if (bf_type<0)||(bf_type>1)
  bf_type = 0;
end;
%% other variables
mu = 4.2;
sigma = 1.65;
% duration
stop = 30;
start = -10;
if td > stop
  warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
  warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
end
x = (start:td:stop-td)';
bs = exp(-(x-mu).^2./(2*sigma^2));
if bf_type == 1
  bs = [bs [diff(bs); 0]];
end
% orthogonalise
bs = spm_orth(bs);
% normalise
bs = bs./repmat((max(bs) - min(bs)), size(bs, 1), 1);
return
