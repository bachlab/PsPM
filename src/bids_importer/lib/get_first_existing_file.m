function fp = get_first_existing_file(search_dirs, required_pattern)
% required_pattern example: 'physio.tsv.gz'
% Function returns first file containing BOTH:
%   - 'eye'
%   - required_pattern
%
% search order follows the order of search_dirs.

fp = "";

for k = 1:numel(search_dirs)
    d = search_dirs{k};
    if ~isfolder(d)
        continue;
    end

    % list all files in directory
    files = dir(d);
    files = files(~[files.isdir]);  % remove folders
    
    for i = 1:numel(files)
        fname = files(i).name;
        
        if contains(fname, 'eye', 'IgnoreCase', true) && ...
           contains(fname, required_pattern, 'IgnoreCase', true)
       
            fp = string(fullfile(d, fname));
            return;
        end
    end
end

end
