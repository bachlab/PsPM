function [out] = scr_cfg_run_segment_mean(job)

[path, fn, ~] = fileparts([job.output_file.file_path{1} filesep job.output_file.file_name]);
out_file = [path filesep fn '.mat'];

options = struct();
options.plot = job.plot;
options.overwrite = job.overwrite;
options.newfile = out_file;
options.adjust_method = job.adjust_method;

[~, f_out] = scr_segment_mean(job.segment_files, options);
out = {f_out.file};