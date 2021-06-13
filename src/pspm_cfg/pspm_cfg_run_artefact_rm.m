function out = pspm_cfg_run_artefact_rm(job)
% Executes pspm_pp

% $Id$
% $Rev$

options = struct;
options.overwrite = job.overwrite;

filtertype = fieldnames(job.filtertype);
filtertype = filtertype{1};
datafile = job.datafile;
datafile = datafile{1};
channelnumber = job.chan_nr;

switch filtertype
    case 'median'
        n = job.filtertype.(filtertype).nr_time_pt;
        out = pspm_pp(filtertype, datafile, n, channelnumber, options);
    case 'butter'
        freq = job.filtertype.(filtertype).freq;
        out = pspm_pp(filtertype, datafile, freq, channelnumber, options);
    case 'scr_pp'
        scr_job = job.filtertype.(filtertype);
        % Option structure sent to pspm_simple_qa
        scr = struct();
        if isfield(scr_job, 'min'), scr.min = scr_job.min; end % Check if min is defined
        if isfield(scr_job, 'max'), scr.max = scr_job.max; end % Check if max is defined
        if isfield(scr_job, 'slope'), scr.slope = scr_job.slope; end % Check if slope is defined
        % Check if missing_epochs is defined
        if isfield(scr_job.missing_epochs, 'write_to_file')
            if isfield(scr_job.missing_epochs.write_to_file,'filename') && ...
                    isfield(scr_job.missing_epochs.write_to_file,'outdir')

                scr.missing_epochs_filename = fullfile( ...
                    scr_job.missing_epochs.write_to_file.outdir{1}, ...
                    scr_job.missing_epochs.write_to_file.filename);

            end
        end

        % Check if deflection_threshold is defined
        if isfield(scr_job, 'deflection_threshold')
            scr.deflection_threshold = scr_job.deflection_threshold;
        end

        % Check if data_island_threshold is defined
        if isfield(scr_job, 'data_island_threshold')
            scr.data_island_threshold = scr_job.data_island_threshold;
        end

        % Check if expand_epochs is defined
        if isfield(scr_job, 'expand_epochs')
            scr.expand_epochs = scr_job.expand_epochs;
        end

        % Check if data will be changed
        if ~isfield(options, 'change_data')
            options.change_data = 1;
        end

        % out = pspm_pp(filtertype, datafile, qa, channelnumber, options);
        newdatafile = [];
        [sts, infos, data] = pspm_load_data(datafile, 0);
        if sts ~= 1
            warning('ID:invalid_input', 'call of pspm_load_data failed');
            return;
        end
        for k = 1:numel(channum)
            curr_chan = channum(k);
            [sts, data{curr_chan}.data] = pspm_scr_pp(data{curr_chan}.data, data{curr_chan}.header.sr);
            if sts == -1
                warning('ID:invalid_input', 'call of pspm_scr_pp failed in round %s',k);
                return;
            end
        end
        infos.pp = sprintf('Preprocessing SCR');

        % save data only if change_data is set to 1
        if scr.change_data == 1
            [pth, fn, ext] = fileparts(datafile);
            newdatafile = fullfile(pth, ['m', fn, ext]);
            infos.ppdate = date;
            infos.ppfile = newdatafile;
            clear savedata
            savedata.data = data;
            savedata.infos = infos;
            savedata.options = options;
            sts = pspm_load_data(newdatafile, savedata);
            fprintf(' done\n');
        end

        if ~iscell(newdatafile)
            newdatafile = {newdatafile};
        end
end
