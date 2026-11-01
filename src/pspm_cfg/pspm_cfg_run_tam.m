function out = pspm_cfg_run_tam(job)

model = struct();
options = struct();

%% Data & design
[newmodel, newoptions] = pspm_cfg_selector_data_design('run', job);

fields = fieldnames(newmodel);
for i = 1:numel(fields)
    model.(fields{i}) = newmodel.(fields{i});
end

%% Output
model.modelfile = pspm_cfg_selector_outputfile('run', job);

%% TAM settings
model.modality = 'pupil';
model.modelspec = job.modelspec;
model.window = job.window;
model.norm = job.norm;
model.baseline = job.baseline;
model.norm_max = job.norm_max;

%% Channel
model.channel = pspm_cfg_selector_channel('run', job.chan);

%% Filter
model.filter = pspm_cfg_selector_filter('run', job.filter);

if ischar(model.filter) && strcmpi(model.filter, 'none')
    model = rmfield(model, 'filter');
else
    if isnumeric(model.filter.lpfreq) && isnan(model.filter.lpfreq)
        model.filter.lpfreq = 'none';
    end

    if isnumeric(model.filter.hpfreq) && isnan(model.filter.hpfreq)
        model.filter.hpfreq = 'none';
    end

    if isnumeric(model.filter.down) && isnan(model.filter.down)
        model.filter.down = 'none';
    end
end

%% Standard experimental condition
if isfield(job.std_exp_cond, 'none')
    model.std_exp_cond = 'none';
elseif isfield(job.std_exp_cond, 'name')
    model.std_exp_cond = job.std_exp_cond.name;
elseif isfield(job.std_exp_cond, 'index')
    model.std_exp_cond = job.std_exp_cond.index;
end

%% Marker channel
if isfield(newoptions, 'marker_chan_num')
    options.marker_chan = newoptions.marker_chan_num;
end

%% Options
options = pspm_update_struct(options, job.output, {'overwrite'});

%% Run
[sts, ~] = pspm_tam(model, options);

if sts < 1
    error('TAM estimation failed.');
end

out = {model.modelfile};

end