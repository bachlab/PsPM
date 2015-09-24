function [bs, x] = scr_bf_ldrf_gu(td, options)
% SCR_bf_ldrf_gu  
% Description: 
%
% FORMAT: [bs, x] = scr_bf_ldrf_gu(td, options) 
%     OR: [bs, x] = scr_bf_ldrf_gu(td)
%
%   Inputs:
%       td:         time resolution in s
%       options:    optional function paramters
%           duration:   duration of the function in s [20s]
%           offset:     offset in s. tells the function where to start with 
%                       the response function [0.2s]
%           params:     parameters for the gamma function. [default params 
%                       according to Korn et al.]
%
% with td = time resolution in s
%
% REFERENCE
%
%________________________________________________________________________
% PsPM 3.1
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$   
% $Rev$
% initialise
global settings
if isempty(settings), scr_init; end;

% check input arguments
if nargin==0
    errmsg='No sampling interval stated'; warning(errmsg); return;
elseif nargin < 2
    options = struct();
end;

if ~isfield(options, 'params')
    options.params = [0.270885699519043, 2.29354406615360, 1.49589382334256, 0.00402041347274798];
end;

if ~isfield(options, 'duration')
    options.duration = 20;
end;

if ~isfield(options, 'offset')
    options.offset = 0.2;
end;

offset = options.offset;
bf_dur = options.duration;

n_bf = bf_dur/td;
bs = zeros(1, n_bf);
x2 = linspace(0,(bf_dur-offset)-td,(bf_dur-offset)/td);
x1 = linspace(0,offset-td,offset/td);
x = [x1, (x2+offset)];

%% estimates for smoothed gaussian
p = [0.270885699519043, 2.29354406615360, 1.49589382334256, 0.00402041347274798];
sg_gt = exp(-((x2).^2)./(2.*p(1).^2));
sg_ht = exp(-x2*p(2)) + exp (-x2*p(3));
sg_ft = conv(sg_gt, sg_ht);
bs(round((offset+td)/td):end) = p(4) * sg_ft(1:numel(x2));
