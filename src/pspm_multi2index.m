function [sts, onsets, durations] = pspm_multi2index(timeunits, multi, sr, session_duration, varargin)
% ● Description
%   pspm_multi2index converts a multi onsets structure from pspm_get_timing to a
%   cell array of numerical indices. This function is used by pspm_glm and
%   pspm_extract_segments.
% ● Format
% [onsets, durations] = pspm_multi2index('samples', multi, sr_ratio, session_duration)
% [onsets, durations] = pspm_multi2index('seconds', multi, sr, session_duration)
% [onsets, durations] = pspm_multi2index('markers', multi, sr, session_duration, events)
% ● Arguments
%           multi: multi structure from pspm_get_timing
%             sr: sampling rate, or vector of sampling rates with the same 
%                 number of elements as multi
%       sr_ratio: if data was downsampled wrt onset definition, ratio of
%                 new_sr/old_sr; or vector of sampling rate ratios.
%                 Otherwise, should be 1.
% session_duration: vector of session duration (number of elements in data
%                 vector)
%         events: cell array of event definitions (in seconds)
% ● History
%   Introduced in PsPM 6.2
%   Written in 2024 by Dominik Bach (Uni Bonn)

sts = 0; onsets = {}; durations = {};
if numel(sr) == 1
    sr = repmat(sr, numel(multi), 1);
end
if numel(sr) ~= numel(multi) || numel(session_duration) ~= numel(multi)
    warning('ID:invalid_input', 'No event definition provided.'); return;
end
if ~isempty(multi)
    for iSn = 1:numel(multi)
        for n = 1:numel(multi(iSn).names)
            % convert onsets to samples
            switch timeunits
                case {'samples', 'seconds'}
                    onsets{n}{iSn}    = pspm_time2index(multi(iSn).onsets{n}, sr(iSn), session_duration);
                    durations{n}{iSn}  = pspm_time2index(multi(iSn).durations{n}, sr(iSn), session_duration, 1);
                case 'markers'
                    if nargin == 0
                        warning('ID:invalid_input', 'No event definition provided.'); return;
                    else
                        events = varargin{1};
                    end
                    % markers are timestamps in seconds
                    onsets{n}{iSn}    = pspm_time2index(multi(iSn).onsets{n}, sr(iSn), session_duration, 0, events{iSn});
                    durations{n}{iSn}  = pspm_time2index(multi(iSn).durations{n}, sr(iSn), session_duration, 1);
            end
        end
    end
end
sts = 1;
