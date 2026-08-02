function ev_tsv = find_eye_files(candidate_paths, task_id, run_id)
%FIND_EYE_FILES Locate eye-related physio TSV files across candidate directories.
%
%   ev_tsv = FIND_EYE_FILES(candidate_paths, task_id, run_id)
%
%   Searches a list of candidate directories for a BIDS-like eye/physio TSV
%   file matching a given suffix and optional task/run entities. This is
%   typically used to locate eye-tracking physio exports stored as TSV (often
%   compressed as .tsv.gz).
%
%   The function iterates over `candidate_paths` in order and returns the
%   first matching file. If no matching file is found, returns an empty
%   string ("").
%
%   Inputs
%   ------
%   candidate_paths : cell array
%       Cell array of directory paths (char/string). Each directory is
%       checked in order. Non-existent directories are skipped.
%
%   task_id : char | string
%       Optional task label (BIDS entity value for `task-<task_id>`).
%       Pass '' or [] to disable task filtering.
%
%   run_id : char | string
%       Optional run label (BIDS entity value for `run-<run_id>`).
%       Pass '' or [] to disable run filtering.
%
%   Output
%   ------
%   ev_tsv : string
%       Full path to the matched physio TSV (or TSV.GZ) file, or "" if none
%       is found.
%
%   Search logic
%   ------------
%   - Uses a fixed filename suffix (currently 'physio.tsv.gz') to find
%     candidate files in each directory.
%   - If any candidates exist, delegates to FIND_BIDS_FILE to apply entity
%     filters (task/run) and select the best match.
%   - Stops at the first directory containing a match.
%
%   Notes
%   -----
%   - This function assumes FindFiles can locate files matching `suffix`.
%   - To support uncompressed files (e.g., 'physio.tsv'), either adjust the
%     suffix here or enhance FIND_BIDS_FILE / FindFiles usage to search both.
%
%   See also
%   --------
%   FIND_BIDS_FILE, FINDFILES

ev_tsv = "";
suffix = 'physio.tsv.gz'; 

% look in dirs
for k = 1:numel(candidate_paths)
    d = candidate_paths{k};
    if ~isfolder(d), continue; end

    % find json
    match_files = FindFiles(d, suffix).files;

    % continue if no *physioevents.tsv are present
    if isempty(match_files); continue; end
    
    % find tsv file
    [ev_tsv, ~] = find_bids_file( ...
        d, ...
        suffix, ...
        task_id, ...
        run_id, ...
        'eye' ...,
    );

    if ~isempty(ev_tsv)
        return
    end
end

end
