function [ev_tsv, ev_json] = find_physio_file(physio_path, modality, task_id, run_id)

ev_json = ''; % isempt("") = 0?
ev_tsv  = '';
suffix = 'physio.tsv.gz'; 

% it could be that data exists without 'physio' folder (e.g., 'eyetracking'
% data only
if ~isfolder(physio_path); return; end

% find physio files
match_files = FindFiles(physio_path, suffix).files;

% continue if no *physioevents.tsv.gz are present
if isempty(match_files); return; end

% find tsv file
[ev_tsv, ev_json] = find_bids_file( ...
    physio_path, ...
    suffix, ...
    task_id, ...
    run_id, ...
    sprintf('recording-%s', modality) ...
); 

if ~isempty(ev_tsv) && ~isempty(ev_json)
    return
end
end
