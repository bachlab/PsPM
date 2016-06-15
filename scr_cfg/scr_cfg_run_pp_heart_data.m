function out = scr_cfg_run_pp_heart_data(job)
% Preprocess heart data 
%
%
% $Id$
% $Rev$

fn = job.datafile{1};
replace = job.replace_chan;

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
            % e.g. ppu2hb
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
                
                opt.minhr = job.pp_type{i}.ecg2hb.opt.minhr;
                opt.maxhr = job.pp_type{i}.ecg2hb.opt.maxhr;
                opt.semi = job.pp_type{i}.ecg2hb.opt.semi;
                opt.twthresh = job.pp_type{i}.ecg2hb.opt.twthresh;
                
                % set replace
                opt.replace = replace;
                
                % call function
                [sts, winfo] = scr_ecg2hb(fn, chan, opt);
            case 'hb2hp'
                sr = job.pp_type{i}.hb2hp.sr;              
                opt = struct(); 
                opt.replace = replace;
                opt.limit = job.pp_type{i}.hb2hp.limit;
                
                [sts, winfo] = scr_hb2hp(fn, sr, chan, opt);
            case 'ecg2hp'
                sr = job.pp_type{i}.ecg2hp.sr;
                
                % copy options
                opt = struct();
                opt.minhr = job.pp_type{i}.ecg2hp.opt.minhr;
                opt.maxhr = job.pp_type{i}.ecg2hp.opt.maxhr;
                opt.semi = job.pp_type{i}.ecg2hp.opt.semi;
                opt.twthresh = job.pp_type{i}.ecg2hp.opt.twthresh;
                
                % set replace
                opt.replace = replace;
                
                % call ecg2hb
                [sts, winfo] = scr_ecg2hb(fn, chan, opt);
                
                % replace channel
                opt.replace = true;
                opt.limit = job.pp_type{i}.ecg2hp.limit;
                % call ecg2hp
                [sts, winfo] = scr_hb2hp(fn, sr, winfo.channel, opt);
            case 'ppu2hb'
                opt = struct();
                opt.replace = logical(replace);
                [sts, winfo] = scr_ppu2hb(fn, chan, opt);
        end;
        
        outputs{i} = winfo.channel;
        
    end; 
end;

out = fn;