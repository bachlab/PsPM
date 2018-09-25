function pspm_combine_markers(fn)

% define new file name
[pth, newfn, ext] = fileparts(fn);
newfn = fullfile(pth, ['c', newfn, ext]);

% get wave channels
[sts, waveinfos, wavedata] = pspm_load_data(fn, 'wave');

% get marker channels
[sts, markerinfos, markerdata] = pspm_load_data(fn, 'marker');

% combine marker channels
for k = 1:numel(markerdata)
    timestamps{k, 1} = markerdata{k}.data(:);
    markervalues{k, 1} = k * ones(size(timestamps{k}));
end;

timestamps = cell2mat(timestamps);
markervalues = cell2mat(markervalues);

[timestamps, indx] = sort(timestamps);
markervalues = markervalues(indx);

% stack wave channels and new marker channel
newdata.data = wavedata;
newdata.data{end + 1, 1}.data = timestamps;
newdata.data{end}.header = markerdata{1}.header;
newdata.data{end}.markerinfo.value = markervalues;
newdata.data{end}.markerinfo.name  = cellstr(num2str(markervalues));
newdata.infos = waveinfos;

% save
pspm_load_data(newfn, newdata);