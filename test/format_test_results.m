function str = format_test_results(stats)
    durations = [stats.Duration];
    names = {stats.Name};
    success_mask = [stats.Passed];
    fail_mask = [stats.Failed];
    incomplete_mask = [stats.Incomplete];
    details = {stats.Details};

    total_test_time = sum(durations);

    str = sprintf('### Build Statistics\n');
    str = [str sprintf('* Total testing time: %.2f sec\n', total_test_time)];
    str = [str sprintf('* Number of passed checks: %d\n', sum(success_mask))];
    str = [str sprintf('* Number of failed checks: %d\n', sum(fail_mask))];
    str = [str sprintf('* Number of incomplete checks: %d\n', sum(incomplete_mask))];
    str = [str newline];
    str = [str sprintf('#### Table of Failed Checks\n')];
    str = [str format_md_table(fail_mask, details, names, durations)];
    str = [str newline];
    str = [str sprintf('#### Table of Incomplete Checks\n')];
    str = [str format_md_table(incomplete_mask, details, names, durations)];
end

function str = format_md_table(mask, details, names, durations)
    str = sprintf('| Test name | File | Line number | Duration |\n');
    str = [str sprintf('| --- | --- | --- | --- |\n')];
    indices = find(mask);
    for i = 1:numel(indices)
        idx = indices(i);
        report_whole = details{idx}.DiagnosticRecord.Report;
        report_elems = split(report_whole);
        filepath = report_elems{end - 3};
        % parts = {};
        if contains(filepath, '/')
            parts = split(filepath, '/');
        else
            parts = split(filepath, '\');
        end
        filename = parts{end};
        linenum = str2double(report_elems{end});
        str = [str, sprintf('| %s | %s | %d | %.2f |\n', names{idx}, filename, linenum, durations(idx))];
    end

end