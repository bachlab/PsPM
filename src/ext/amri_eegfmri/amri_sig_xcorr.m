%%
% amri_sig_xcorr: compute cross-correlation between a and b
% NOTE: computation is done to correlate shifted b to a. 
% 
% Usage 
%   c = amri_sig_xcorr(a,b);                    
%   c = amri_sig_xcorr(a,b,'maxlag',10);
%   c = amri_sig_xcorr(a,b,'method','fft');
%   c = amri_sig_xcorr(a,b,'method','tcc');
%   [c,lags] = amri_sig_xcorr(a,b);
%   [c,lags] = amri_sig_xcorr(a,b,'demean',1);
%
% Keywords
%   maxlag: maximum lag or shift
%   method: 'fft' (fourier transform) or 'tcc' (shifted correlation) {default: 'fft', which is faster}
%   demean: 1 or 0. demean both input vectors before correlation {default: 0}
% 
% See also
%   corrcoef
%
% Version
%   1.02

%% DISCLAIMER AND CONDITIONS FOR USE:
%     This software is distributed under the terms of the GNU General Public
%     License v3, dated 2007/06/29 (see http://www.gnu.org/licenses/gpl.html).
%     Use of this software is at the user's OWN RISK. Functionality is not
%     guaranteed by creator nor modifier(s), if any. This software may be freely
%     copied and distributed. The original header MUST stay part of the file and
%     modifications MUST be reported in the 'MODIFICATION HISTORY'-section,
%     including the modification date and the name of the modifier.

%% MODIFICATION HISTORY
% 1.00 - 06/01/2010 - ZMLIU - create the original file
% 1.01 - 06/23/2010 - ZMLIU - add an output 'lags'
%                           - add a new keyword 'demean'
% 1.02 - 07/23/2010 - ZMLIU - use varargin
%        16/11/2011 - JAdZ  - v1.02 included in amri_eegfmri_toolbox v0.1

function [c,lags] = amri_sig_xcorr(a,b,varargin)

if nargin<1
    eval('help amri_sig_xcorr');
    return
end

if nargin<2
    error('amri_sig_xcorr(): at least 2 inputs');
end

method = 'fft';

a = a(:);
b = b(:);

M = max([length(a) length(b)]);
if length(a)<M 
    a = [a; zeros(M-length(a),1)];
end
if length(b)<M
    b = [b; zeros(M-length(b),1)];
end

maxlag = M;
demean = 0;

% KEYWORD-VALUE PAIRS
if nargin>2 && rem(nargin,2)==1
    error('amri_sig_xcorr(): need an even number of inputs');
end

for i=1:2:size(varargin,2)
    Keyword = varargin{i};
    Value   = varargin{i+1};
    if ~ischar(Keyword) 
        printf('amri_sig_xcorr(): keywords must be strings')
        return
    end
    if strcmpi(Keyword,'maxlag') && isnumeric(Value)
        maxlag=abs(Value(1));
        if maxlag>M
            fprintf('amri_sig_xcorr(): maxlag is larger than the data length\n');
            maxlag=M;
            fprintf('amri_sig_xcorr(): maxlag is forced to be the data length\n');
        end
    elseif strcmpi(Keyword,'method') && ischar(Value)
        if strcmpi(method,'tcc') || strcmpi(method,'time')
            method='tcc';
        elseif strcmpi(method,'fft') || strcmpi(method,'frequency')
            method='fft';
        else
            error('amri_sig_xcorr(): unknown method');
        end
    elseif strcmpi(Keyword,'demean')
        switch Value,
            case 1, demean=1;
            case 0, demean=0;
            case {'y','yes'}, demean=1;
            case {'n','no'}, deman=0;
            case true, demean=1;
            case false, demean=0;
        end
    else
        error('amri_sig_xcorr(): unknown keyword');
    end
end

if demean==1
    a = a - mean(a);
    b = b - mean(b);
end

if strcmpi(method,'fft')
    % Transform both vectors
    A = fft(a,2^nextpow2(2*M-1));
    B = fft(b,2^nextpow2(2*M-1));
    % Compute cross-correlation
    c = ifft(A.*conj(B));
    c = [c(end-maxlag+1:end,:);c(1:maxlag+1,:)];
    % normalize
    c = c/sqrt(sum(a.^2)*sum(b.^2));
elseif strcmpi(method,'tcc')
    c=zeros(2*maxlag,1);
    for i=1:2*maxlag+1
        lag = i-maxlag;
        oi=1:length(a);         
        ni=lag:length(a)-1+lag;
        ai=oi(ni>=1&ni<=length(a));
        bi=1:length(ai);
        cc=corrcoef(a(ai),b(bi));
        c(i)=cc(1,2);
    end
end

lags = (-maxlag:maxlag)';
