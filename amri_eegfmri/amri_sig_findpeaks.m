%% 
% amri_sig_findpeaks() - peak detection for vectorial time-series input
%               
% Usage
%   [peaks]=amri_sig_findpeaks(ts);       % find both positive and negative peaks in ts
%   [peaks]=amri_sig_findpeaks(ts,'pos'); % find positive peaks in ts
%   [peaks]=amri_sig_findpeaks(ts,'neg'); % find negative peaks in ts
%
% Inputs
%   ts:      a discrete time series vector
%
% Outputs
%   peaks:   a vector of the same length as the input vector
%            0: non peak
%           >0: positive peak
%           <0: negative peak
%
% See also:
%  diff()
%
% Version:
%   1.02
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
%     Nov. 3, 2009
%     Zhongming Liu, PhD
%     Advanced MRI, NINDS, NIH

%% MODIFICATION HISTORY
% 1.00 - 10/01/2009 - ZMLIU - Create the file inspired by 
%                             eeg_peaks() by Darren Weber and
%                             peakdet() by Eli Billauer
% 1.01 - 11/05/2009 - ZMLIU - Add options to output positive or negative
%                             peaks
% 1.02 - 06/18/2010 - ZMLIU - print 'help' when no input
%        16/11/2011 - JAdZ  - v1.02 included in amri_eegfmri_toolbox v0.1

function [peaks] = amri_sig_findpeaks(ts,type)
    if nargin<1
        eval('help amri_sig_findpeaks');
        return
    end
    
    if nargin<2
        type='both';
    end

    [m,n]=size(ts);
    ts = ts(:);
    diff1 = [0;diff(ts)<0;0];
    peaks = diff(diff1);
    peaks([1 end],:) = 0;
    peaks=reshape(peaks,m,n);
    
    if strncmpi(type,'pos',3)
        peaks(peaks<0)=0;
    elseif strncmpi(type,'neg',3)
        peaks(peaks>0)=0;
    else
        % do nothing
    end
