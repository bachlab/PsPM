function [sts, data, newsr] = pspm_downsample(data, sr,sr_down)
% ● Description
%   pspm_downsample performs a downsampling (resampling) operation on 
%   the provided data. 
%   
%   
%   used by pspm_prepdata & pspm_dcm
%   
% ● Format
%           [sts, data, newsr] = pspm_downsample(data, sr,sr_down)
%
% ● Arguments
%   *        data:    the input data for performing downsampling on.
%   *        sr:      original sampling rate of the input data.
%   *        sr_down: targeted downsampling rate.
%
% ● Output
%   *       sts: -1 if the frequency ratio is not an integer
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao
%   Maintained in 2024 by Bernhard von Raußendorf

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
%% 2 Check input arguments
if nargin < 2
  warning('Not enough input arguments.'); return
end
%% 3 Performing downsampling

freqratio = sr/sr_down;
isL = false;

% how to downsample a logical array (pspm_dcm_test>validinput uses one)
if islogical(data)
    data = double(data);
    isL = true;
end


if settings.signal
    % this filts the data on the way, which does not really matter
    % for us anyway, but allows real sr ratios
    if sr == floor(sr) && sr_down == floor(sr_down)
        data = resample(data, sr_down, sr);
        newsr = sr_down;
        sts = 1;
        if isL
           data = logical(data);
        end
    else
        % use a crude but very general way of getting to integer
        % numbers
        altsr = floor(sr);
        altdownsr = floor(sr_down);
        data = resample(data, altdownsr, altsr);
        newsr = sr * altdownsr/altsr;
        warning('ID:nonint_sr', 'Note that the new sampling rate is a non-integer number.');
        sts = 1;
        if isL
            data = logical(data);
        end
    end
elseif freqratio == ceil(freqratio) % NB isinteger might not work for some values
    % to avoid toolbox use, but only works for integer sr ratios
    data = data(freqratio:freqratio:end); % from old pspm_downsample
    newsr = sr_down;
    sts = 1;
    if isL
        data = logical(data);
    end    
else
    sts = -1;
    errmsg = 'because signal processing toolbox is not installed and downsampling ratio is non-integer.';
    % the function gives back the not downsampled data!
end



return

end
