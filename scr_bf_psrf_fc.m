function [bs, x] = scr_bf_psrf_fc(varargin)
% SCR_bf_psrf_fc
% Description: 
%
% FORMAT: [bs, x] = SCR_BF_PSRF_FC(TD, cs, cs_d, us)
%         [bs, x] = SCR_BF_PSRF_FC([TD, cs, cs_d, us])
% with td = time resolution in s and d:number of derivatives (default 0)
%
% REFERENCE
%
%________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$   
% $Rev$


% initialise
global settings
if isempty(settings), scr_init; end;

% check input arguments
if nargin==0
    errmsg='No sampling interval stated'; warning('ID:invalid_input', errmsg); return;
end;

% default values
duration = 20;

cs = 0;
cs_d = 0;
us = 0;

p_cs = [6.02748993374604 0.730338256670511 1.61015747521252 0.02934727535797];
p_us = [1.580910440721072 1.588518509251424 2.252132280243361 4.02145529040228];

% set parameters
td = varargin{1}(1);
if nargin > 1 
    if nargin > 3
        us = varargin{4};
    end;
    
    if nargin > 2
        cs_d = varargin{3};
    end;
    cs = varargin{2};
elseif numel(varargin{1}) > 1
    n = numel(varargin{1});
    if n > 3
        us = varargin{1}(4);
    end;
    if n > 2
        cs_d = varargin{1}(3);
    end;
    cs = varargin{1}(2);
end;

x = (0:td:duration)';
bs = zeros(numel(x), sum([cs,cs_d,us]));

if cs || cs_d
    a = p_cs(1);
    b = p_cs(2);
    A = p_cs(3);
    
    sta = 1+ceil(p_cs(4)/td);
    sto = numel(x);
    x_cs = (0:td:(duration - p_cs(4)))';
    
    gl_cs = gammaln(a);
    g_cs = A * (exp(log(x_cs).*(a-1) - gl_cs - (x_cs)./b - log(b)*a));
    
    % put into bs
    if cs
        bs(sta:sto, 1) = g_cs;
    end;
end;

if cs_d
    g_cs_d = [0;diff(g_cs)];
    
    % put into bs
    sta = 1+ceil(p_cs(4)/td);
    sto = numel(x);
    
    bs(sta:sto, sum([cs, cs_d])) = g_cs_d;
end;

if us
    a = p_us(1);
    b = p_us(2);
    A = p_us(3);
    
    sta = 1+ceil(p_us(4)/td);
    sto = numel(x);
    x_us = (0:td:(duration-p_us(4)))';
    
    gl_us = gammaln(a);
    g_us = A * (exp(log(x_us).*(a-1) - gl_us - (x_us)./b - log(b)*a));
    
    % put into bs
    bs(sta:sto, sum([cs, cs_d, us])) = g_us;
end;
