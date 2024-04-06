function out = pspm_cfg_run_pp_heart_data(job)
% Updated on 08-01-2024 by Teddy
fn = job.datafile{1};
outputs = cell(size(job.pp_type));
for i = 1:numel(job.pp_type)
  pp_fields = fields(job.pp_type{i});
  for j = 1:numel(pp_fields) % numel should be 1
    pp = pp_fields{j};
    % extract chan
    subs_pp.type= '.';
    subs_pp.subs = pp;
    pp_field = subsref(job.pp_type{i}, subs_pp);
    chan = pspm_cfg_channel_selector('run', pp_field.chan);
     switch pp
      case 'ecg2hb'
        % copy options
        options = struct();
        options.channel = chan;
        options.minHR = job.pp_type{i}.ecg2hb.opt.minhr;
        options.maxHR = job.pp_type{i}.ecg2hb.opt.maxhr;
        options = pspm_update_struct(options, ...
                                     job.pp_type{i}.ecg2hb.opt, ...
                                     {'semi', 'twthresh'});
        options = pspm_update_struct(options, job, 'channel_action');
        % call function
        [sts, winfo] = pspm_convert_ecg2hb(fn, options);
      case 'ecg2hb_amri'
        options = pp_field.opt;
        options.channel = chan;
        options = pspm_update_struct(options, job, 'channel_action');
        winfo = struct();
        [sts, winfo.channel] = pspm_convert_ecg2hb_amri(fn, options);
      case 'hb2hp'
        sr = job.pp_type{i}.hb2hp.sr;
        options = struct();
        options.channel = chan;
        options.limit = job.pp_type{i}.hb2hp.limit;
        options = pspm_update_struct(options, job, 'channel_action');
        [sts, winfo] = pspm_convert_hb2hp(fn, sr, options);
      case 'ecg2hp'
        sr = job.pp_type{i}.ecg2hp.sr;
        % copy options
        options = struct();
        options = pspm_update_struct(options, ...
                                     job.pp_type{i}.ecg2hp.opt, ...
                                     {'minhr', ...
                                      'maxhr', ...
                                      'semi', ...
                                      'twthresh'});
        % set replace
        options = pspm_update_struct(options, job, {'channel_action'});
        % call ecg2hb
        [sts, winfo] = pspm_convert_ecg2hb(fn, chan, options);
        if sts ~= -1
          % replace channel
          options.channel_action = 'replace';
          options = pspm_update_struct(options, ...
                                       job.pp_type{i}.ecg2hp, ...
                                       'limit');
          % call ecg2hp
          [sts, winfo] = pspm_convert_hb2hp(fn, sr, winfo.channel, options);
        end
      case 'ppg2hb'
        options = struct();
        options.channel = chan;
        options = pspm_update_struct(options, job, {'channel_action'});
        [sts, winfo] = pspm_convert_ppg2hb(fn, options);
    end
    if sts ~= -1
      outputs{i} = winfo.channel;
    else
      outputs{i} = [];
      warning('Error occured during conversion. Could not finish correctly.');
    end
  end
end
out = {fn};