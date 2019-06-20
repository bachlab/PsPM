function [sts, out_channel] = pspm_ecg2hb_fmri(fn, options)
    %
    %   FORMAT:  [sts, out_channel] = pspm_ecg2hb_fmri(fn)
    %            [sts, out_channel] = pspm_ecg2hb_fmri(fn, options)
    %
    %       fn:                      [string] Path to the PsPM file which contains 
    %                                the pupil data.
    %       options:
    %           Optional:
    %               channel:         [numeric/string] Channel ID to be preprocessed.
    %                                (Default: 'ecg')
    %
    %                                Channel can be specified by its index in the given
    %                                PsPM data structure. It will be preprocessed as long
    %                                as it is a valid ECG channel.
    %
    %                                If there are multiple channels with 'ecg' type, only
    %                                the last one will be processed. If you want to detect
    %                                r-peaks for all ECG channels in a PsPM file separately,
    %                                call this function multiple times with the index of
    %                                each channel.  Further, use 'add' mode to store each
    %                                resulting 'heartbeat' channel separately.
    %
    %               channel_action:  ['add'/'replace'] Defines whether corrected data
    %                                should be added or the corresponding preprocessed
    %                                channel should be replaced. Note that 'replace' mode
    %                                does not replace the raw data channel, but a previously
    %                                stored heartbeat channel.
    %                                (Default: 'replace')
    %
    %       out_channel:             Channel ID of the preprocessed output. Output will
    %                                be written to a 'heartbeat' channel to the given PsPM
    %                                file. .data field contains a logic vector of same
    %                                length as the input ECG channel in which a true value
    %                                (1) indicates an R-peak.
    %
    % [1] Liu, Zhongming, et al. "Statistical feature extraction for artifact
    %     removal from concurrent fMRI-EEG recordings." Neuroimage 59.3 (2012):
    %     2073-2087.
    % [2] http://www.amri.ninds.nih.gov/software.html
    %__________________________________________________________________________
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    % initialise
    % -------------------------------------------------------------------------
    sts = -1;
    global settings;
    if isempty(settings), pspm_init; end;

    % create default arguments
    % --------------------------------------------------------------
    if nargin < 2
        options = struct();
    end
    if ~isfield(options, 'channel')
        options.channel = 'ecg';
    end
    if ~isfield(options, 'channel_action')
        options.channel_action = 'replace';
    end

    % input checks
    % -------------------------------------------------------------------------

    % load
    % -------------------------------------------------------------------------
    addpath(pspm_path('backroom'));
    [lsts, data] = pspm_load_single_chan(fn, options.channel, 'last', 'ecg');
    if lsts ~= 1; return; end;
    rmpath(pspm_path('backroom'));

    % process
    % -------------------------------------------------------------------------
    addpath(pspm_path('amri_eegfmri'));
    ecg.data = data{1}.data;
    ecg.srate = data{1}.header.sr;
    heartbeats{1}.data = amri_eeg_rpeak(ecg);
    rmpath(pspm_path('amri_eegfmri'));

    % save
    % -------------------------------------------------------------------------
    heartbeats{1}.header.sr = 1;
    heartbeats{1}.header.chantype = 'hb';
    heartbeats{1}.header.units = 'events';
    o.msg.prefix = 'QRS detection using AMRI algorithm';
    [lsts, infos] = pspm_write_channel(fn, heartbeats, options.channel_action);
    if lsts ~= 1; return; end;

    out_channel = infos.channel;
    sts = 1;
end
