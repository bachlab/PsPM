function [out] = pspm_cfg_run_segment_mean(job)
% Updated on 19-12-2023 by Teddy
[path, fn, ~] = fileparts([job.output_file.file_path{1} filesep job.output_file.file_name]);
out_file = [path filesep fn '.mat'];
options = struct();
options = pspm_update_struct(options, job, {'plot', 'overwrite', 'adjust_method'});
options.newfile = out_file;
[~, f_out] = pspm_segment_mean(job.segment_files, options);
if isfield(f_out, 'file')
  out = {f_out.file};
else
  out = {};
end