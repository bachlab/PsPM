function [sts, import, sourceinfo] = pspm_get_smrx(datafile, import)
% ● Description
%   pspm_get_smrx is the main function for reading spike-smrx files
% ● Format
%   [sts, import, sourceinfo] = pspm_get_smr(datafile, import);
% ● Arguments
%     datafile: path to the smrx file
%   ┌───import: [struct]  The struct that stores required parameters.
%   ├─.channel: [integer] The number of the channel to load. Use '0' to
%   │                     load all channels.
%   ├───.flank: [string]
%   ├.transfer: [string]  The transfer function, use a file, an input or 'none'.
%   ├────.type: [string]  The type of input channel, such as 'scr'.
%   └──.typeno: [integer] The number of channel type, please see pspm_init.
% ● Output
%   sts: the status recording whether the function runs successfully.
%   import: the struct that stores read information.
%   sourceinfo: the struct that stores channel titles.
% ● Developer's notes
%   The following fields are read from the datafile and saved in import
%   * data      | via CEDS64ReadWaveF/CEDS64ReadEvents/CEDS64ReadMarkers
%   * div       | via CEDS64ChanDiv
%   * gain      | determined based on Unit
%   * idealRate | via CEDS64IdealRate
%   * length    | via CEDS64ReadWaveF/CEDS64ReadEvents/CEDS64ReadMarkers
%   * marker    | based on channel type
%   * number    | the number of channel
%   * realRate  | via CEDS64RealRate
%   * sr        | as realRate or idealRate (if realRate is unavailable)
%   * title     | via CEDS64ChanTitle
%   * units     | via CEDS64ChanUnits
% ● Disclaim
%   The calculation of data points for marker channels is performed by
%   multiplying time with gain and ideal rate, which has not been tested
%   and validated.
% ● History
%   Introduced in PsPM 6.2
%   Written in 2024 by Teddy

%% 1 Initialise
global settings
if isempty(settings)
    pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','CEDS64ML'));
if ~strcmpi(computer('arch'), 'win64')
    error('Reading .smrx files is available only on Windows 64bit.');
end
% Add path to CED code
cedpath = fileparts(which('CEDS64Open'));
setenv('CEDS64ML', fileparts(which('CEDS64Open')));
CEDS64LoadLib(cedpath);
maxEvents = 1e5; % this is a hardcoded value for maximum number of events import
%% 2 Get external file
warning off;
% 2.1 Open file
fhand = CEDS64Open(datafile, 1);
if (fhand < 0); error('Could not open file.'); end
% 2.2 Read file info
fileinfo.timebase      = CEDS64TimeBase(fhand);
fileinfo.maxchan       = CEDS64MaxChan(fhand);
fileinfo.maxtime       = CEDS64MaxTime(fhand);
[~, fileinfo.timedate] = CEDS64TimeDate(fhand);
fileinfo.timedate      = double(fileinfo.timedate);
% 2.3 Get list of channels
iChan = 0;
chanindx = []; % index of non-empty channels
for iChannel = 1:fileinfo.maxchan
    chanType = CEDS64ChanType(fhand, iChannel); % Read channel type
    if ismember(chanType, 1:9)
        iChan                             = iChan + 1;
        X                                 = GetCEDChanInfo(fhand, iChannel);
        for fn = fieldnames(X)'; fileinfo.chaninfo(iChan).(fn{1}) = X.(fn{1}); end % transfer to fileinfo
        fileinfo.chaninfo(iChan).type = chanType;
        chanindx = [chanindx, iChan];
    else
        iChan                             = iChan + 1;
        fileinfo.chaninfo(iChan).number   = iChannel;
        fileinfo.chaninfo(iChan).type     = 0;
        fileinfo.chaninfo(iChan).title    = '0';
    end
end
fileinfo.nchan = length(fileinfo.chaninfo);

% channel types per CEDS64ChanType.m:
%   iType - 0 no channel
%           1 Waveform channel
%           2 Event (falling)
%           3 Event (rising)
%           4 Event (both)
%           5 Marker
%           6 Wavemark
%           7 Realmark
%           8 TextMark
%           9 Realwave
%           or a negative error code

