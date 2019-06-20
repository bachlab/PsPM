%% 
% amri_sig_filtfft() - lowpass, highpass or bandpass filtering using a pair of forward 
%             and inverse fourier transform. 
%
% Usage
%   [ts_new]=amri_sig_filtfft(ts, fs, lowcut, highcut, revfilt, trans)
%
% Inputs
%   ts:      a discrete time series vector
%   fs:      sampling frequency of the time series
%   lowcut:  lowcutoff frequency (in Hz)
%   highcut: highcutoff frequency (in Hz)
%   revfilt: 0:band-pass; 1:band-stop {default: 0}
%   trans:   relative transition zone {default: 0.15}
%
% Output:
%   ts_new:  the filtered time series vector
%
% See also:
%  fft(),ifft()
%
% Version:
%   1.06
%
% Examples:
%   N/A

%% DISCLAIMER AND CONDITIONS FOR USE:
%     This software is distributed under the terms of the GNU General Public
%     License v3, dated 2007/06/29 (see http://www.gnu.org/licenses/gpl.html).
%     Use of this software is at the user's OWN RISK. Functionality is not
%     guaranteed by creator nor modifier(s), if any. This software may be freely
%     copied and distributed. The original header MUST stay part of the file and
%     modifications MUST be reported in the 'MODIFICATION HISTORY'-section,
%     including the modification date and the name of the modifier.
%
% CREATED:
%     Oct. 1, 2009
%     Zhongming Liu, PhD
%     Advanced MRI, NINDS, NIH

%% MODIFICATION HISTORY
% 1.00 - 10/01/2009 - ZMLIU - create the file based on eegfiltfft.m (EEGLAB)
% 1.01 - 01/10/2010 - ZMLIU - using sin() to small the edge of cutoff
%                           - use an nfft of a power of 2 
%                           - use transition zones
% 1.02 - 01/15/2010 - ZMLIU - fix a bug re highpass filter
% 1.03 - 04/12/2010 - ZMLIU - rename to amri_sig_filtfft.m
% 1.04 - 06/16/2010 - ZMLIU - remove dc and linear trend before filtering; 
%                           - after filtering add the trend back
% 1.05 - 07/22/2010 - ZMLIU - change the way of computing fres
%        16/11/2011 - JAdZ  - v1.05 included in amri_eegfmri_toolbox v0.1
% 1.06 - 07/15/2013 - ZMLIU - fix a bug against filter out of bounds 

function ts_new = amri_sig_filtfft(ts, fs, lowcut, highcut, revfilt, trans)

if nargin<1
    eval('help amri_sig_filtfft');
    return
end

if ~isvector(ts)
    printf('amri_sig_filtfft(): input data has to be a vector');
end

if nargin<2,fs=1;end                % default sampling frequency is 1 Hz, if not specified
if nargin<3,lowcut=NaN;end          % default lowcut is NaN, if not specified
if nargin<4,highcut=NaN;end         % default highcut is NaN, if not specified
if nargin<5,revfilt=0;end           % default revfilt=0: bandpass filter
if nargin<6,trans=0.15;end          % default relative trans of 0.15

[ts_size1, ts_size2] = size(ts);    % save the original dimension of the input signal
ts=ts(:);                           % convert the input into a column vector
npts = length(ts);                  % number of time points 
nfft = 2^nextpow2(npts);            % number of frequency points 

fv=fs/2*linspace(0,1,nfft/2+1);     % even-sized frequency vector from 0 to nyguist frequency
fres=(fv(end)-fv(1))/(nfft/2);      % frequency domain resolution
% fv=fs/2*linspace(0,1,nfft/2);     % even-sized frequency vector from 0 to nyguist frequency
% fres=(fv(end)-fv(1))/(nfft/2-1);  % frequency domain resolution


filter=ones(nfft,1);                % desired frequency response

% remove the linear trend 
ts_old = ts;                        
ts = detrend(ts_old,'linear');
trend  = ts_old - ts;

% design frequency domain filter
if (~isnan(lowcut)&&lowcut>0)&&...          % highpass
   (isnan(highcut)||highcut<=0)
   
    %          lowcut
    %              ----------- 
    %             /
    %            /
    %           /
    %-----------
    %    lowcut*(1-trans)
    
    idxl = round(lowcut/fres)+1;
    idxlmt = round(lowcut*(1-trans)/fres)+1;
    idxlmt = max([idxlmt,1]);
    filter(1:idxlmt)=0;
    filter(idxlmt:idxl)=0.5*(1+sin(-pi/2+linspace(0,pi,idxl-idxlmt+1)'));
    filter(nfft-idxl+1:nfft)=filter(idxl:-1:1);    

elseif (isnan(lowcut)||lowcut<=0)&&...      % lowpass
       (~isnan(highcut)&&highcut>0)
    
    %        highcut
    % ----------
    %           \
    %            \
    %             \
    %              -----------
    %              highcut*(1+trans)
    
    idxh=round(highcut/fres)+1;                                                                         
    idxhpt = round(highcut*(1+trans)/fres)+1;                                   
    filter(idxh:idxhpt)=0.5*(1+sin(pi/2+linspace(0,pi,idxhpt-idxh+1)'));
    filter(idxhpt:nfft/2)=0;
    filter(nfft/2+1:nfft-idxh+1)=filter(nfft/2:-1:idxh);
    
elseif lowcut>0&&highcut>0&&highcut>lowcut  
    if revfilt==0                           % bandpass (revfilt==0)
        
    %         lowcut   highcut
    %             -------
    %            /       \     transition = (highcut-lowcut)/2*trans
    %           /         \    center = (lowcut+highcut)/2;
    %          /           \
    %   -------             -----------
    % lowcut-transition  highcut+transition
    transition = (highcut-lowcut)/2*trans;
    idxl   = round(lowcut/fres)+1;
    idxlmt = round((lowcut-transition)/fres)+1;
    idxh   = round(highcut/fres)+1;
    idxhpt = round((highcut+transition)/fres)+1;
    idxl = max([idxlmt,1]);
    idxlmt = max([idxlmt,1]);
    idxh = min([nfft/2 idxh]);
    idxhpt = min([nfft/2 idxhpt]);
    filter(1:idxlmt)=0;
    filter(idxlmt:idxl)=0.5*(1+sin(-pi/2+linspace(0,pi,idxl-idxlmt+1)'));
    filter(idxh:idxhpt)=0.5*(1+sin(pi/2+linspace(0,pi,idxhpt-idxh+1)'));
    filter(idxhpt:nfft/2)=0;
    filter(nfft-idxl+1:nfft)=filter(idxl:-1:1);
    filter(nfft/2+1:nfft-idxh+1)=filter(nfft/2:-1:idxh);
    
    else                                    % bandstop (revfilt==1)
        
    % lowcut-transition  highcut+transition
    %   -------             -----------
    %          \           /  
    %           \         /    transition = (highcut-lowcut)/2*trans
    %            \       /     center = (lowcut+highcut)/2;
    %             -------
    %         lowcut   highcut
    
    
    transition = (highcut-lowcut)/2*trans;
    idxl   = round(lowcut/fres)+1;
    idxlmt = round((lowcut-transition)/fres)+1;
    idxh   = round(highcut/fres)+1;
    idxhpt = round((highcut+transition)/fres)+1;
    idxlmt = max([idxlmt,1]);
    idxlmt = max([idxlmt,1]);
    idxh = min([nfft/2 idxh]);
    idxhpt = min([nfft/2 idxhpt]);
    filter(idxlmt:idxl)=0.5*(1+sin(pi/2+linspace(0,pi,idxl-idxlmt+1)'));
    filter(idxl:idxh)=0;
    filter(idxh:idxhpt)=0.5*(1+sin(-pi/2+linspace(0,pi,idxl-idxlmt+1)'));
    filter(nfft-idxhpt+1:nfft-idxlmt+1)=filter(idxhpt:-1:idxlmt);
    
    end
    
else
    printf('amri_sig_filtfft(): error in lowcut and highcut setting');
end

X=fft(ts,nfft);                         % fft
ts_new = real(ifft(X.*filter,nfft));    % ifft
ts_new = ts_new(1:npts);                % tranc

% add back the linear trend
ts_new = ts_new + trend;

ts_new = reshape(ts_new,ts_size1,ts_size2);

return
