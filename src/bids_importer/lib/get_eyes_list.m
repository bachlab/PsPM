function eyes = get_eyes_list(files)

eyes = {};

for i = 1:numel(files)
    filename = files{i};

    token = regexp(filename, 'recording-(eye\d+)', 'tokens', 'once');

    if ~isempty(token)
        eyes{end+1} = token{1};
    end
end

eyes = unique(eyes);
end