function out = pspm_cfg_run_pp_heart_data(job)
% Preprocess heart data
%
%
% $Id: pspm_cfg_run_pp_heart_data.m 746 2019-06-25 09:19:33Z esrefo $
% $Rev: 746 $

fn = job.datafile{1};
channel_action = job.channel_action;

outputs = cell(size(job.pp_type));

for i=1:numel(job.pp_type)
    pp_fields = fields(job.pp_type{i});
    for j=1:numel(pp_fields) % numel should be 1
        pp = pp_fields{j};
        % extract chan
        subs_pp.type= '.';
        subs_pp.subs = pp;
        pp_field = subsref(job.pp_type{i}, subs_pp);
        if isfield(pp_field.chan, 'chan_nr')
            chan = pp_field.chan.chan_nr;
        elseif isfield(pp_field.chan, 'chan_def')
            % only works as long as pp has format of something2somethingelse
            % e.g. ppg2hb
            chan = regexprep(pp, '(\w*)2(\w*)', '$1');
        elseif isfield(pp_field.chan, 'proc_chan')
            pchan = pp_field.chan.proc_chan;
            if pchan > numel(outputs)
                warning('Argument for processed channel is out of range.');
                return;
            elseif pchan >= i
                warning('Processed channel is not yet processed, cannot continue.');
                return;
            else
                chan = outputs{pchan};
            end;
        end;

        switch pp
            case 'ecg2hb'
                % copy options
                opt = struct();

                opt.minHR = job.pp_type{i}.ecg2hb.opt.minhr;
                opt.maxHR = job.pp_type{i}.ecg2hb.opt.maxhr;
                opt.semi = job.pp_type{i}.ecg2hb.opt.semi;
                opt.twthresh = job.pp_type{i}.ecg2hb.opt.twthresh;
                opt.channel_action = channel_action;

                % call function
                [sts, winfo] = pspm_ecg2hb(fn, chan, opt);
            case 'ecg2hb_amri'
                opt = pp_field.opt;
                opt.channel_action = channel_action;
                opt.channel = chan;
                winfo = struct();
                [sts, winfo.channel] = pspm_convert_ecg2hb_amri(fn, opt);
            case 'hb2hp'
                sr = job.pp_type{i}.hb2hp.sr;
                opt = struct();
                opt.channel_action = channel_action;
                opt.limit = job.pp_type{i}.hb2hp.limit;

                [sts, winfo] = pspm_convert_hb2hp(fn, sr, chan, opt);
            case 'ecg2hp'
                sr = job.pp_type{i}.ecg2hp.sr;

                % copy options
                opt = struct();
                opt.minhr = job.pp_type{i}.ecg2hp.opt.minhr;
                opt.maxhr = job.pp_type{i}.ecg2hp.opt.maxhr;
                opt.semi = job.pp_type{i}.ecg2hp.opt.semi;
                opt.twthresh = job.pp_type{i}.ecg2hp.opt.twthresh;

                % set replace
                opt.channel_action = channel_action;

                % call ecg2hb
                [sts, winfo] = pspm_ecg2hb(fn, chan, opt);

                if sts ~= -1

                    % replace channel
                    opt.channel_action = 'replace';
                    opt.limit = job.pp_type{i}.ecg2hp.limit;
                    % call ecg2hp
                    [sts, winfo] = pspm_convert_hb2hp(fn, sr, winfo.channel, opt);
                end;
            case 'ppg2hb'
                opt = struct();
                opt.channel_action = channel_action;
                [sts, winfo] = pspm_convert_ppg2hb(fn, chan, opt);
        end;

        if sts ~= -1
            outputs{i} = winfo.channel;
        else
            outputs{i} = [];
            warning('Error occured during conversion. Could not finish correctly.');
        end;

    end;
end;

out = {fn};
