function sts = pspm_pull_zenodo(ID, datapath)

fprintf('Pulling data set %i from zenodo.org\n', ID);
mkdir(datapath);

zipfiles = {'Data', 'Data_pp'};
for iFiles = 1:2
    try
        url = ['https://zenodo.org/record/',num2str(ID), '/files/', zipfiles{iFiles}, '.zip'];
        zipfn = fullfile(datapath, [zipfiles{iFiles}, '.zip']);
        websave(zipfn, url);
        unzip(zipfn, datapath);
        delete(zipfn);
        newpath = fullfile(datapath, 'Data');
        if exist(newpath, 'dir')
            filelist = dir(fullfile(newpath, '*.mat'));
            oldfile = fullfile(newpath, {filelist.name});
            newfile = fullfile(datapath, {filelist.name});
            for i_fn = 1:numel(oldfile)
                movefile(oldfile{i_fn}, newfile{i_fn});
            end
            rmdir(newpath);
        end
    catch
        tempfile = [zipfn, '.html'];
        if exist(tempfile)
            delete(tempfile)
        end
        fprintf('File ''%s'' does not exist on the remote storage.\n', zipfiles{iFiles})
    end
end

sts = 1;