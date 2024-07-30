function sts = pspm_pull_zenodo(ID, datapath)

fprintf('Pulling data set %i from zenodo.org\n', ID);
mkdir(datapath);

zipfiles = {'Data', 'Data_pp'};
for iFiles = 1:2
    url = ['https://zenodo.org/record/',num2str(ID), '/files/', zipfiles{iFiles}, '.zip'];
    zipfn = fullfile(datapath, [zipfiles{iFiles}, '.zip']);
    try
        websave(zipfn, url);
    catch
        tempfile = [zipfn, '.html'];
        if exist(tempfile)
            delete(tempfile)
        end
        fprintf('File ''%s'' does not exist on the remote storage.\n', zipfiles{iFiles})
    end
    if exist(zipfn, 'file')
        matfileno(1) = numel(dir(fullfile(datapath, '*.mat')));
        zipflag = 0;
        try
            unzip(zipfn, datapath);
        catch
            zipflag = 1;
        end
        matfileno(2) = numel(dir(fullfile(datapath, '*.mat')));
        if zipflag || diff(matfileno)==0
            warning('Error unzipping data set. This can happen for large files (> 2 GB). Please unzip manually');
        else
            delete(zipfn);
            newdir = dir(datapath);
            newpathindx = (arrayfun(@(x) x.isdir & ~ismember(x.name, {'.', '..'}), newdir));
            if any(newpathindx)
                if sum(newpathindx) > 1
                    warning('Error extracting data set.');
                    return
                else
                    newpath = fullfile(datapath, newdir(newpathindx).name);
                    filelist = dir(fullfile(newpath, '*.mat'));
                    oldfile = fullfile(newpath, {filelist.name});
                    newfile = fullfile(datapath, {filelist.name});
                    for i_fn = 1:numel(oldfile)
                        movefile(oldfile{i_fn}, newfile{i_fn});
                    end
                    rmdir(newpath);
                end
            end
        end
    end
end

sts = 1;