function [sts, hist_str] = pspm_format_history_from_file(fn)
    % pspm_format_history returns the infos.history field of the PsPM file
    % given in fn in a table-like formatted string. For further details, refer
    % to <a href="matlab:help pspm_format_history">pspm_format_history</a>.
    %
    % FORMAT:
    %     [sts, hist_str] = pspm_format_history_from_file(fn)
    %
    % INPUT:
    %     fn: [string] Path to a PsPM file
    %
    % OUTPUT:
    %     hist_str: Formatted table string
    %
    % --------------------------------------------------------------------------
    % (C) 2019 Eshref Yozdemir

    [sts, infos, ~, ~] = pspm_load_data(fn);
    if sts ~= 1; return; end;
    [sts, hist_str] = pspm_format_history(infos.history);
end
