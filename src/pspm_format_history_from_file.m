function [sts, hist_str] = pspm_format_history_from_file(fn)
% ● Description
%   pspm_format_history returns the infos.history field of the PsPM file
%   given in fn in a table-like formatted string. For further details, refer
%   to <a href="matlab:help pspm_format_history">pspm_format_history</a>.
% ● Format
%   [sts, hist_str] = pspm_format_history_from_file(fn)
% ● Argument
%   fn: [string] Path to a PsPM file
% ● Output
%   hist_str: Formatted table string
% ● History
%   Written in 2019 by Eshref Yozdemir (UZH)

[sts, infos, ~, ~] = pspm_load_data(fn);
if sts ~= 1; return; end
[sts, hist_str] = pspm_format_history(infos.history);
end