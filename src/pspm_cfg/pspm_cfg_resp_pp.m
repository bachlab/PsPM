function resp_pp = pspm_cfg_resp_pp
    % Coversion of continuous respiration data various respiration data types

    % $Id: pspm_cfg_resp_pp.m 626
    % 2019-02-20 16:14:40Z lciernik $
    % 15-06-2021 Teddy Chao
    % $Rev: 626 $

    % Initialise
    global settings
    if isempty(settings)
        pspm_init;
    end

    % Data File
    datafile         = cfg_files;
    datafile.name    = 'Data File';
    datafile.tag     = 'datafile';
    datafile.num     = [1 1];
    %datafile.filter  = '.*\.(mat|MAT)$';
    datafile.help    = {['Specify data file. The processed ' ...
    'respiration data will be written to a new channel in this file.'],...
    ' ',settings.datafilehelp};

    % Sample rate
    sr         = cfg_entry;
    sr.name    = 'Sample Rate';
    sr.tag     = 'sr';
    sr.strtype = 'r';
    sr.num     = [1 1];
    sr.val     = {10};
    sr.help    = {['Sample rate for the new channel. Default: 10 Hz. '], ...
    ['Will be ignored for datatype "respiration time stamps".']};

    % Channel
    chan_def         = cfg_const;
    chan_def.name    = 'Default';
    chan_def.tag     = 'chan_def';
    chan_def.val     = {0};
    chan_def.help    = {'First respiration channel.'};

    chan_nr         = cfg_entry;
    chan_nr.name    = 'Number';
    chan_nr.tag     = 'chan_nr';
    chan_nr.strtype = 'i';
    chan_nr.num     = [1 1];
    chan_nr.help    = {''};

    chan         = cfg_choice;
    chan.name    = 'Channel';
    chan.tag     = 'chan';
    chan.val     = {chan_def};
    chan.values  = {chan_def,chan_nr};
    chan.help    = {'Number of respiration channel (default: first respiration channel).'};

    % define channel_action
    % ------------------------------------------------------
    channel_action = cfg_menu;
    channel_action.name = 'Channel action';
    channel_action.tag  = 'channel_action';
    channel_action.values = {'add', 'replace'};
    channel_action.labels = {'Add', 'Replace'};
    channel_action.val = {'add'};
    channel_action.help = {'Choose whether to add the new channels or replace a channel previously added by this method.'};


    stype_bellows      = cfg_const;
    stype_bellows.name = 'Bellows';
    stype_bellows.tag  = 'bellows';
    stype_bellows.val  = {'bellows'};
    stype_bellows.help = {''};

    stype_cushion      = cfg_const;
    stype_cushion.name = 'Cushion';
    stype_cushion.tag  = 'cushion';
    stype_cushion.val  = {'cushion'};
    stype_cushion.help = {''};

    systemtype        = cfg_choice;
    systemtype.name   = 'System type';
    systemtype.tag    = 'systemtype';
    systemtype.val    = {stype_bellows};
    systemtype.values = {stype_bellows, stype_cushion};
    systemtype.help   = {'Type of the measuring system: bellows or cushion'};

    dtype_rp        = cfg_menu;
    dtype_rp.name   = 'Respiration period';
    dtype_rp.tag    = 'rp';
    dtype_rp.val    = {1};
    dtype_rp.labels = {'No', 'Yes'};
    dtype_rp.values = {0, 1};
    dtype_rp.help   = {'Create a channel with interpolated respiration period.'};

    dtype_ra        = cfg_menu;
    dtype_ra.name   = 'Respiration amplitude';
    dtype_ra.tag    = 'ra';
    dtype_ra.val    = {1};
    dtype_ra.labels = {'No', 'Yes'};
    dtype_ra.values = {0, 1};
    dtype_ra.help   = {'Create a channel with interpolated respiration amplitude.'};

    dtype_rfr        = cfg_menu;
    dtype_rfr.name   = 'Respiratory flow rate';
    dtype_rfr.tag    = 'rfr';
    dtype_rfr.val    = {1};
    dtype_rfr.labels = {'No', 'Yes'};
    dtype_rfr.values = {0, 1};
    dtype_rfr.help   = {'Create a channel with interpolated respiratory flow rate.'};

    dtype_rs        = cfg_menu;
    dtype_rs.name   = 'Respiration time stamps';
    dtype_rs.tag    = 'rs';
    dtype_rs.val    = {1};
    dtype_rs.labels = {'No', 'Yes'};
    dtype_rs.values = {0, 1};
    dtype_rs.help   = {'Create a channel with respiration time stamps.'};

    datatype       = cfg_branch;
    datatype.name  = 'Data type';
    datatype.tag   = 'datatype';
    datatype.val   = {dtype_rp, dtype_ra, dtype_rfr, dtype_rs};
    datatype.help  = {''};

    plot         = cfg_menu;
    plot.name    = 'Diagnostic plot';
    plot.tag     = 'plot';
    plot.val     = {0};
    plot.labels  = {'No', 'Yes'};
    plot.values  = {0, 1};
    plot.help    = {'Specify whether a respiratory cycle detection plot ', ...
    'should be created (Yes) or not (No) (default: No).'};

    options        = cfg_branch;
    options.name   = 'Options';
    options.tag    = 'options';
    options.val    = {systemtype, datatype, plot};
    options.help   = {['Choose for each possible process datatype either ', ...
    'yes or no (default: yes)']};

    % Executable Branch
    resp_pp      = cfg_exbranch;
    resp_pp.name = 'Preprocess respiration data';
    resp_pp.tag  = 'resp_pp';
    resp_pp.val  = {datafile,sr,chan, channel_action ,options};
    resp_pp.prog = @pspm_cfg_run_resp_pp;
    resp_pp.vout = @pspm_cfg_vout_resp_pp;
    resp_pp.help = {['Convert continuous respiration traces into interpolated ', ...
    'respiration period, amplitude, or RFR, or into time stamps indicating ', ...
    'the start of inspiration. This function detects the beginning of ', ...
    'inspiration, assigns period/amplitude/RFR of the last cycle to this ', ...
    'data point, and interpolates data. This function outputs respiration ', ...
    'period rather than respiration rate in analogy to heart period models ', ...
    '- heart period linearly varies with ANS input to the heart. ', ...
    'RFR (respiratory flow rate) is the integral of the absolute thorax ', ...
    'excursion per respiration cycle, divided by the cycle period. ', ...
    'Converted data are written into new channel(s).']};

    function out = pspm_cfg_run_resp_pp(job)
        sr = job.sr;% sample rate
        if isfield(job.chan,'chan_nr')
            chan = job.chan.chan_nr;
        else
            chan = '';
        end
        resp_pp_options.plot = job.options.plot;
        if isfield(job.options.systemtype, 'bellows')
            resp_pp_options.systemtype = 'bellows';
        else
            resp_pp_options.systemtype = 'cushion';
        end
        f = fields(job.options.datatype);
        resp_pp_options.datatype = {};
        for i = 1:numel(f)
            if job.options.datatype.(f{i}) == 1
                resp_pp_options.datatype = [resp_pp_options.datatype, f{i}];
            end
        end
        resp_pp_options.channel_action = job.channel_action;
        sts = pspm_resp_pp(job.datafile{1}, sr, chan, resp_pp_options);
        out = job.datafile;
    end

    function vout = pspm_cfg_vout_resp_pp(job)
        vout = cfg_dep;
        vout.sname      = 'Output File';
        vout.tgt_spec = cfg_findspec({{'class','cfg_files'}});
        vout.src_output = substruct('()',{':'});
    end
end
