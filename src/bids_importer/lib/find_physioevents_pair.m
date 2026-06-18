function [ev_tsv, ev_json] = find_physioevents_pair(candidate_paths, task_id, run_id)
% base_stem example:
%   sub-999_ses-01_task-fearconditioning_physioevents
% It will match:
%   <stem>.json
%   <stem>.tsv OR <stem>.tsv.gz
% And also allow optional recording entity:
%   <stem>_recording-eye1.json, etc. (if you want) ?

ev_json = "";
ev_tsv  = "";
suffix  = 'physioevents.tsv.gz';

% look in dirs
for k = 1:numel(candidate_paths)
    d = candidate_paths{k};
    if ~isfolder(d), continue; end

    % find json
    match_files = FindFiles(d, suffix).files;

    % continue if no *physioevents.tsv are present
    if isempty(match_files); continue; end
    
    % find tsv file
    [ev_tsv, ev_json] = find_bids_file( ...
        d, ...
        suffix, ...
        task_id, ...
        run_id ...
    ); 

    if ~isempty(ev_tsv) && ~isempty(ev_json)
        return
    end
end

end
