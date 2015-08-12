function out = scr_cfg_run_pp_ecg(job)
% Preprocess ECG data 
%
%
% $Id$
% $Rev$

fn = job.datafile;
replace = job.replace_chan;

for i=1:numel(job.pp_type)
    pp_fields = fields(job.pp_type{i});
    for j=1:numel(pp_fields) % numel should be 1
        pp = pp_fields{j};
        switch pp
            case 'ecg2hb'
                if isfield(job.pp_type{i}.ecg2hb.chan, 'chan_nr')
                    chan = job.pp_type{i}.ecg2hb.chan.chan_nr;
                elseif isfield(job.pp_type{i}.ecg2hb.chan, 'chan_def')
                    chan = 'ecg';
                end;
                
                % copy options
                opt = struct();
                
                opt.minhr = job.pp_type{i}.ecg2hb.opt.minhr;
                opt.maxhr = job.pp_type{i}.ecg2hb.opt.maxhr;
                opt.peakmaxhr = job.pp_type{i}.ecg2hb.opt.peakmaxhr;
                opt.semi = job.pp_type{i}.ecg2hb.opt.semi;
                opt.twthresh = job.pp_type{i}.ecg2hb.opt.twthresh;
                
                % set replace
                opt.replace = replace;
                
                % call function
                scr_ecg2hb(fn, chan, opt);
            case 'hb2hp'
                sr = job.pp_type{i}.hb2hp.sr;
                
                if isfield(job.pp_type{i}.hb2hp.chan, 'chan_nr')
                    chan = job.pp_type{i}.hb2hp.chan.chan_nr;
                elseif isfield(job.pp_type{i}.ecg2hb.chan, 'chan_def')
                    chan = 'hb';
                end;
                
                opt = struct(); 
                opt.replace = replace;
                
                scr_hb2hp(fn, sr, chan, opt);
        end;
        
    end; 
end;

out = fn;