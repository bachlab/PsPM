% Find R peaks from ECG
%                    
% amri_eeg_rpeak() 
%
% Usage
%   [r_peaks]=amri_eeg_rpeak(ECG)
%
% Outputs
%
% Inputs
%   ECG   =   ECG data stored as an EEGLAB strcuture
%
% Keywords
%   PulseRate: [min max]
%   WhatIsY:   TEO or ECG as input for R-peak detection
% 
% See also:
%   amri_sig_filtfft, 
%   amri_sig_findpeaks,
%   amri_stat_outlier
%
% Version:
%   0.12
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
%     Oct. 21, 2009
%     Zhongming Liu, PhD
%     Advanced MRI, NINDS, NIH

%% MODIFICATION HISTORY
% 0.00 -            - ZMLIU - take out from eeg_cbc() and create the file
%                           - update the initial pulse rate range
% 0.01 -            - ZMLIU - rename as eeg_rpeak()
% 0.02 -            - ZMLIU - refine corr computation at beginning and end of data
% 0.03 -            - ZMLIU - rename as amri_eeg_rpeak.m
% 0.04 -            - ZMLIU - use amri_sig_filtfft instead of filtfft
%                           - use amri_sig_findpeaks instead of findpeaks
% 0.05 - 07/07/2010 - ZMLIU - add try catch to find kTEO.k from pwelch or as 3
%                           - use amri_sig_corr instead of corr
%                           - use amri_sig_xcorr instead of xcorr
%                           - use varargin instead of pairs of p# and v#
% 0.06 - 07/09/2010 - ZMLIU - find kTEO.k from autocorrelation curve
%                           - find ecg peak mainly based on ccorr, and
%                             confirm the peak if surrounding points also
%                             contain a peak of Y.
% 0.07 - 02/01/2011 - ZMLIU - use TEO instead of k-TEO
% 0.08 - 11/11/2011 - ZMLIU - clear up some comments before release
%        16/11/2011 - JAdZ  - v0.08 included in amri_eegfmri_toolbox v0.1
% 0.09 - 01/13/2012 - ZMLIU - add an exception handler
% 0.10 - 04/09/2012 - ZMLIU - create a new event with the same fields from
%                             existing eeg.event
% 0.11 - 08/08/2012 - ZMLIU - change the default range of pulse rate 
% 0.12 - 07/31/2013 - ZMLIU - use TEO or ECG for rr-interval estimation
%                           - better acorr gives more reliable estimation
%                           - option to use TEO or ECG for r peak detection
% 0.13 - 20/06/2019 - esref - Modify interface to remove EEG related things
%                           - Change lines 
%                               [~,imax]=max(weights.*ccorr(anarrowrange));
%                             to
%                               [~,imax]=max(weights' .* ccorr(anarrowrange));
%                             so that a regular expectation is calculated.

%%
function r_peaks = amri_eeg_rpeak(ecg,varargin)

if nargin<1
    error('amri_eeg_rpeak(): need at least one input');
end

%% ************************************************************************
% Defaults
% *************************************************************************

min_pulse_rate = 50;            % per minute
max_pulse_rate = 100;           % per minute

r_marker.name  = 'R';           % r marker name
r_marker.code  = 'Response';    % r marker type [NOT USED]

filter_method  = 'ifft';        % only 'ifft' currently available

kTEO.k         = 1;             % frequency selector
kTEO.lowcutoff = 8;             % low cutoff
kTEO.highcutoff= 40;            % high cutoff

thres.mincc    = 0.5;           % cross corr to the template
thres.maxrpa   = 3;             % max relative peak amplitude
thres.minrpa   = 0.4;           % min relative peak amplitude

whatisy        = 'teo';        % 'TEO' or 'ECG'

checking       = 0;             % check intermediate results
flag_verbose   = 0;             % 1|0, whether print out information      

%% ************************************************************************
% Collect keyword-value pairs
% *************************************************************************

if (nargin> 2 && rem(nargin,2) == 1)
    printf('amri_eeg_cbc(): Even number of input arguments???')
    return
end

for i = 1:2:size(varargin,2) % for each Keyword
    Keyword = varargin{i};
    Value = varargin{i+1};
    if strcmpi(Keyword,'pulserate')
        if isscalar(Value)
            max_pulse_rate = Value+20;
            min_pulse_rate = Value-20;
        else
            max_pulse_rate = Value(2);
            min_pulse_rate = Value(1);
        end
    elseif strcmpi(Keyword,'whatisy')
        whatisy=Value;
    end
end


%% ************************************************************************
% The following codes are used to compute from the ecg lead a k-TEO 
% "complex lead" signal. The k-TEO signal, stored in Y, takes place 
% of the original ecg signal in the subsequent R-peak detection
%

% bandpass filtering from 10 to 40 Hz, in order to suppress T-waves
if strcmpi(filter_method,'ifft')
    ecg.data = amri_sig_filtfft(ecg.data,ecg.srate,0.5,40);
    E = amri_sig_filtfft(ecg.data,ecg.srate,kTEO.lowcutoff,kTEO.highcutoff); 
end

kTEO.k=1;
% construct a complex lead by k-Teager energy operator
if flag_verbose>0
    fprintf(['amri_eeg_rpeak(): construct k-TEO complex (k=' ...
        int2str(kTEO.k) ')\n']);
end
k=kTEO.k;
% Y = zeros(size(E));
Ekm = ones(size(E))*nan;
Ekp = ones(size(E))*nan;
Ekm(k+1:end) = E(1:end-k);
Ekp(1:end-k) = E(k+1:end);
Y = E.^2-Ekm.*Ekp;
Y(isnan(Y))=0;
Y(Y<=0)=0;
clear E Ekm Ekp;

% *************************************************************************


%% ************************************************************************
% compute the average r-r interval using autocorrelation analysis

% varname={'Y','ecg.data'};
varname={'ecg.data','Y'};
acorrmax=0;
for iv=1:length(varname)
    X=eval(varname{iv});
    % printf('amri_eeg_rpeak(): estimate R-R interval');
    acorr_tmp = amri_sig_xcorr(X,X,'maxlag',60/min_pulse_rate*ecg.srate);   % autocorrelation
    peaks = amri_sig_findpeaks(acorr_tmp);                                  % find peaks

    timerange = -fix(length(acorr_tmp)/2):fix(length(acorr_tmp)/2); % in time points
    timerange = timerange/ecg.srate;                        % in sec

    % timerangepr is the range defined by maximal and minimal pulse rate (per minute)
    timerangepr =timerange(timerange>60/max_pulse_rate&timerange<60/min_pulse_rate);
    % acorrrangepr is the autocorrelation within timerangepr
    acorrrangepr_tmp=acorr_tmp(timerange>60/max_pulse_rate&timerange<60/min_pulse_rate);
    % find the maximal autocorrelation within timerangepr
    [acorrmax_tmp,imax_tmp]=max(acorrrangepr_tmp);
    if acorrmax_tmp>=acorrmax
        imax=imax_tmp;
        acorrmax=acorrmax_tmp;
        acorrrangepr=acorrrangepr_tmp;
        acorr=acorr_tmp;
        Y_auto=X;
    end
end

% 07-31-2013, ZMLIU & Jen
if strcmpi(whatisy,'auto')
    Y=Y_auto;
elseif strcmpi(whatisy,'TEO')
    % do nothing
elseif strcmpi(whatisy,'ECG')
    Y=ecg.data;
end

% the time of the maximal autocorrelation is the iri (in sec)
irisec=timerangepr(imax);                            % iri in sec
iri=round(irisec*ecg.srate);                         % iri in time points
% update min_pulse_rate and max_pulse_rate to be more precise
% the updated pulse range should cover 3*FWHM of the autocorr function
old_min_pr = min_pulse_rate;
old_max_pr = max_pulse_rate;
[~,itemp]=min(abs(acorrrangepr(imax+1:end)-acorrmax/2));
itemp=round(itemp*3+imax);
itemp=min([length(timerangepr) itemp]);
min_pulse_rate=60/timerangepr(itemp);
[~,itemp]=min(abs(acorrrangepr(1:imax-1)-acorrmax/2));
itemp=round(imax-(imax-itemp)*3);
itemp=max([itemp 1]);
max_pulse_rate=60/timerangepr(itemp);

% display
if checking>=1
    figure;
    set(gcf,'Color','w');
    plot(timerange,acorr,'k');                              % autocorrelation curve
    title('IRI estimate using autocorrelation','FontSize',12);
    xlabel('Time (sec)','FontSize',12);
    ylabel('Autocorrelation','FontSize',12);
    box off; hold on;
    plot(timerange(peaks>0),acorr(peaks>0),'sk');           % mark positive peaks
    yrange=get(gca,'YLim');
    yline =yrange(1):0.01:yrange(2);
    plot(ones(size(yline))*60/old_min_pr,yline,'--b');      % a dashed blue line for min pulse rate
    plot(ones(size(yline))*60/old_max_pr,yline,'--b');      % a dashed blue line for max pulse rate
    plot(ones(size(yline))*60/min_pulse_rate,yline,'b');    % a blue line for min pulse rate
    plot(ones(size(yline))*60/max_pulse_rate,yline,'b');    % a blue line for max pulse rate
    plot(ones(size(yline))*irisec,yline,'r');               % a red line for irisec
    text(irisec,yrange(2),sprintf('IRI=%.3f s', irisec),'Color','r');
end

% *************************************************************************

%% ************************************************************************
% compute the median and standard deviation of R-peak height
% segment k-TEO complex signal into many epochs of length of 2*iri.
% the reason 2*iri is used in segmentation is just to ensure that at 
% least one cardiac cycle is contained in each epoch
% find a max value for each epoch as a sample of r_heights (note that
% r_heights here are not the heights of r peaks but the heights of the
% complex signals (hopefully) corresponding to the r peak time points)
% then, the median and standard deviation of r_heights are computed.

r_heights = zeros(1,round(length(Y)/2/iri));
for i = 1 : length(r_heights)
    r_heights(i) = max(Y((i-1)*2*iri+1:min([i*2*iri,length(Y)])));
end
[~,I]=amri_stat_outlier(r_heights);
r_heights(I)=[];
median_r_height = median(r_heights);
std_r_height = std(r_heights);
max_r_height = max(r_heights);
min_r_height = min(r_heights);

% *************************************************************************


%% ************************************************************************
% get a template for a single heart beat
%

% first, try to find a segment, with a length of 5*iri, that contains 
% no outlier typically resulting from huge residual of gradient artifact
% printf('amri_eeg_rpeak(): setup a template of a pulse cycle');
for i=1:fix(length(Y)/(5*iri))
    timerange = iri*5*(i-1)+iri+1: min([iri*5*i+iri length(Y)]);
    % an outlier differs from median_r_height by 3*std_r_height
    outliers = find(Y(timerange)>median_r_height+3*std_r_height);
    % if no outlier is found in the current time range
    % jump out of search loop, because this is the time range 
    % we want to find a template of cardiac cycle. 
    if isempty(outliers)
        break;
    else
        if i==fix(length(Y)/(5*iri)) 
            % if outlier exists even after reaching the last segment
            % exclude the outlier time points in the last segment
            printf('eeg_gac(): no template is found');
            timerange(outliers)=[];
        end
    end
end

% after identifying a 5*iri segment as the base period for template
% search. (Note that this base period is most typically located close 
% to the beginning of the data)
% find the maximal value in this time range. The time point of the
% maximum is the r peak location of the template. Then we define a
% template segment centered at the r peak with a length of iri (if
% possible).
[~,temp_i]=max(Y(timerange));

template_center = timerange(temp_i);
template_before = max([1 template_center-round(iri/2)+1]);
template_after  = min([length(Y) template_center+round(iri/2)-1]);
template_length = template_after-template_before+1;      %#ok<NASGU>
template_peak_local = template_center-template_before+1; %#ok<NASGU>
template = Y(template_before:template_after);

if checking>=1
    figure;
    set(gcf,'Color','w');
    plot(Y,'k');
    hold on;
    box off;
    xlim([max([min(timerange)-iri 1]) min([max(timerange)+iri length(Y)])]);
    yrange=get(gca,'YLim');
    yline=yrange(1):diff(yrange)/100:yrange(2);
    plot(ones(size(yline))*template_center,yline,'r');
    text(template_center,yrange(2),'center');
    plot(ones(size(yline))*template_before,yline,'b');
    text(template_before,yrange(2),'start');
    plot(ones(size(yline))*template_after,yline,'b');
    text(template_after,yrange(2),'end');
    xlabel('Time (by point)','FontSize',12);
    ylabel('k-TEO Complex lead','FontSize',12);
    title('Template Search','FontSize',12);
end

% *************************************************************************

%% ************************************************************************
% identify r peaks for all heart beats by combining peak detection 
% and cross correlation
% initial r-peak detection, BEGIN

% peak detection based on amplitude
% printf('amri_eeg_rpeak(): initial R peak detection');
Ypeaktimes = amri_sig_findpeaks(Y,'pos');
Ypeaks=zeros(size(Y));
% exclude outliers
Ypeaktimes(Y>max_r_height|Y<min_r_height)=0;
% normalize by median_r_height
Ypeaks(Ypeaktimes>0)=Y(Ypeaktimes>0)/median_r_height; 

% peak detection based on cross correlation 
% (this is relatively a time consuming process)
ccorr = ones(size(Y))*nan;
for i=1:length(Y)
    asegment_center = i;
    asegment_before = asegment_center-(template_center-template_before);
    asegment_after  = asegment_center+(template_after-template_center);
    if asegment_before<1 % data beginning
        asegment = Y(1:asegment_after);
        ccorr(i)=amri_sig_corr(asegment',template(1-asegment_before+1:end)');
    elseif asegment_after>length(Y)
        asegment = Y(asegment_before:end);
        ccorr(i)=amri_sig_corr(asegment',template(1:length(asegment))');
        continue;
    else
        asegment = Y(asegment_before:asegment_after);
        ccorr(i)=amri_sig_corr(asegment',template');
    end
end

% identify a time point as an r peak, if satisfying both the amplitude
% and correaltion criteria
% r_peaks=zeros(size(Y));   % 0: not r peak; 1: is r peak
r_peaks=amri_sig_findpeaks(ccorr,'pos')>0&ccorr>thres.mincc;
r_peaks_time=find(r_peaks>0);
Ypeakuncertainty=round(0.04*ecg.srate);
ecgpeakuncertainty=round(0.04*ecg.srate);
for i=1:length(r_peaks_time)
    ti = r_peaks_time(i);
    ti_from   = max([1 ti-Ypeakuncertainty]);
    ti_to     = min([length(Y) ti+Ypeakuncertainty]);
    ti_range1 = ti_from:ti_to;
    ti_from   = max([1 ti-ecgpeakuncertainty]);
    ti_to     = min([length(Y) ti+ecgpeakuncertainty]);
    ti_range2 = ti_from:ti_to;
    if ~any(Ypeaks(ti_range1)>0)
        r_peaks(ti)=0;
    else
        ypeakval = max(Ypeaks(ti_range1));
        if ypeakval<thres.minrpa
            r_peaks(ti)=0;
        else
            [~,j]=max(ecg.data(ti_range2));
            tj=ti_range2(j);
            r_peaks(ti)=0;
            r_peaks(tj)=1;
        end
    end
end
old_r_peaks = r_peaks;

% initial r-peak detection, END
% ---------------------------------------------------------------------

% ---------------------------------------------------------------------
% correct false positive or negative 
% false correction, BEGIN

r_peaks_time = find(r_peaks==1);
r_peaks_interval = diff(r_peaks_time);

% printf('amri_eeg_rpeak(): detect and remove false positives');
% remove false positive until no false positive is found or search for
% false positives has been done 5 times
num_lp = 1;
max_loop = 10;
while num_lp<=max_loop
    for i=2:length(r_peaks_time)
        rrint = r_peaks_time(i)-r_peaks_time(i-1);
        if rrint<round(60/max_pulse_rate*ecg.srate);
            % if a false positive is detected
            % then remove both the previous and current r peaks
            % set a new r peak at the time point of maximal correlation
            r_peaks(r_peaks_time(i-1))=0;
            r_peaks(r_peaks_time(i))=0;
            timerange=r_peaks_time(i-1):r_peaks_time(i);
            [~,imax]=max(ccorr(timerange));
            r_peaks(timerange(imax))=1;
        end
    end
    r_peaks_time = find(r_peaks==1);
    if ~sum(diff(r_peaks_time)<round(60/max_pulse_rate*ecg.srate))
        break;
    end
    num_lp=num_lp+1;
end

r_peaks_time = find(r_peaks==1);
r_peaks_interval = diff(r_peaks_time);


% an estimate of the standard deviation of r-r interval
iri_std = round(std(r_peaks_interval(r_peaks_interval<60/min_pulse_rate*ecg.srate)));
% new_r_peaks will contain the positions of the new r peaks that need to be inserted
new_r_peaks = [];


% printf('amri_eeg_rpeak(): detect and add false negatives');
for i=2:length(r_peaks_time);
    rrint = r_peaks_time(i)-r_peaks_time(i-1);
    if rrint>round(60/min_pulse_rate*ecg.srate);
        % if one or more false negatives are detected
        % first estimate how many r peaks were missed for the time
        % range between the previous and current r peaks
        fnn = round(rrint/iri)-1;
        if fnn>=1                
            add_r_peaks = zeros(1,fnn);
            rough_iri = round(rrint/(fnn+1));
            if rough_iri>round(60/min_pulse_rate*ecg.srate) || ...
               rough_iri<round(60/max_pulse_rate*ecg.srate)
                rought_iri=iri;
            end
            for jj=1:fnn
                % compute a tentative "new" r peak position
                t_r_peak = r_peaks_time(i-1)+rough_iri*jj;
                % since the tentative r peak should be very close to be
                % accurate, the real r peak is determined as the
                % time point of the maximum of the "weighted" ccorr within 
                % a narrow range around the tentative r peak position. 
                anarrowrange=t_r_peak-3*iri_std:t_r_peak+3*iri_std;
                weights = 1/sqrt(2*pi)/iri_std*exp(-(anarrowrange-t_r_peak).^2/(2*iri_std^2));
                % add exception handler 2012-01-13
                try
                    [~,imax]=max(weights' .* ccorr(anarrowrange));
                    add_r_peaks(jj)=anarrowrange(imax);
                catch err
                    if strcmpi(err.identifier,'MATLAB:badsubscript')
                        weights(anarrowrange<1)=[];
                        weights(anarrowrange>length(ccorr))=[];
                        anarrowrange(anarrowrange<1)=[];
                        anarrowrange(anarrowrange>length(ccorr))=[];
                        [~,imax]=max(weights' .* ccorr(anarrowrange));
                        add_r_peaks(jj)=anarrowrange(imax);
                    end
                end
            end
            new_r_peaks = [new_r_peaks add_r_peaks]; %#ok<AGROW>
        end
    end
end

r_peaks(new_r_peaks)=1;

r_peaks_time = find(r_peaks==1);
r_peaks_interval = diff(r_peaks_time);

% false correction, END
% ---------------------------------------------------------------------


%% ************************************************************************
% append R markers to the event array
% printf('amri_eeg_rpeak(): write R markers');
r_index=find(r_peaks>0);

return;