%% 3 Extract individual channels
% 3.1 Loop through import jobs
for iImport = 1:numel(import)
    % 3.1.1 define channel number
    if import{iImport}.channel > 0
        channel = chanindx(import{iImport}.channel);
    else
        [sts, channel] = pspm_find_channel({fileinfo.chaninfo.kind},...
            import{iImport}.type);
        if sts < 1, return; end
    end
    if channel > fileinfo.nchan
        warning('ID:channel_not_contained_in_file', ...
            'Channel %02.0f not contained in file %s.\n', channel, datafile);
        return;
    end
    sourceinfo.channel{iImport, 1} = sprintf('Channel %02.0f: %s', channel, fileinfo.chaninfo.title);
    % 3.1.2 read individual channels
    switch fileinfo.chaninfo(channel).type
        case 0 % empty
            warning('ID:empty_channel', 'The specified channel was not recorded. \n');
            return
        case 1 % waveform
            dataLength                = floor(fileinfo.maxtime/fileinfo.chaninfo(channel).div);
            [nWF, dataWF]             = CEDS64ReadWaveF(fhand, channel, dataLength, 1);
            import{iImport}.data      = dataWF;
            import{iImport}.length    = nWF;
            import{iImport}.sr        = fileinfo.chaninfo(channel).actualRate;

        case {2, 3} % event falling/rising
            warning('ID:untested_feature', 'The specified channel type is of untested type. Proceed at your own risk. Please reach out to PsPM developers with test data. \n');
            [nEvents, dataEvents]     = CEDS64ReadEvents(fhand, channel, maxEvents, 1, fileinfo.maxtime );

        case 4 % event both - convert to waveform so that flanks can be handled in pspm_get_events
            [ iRead, i64Times, iLevel ] = CEDS64ReadLevels( fhand, channel, maxEvents, 1, fileinfo.maxtime );

            if iLevel == 1
                i64Times = [1; i64Times];
            end
            if mod(length(i64Times), 2) == 1
                i64Times = [i64Times; fileinfo.maxtime];
            end
            i64Times = reshape(i64Times, 2, [])';
            sr = 1./CEDS64TicksToSecs(fhand, 1);
            index = pspm_epochs2logical(i64Times, fileinfo.maxtime, 1); % epochs are specified in samples, so sr = 1 (see pspm_epochs2logical)   
            import{iImport}.data      = index;
            import{iImport}.length    = numel(index);
            import{iImport}.sr        = sr;

        case 5 % marker
            [nEvents, dataMarkers]     = CEDS64ReadMarkers(fhand, channel, maxEvents, 1, fileinfo.maxtime );
            import{iImport}.markerinfo.value           = double([dataMarkers(:,1).m_Code1]);
            import{iImport}.markerinfo.name           = cellfun(@num2str, num2cell([dataMarkers(:,1).m_Code1]), 'UniformOutput', false);
            dataEvents = double([dataMarkers(:,1).m_Time]);

        otherwise
            % waiting for test data
            warning('ID:feature_unsupported', 'The specified channel is of unsupported type. Please contact the PsPM team with example data.  \n');
            return
    end

    if ismember(fileinfo.chaninfo(channel).type, [2, 3, 5])
        import{iImport}.data      = dataEvents*CEDS64TicksToSecs(fhand, 1); % convert to seconds
        import{iImport}.length    = nEvents;
        import{iImport}.sr        = 1;
    end

    if strcmpi(settings.channeltypes(import{iImport}.typeno).data, 'events')
        if ismember(fileinfo.chaninfo(channel).type, [1, 4])
            import{iImport}.marker = 'continuous';
        else
            import{iImport}.marker = 'timestamps';
        end
    elseif fileinfo.chaninfo(channel).type > 1
        % event data for wave channels is supported for smr but we have no smrx test data
        warning('ID:feature_unsupported', 'Pulse rate import is not supported for smrx files. Please contact the PsPM team with example data. \n');
        return
    end
end
%% 4 Clear path and return
rmpath(pspm_path('Import','CEDS64ML'));
sts = 1;
return
function Y = InheritFields(Y, X)
% ● Description
%   InheritFields reads fields from X and transfer to Y.
%   The fields read include number, comment div, ideal rate, title,
%   comment, units, and gain.
% ● History
%   Written in 2024 by Teddy
if isfield(X, 'div')
    Y.div = X.div;
end
if isfield(X, 'gain')
    Y.gain = X.gain;
end
if isfield(X, 'idealRate')
    Y.idealRate = X.idealRate;
end
if isfield(X, 'number')
    Y.number = X.number;
end
if isfield(X, 'title')
    Y.title = X.title;
end
if isfield(X, 'units')
    Y.units = X.units;
end
function Y = GetCEDChanInfo(fhand, i)
% ● Description
%   GetCEDChanInfo reads information from the raw file into output.
%   If the information is not available, read as an empty field.
%   This function can be used by waveform and event channels.
%   The fields read include number, comment div, ideal rate, title,
%   comment, units, and gain.
% ● History
%   Written in 2024 by Teddy
[~, Y.comment]  = CEDS64ChanComment(fhand, i);
Y.div           = CEDS64ChanDiv(fhand, i);
Y.idealRate     = CEDS64IdealRate(fhand, i);
Y.actualRate    = 1./CEDS64TicksToSecs(fhand, Y.div);
Y.number        = i;
[~, chTitle]    = CEDS64ChanTitle(fhand, i);
if ~isempty(chTitle)
    Y.title = chTitle;
else
    Y.title = num2str(i);
end
[~, Y.units]    = CEDS64ChanUnits(fhand, i); % Convert units to gain
chUnits = lower(strtrim(Y.units));
if ~isempty(chUnits)
    if contains(chUnits, 'μ') || contains(chUnits, 'micro')
        Y.gain = 1e-6;
    elseif contains(chUnits, 'milli') || contains(chUnits, 'mv')
        Y.gain = 1e-3;
    else
        Y.gain = 1;
    end
end
