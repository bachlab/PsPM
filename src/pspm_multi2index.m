function index = pspm_multi2index(timeunits, multi, sr, varargin)

if ~isempty(multi)
    for iSn = 1:multi
        for n = 1:numel(multi(iSn).names)
            % convert onsets to samples
            switch model.timeunits
                case 'samples'
                    index{n}{iSn}    = pspm_time2index(multi(iSn).onsets{n}, sr, tmp.snduration(iSn));
                    newdurations = round(multi(iSn).durations{n} * newsr/sr(iSn));
                case 'seconds'
                    newonsets    = pspm_time2index(multi(iSn).onsets{n}, newsr, tmp.snduration(iSn));
                    newdurations = round(multi(iSn).durations{n} * newsr);
                case 'markers'
                    try
                        % markers are timestamps in seconds
                        newonsets = pspm_time2index(events{iSn}(multi(iSn).onsets{n}), ...
                            newsr, tmp.snduration(iSn));
                    catch
                        warning(['\nSome events in condition %01.0f were ', ...
                            'not found in the data file %s'], n, ...
                            model.datafile{iSn}); return;
                    end
                    newdurations = multi(iSn).durations{n};
            end
        end
    end
end
