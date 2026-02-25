function eyes = get_eyes_list(files)

eyes = {};

% Loop through each file
for i = 1:length(files)
    % Get the filename
    filename = files{i};
    token = regexp(filename, 'recording-(eye\d+)', 'tokens', 'once');
    eyes{end+1} = token{1};
end

% Get unique list of eyes
eyes = unique(eyes);
end