function conversion_speed_testing
%
%
%   conversion_speed_testing
%
%
%   TODO: This should be moved to the testing package.

root_path = 'C:\Data\GSK\ChrisRaw';
root_path = 'C:\D\GSK_Data';

base_file = '140207 control cmg.';
file_path = fullfile(root_path,[base_file 'adicht']);
mat_fpath = fullfile(root_path,[base_file 'mat']);
h5_fpath  = fullfile(root_path,[base_file 'h5']);

%Converting the file to mat format
%---------------------------------
if false
tic;
adinstruments.convert(file_path,'format','mat');
toc;
end

%Summary:
%File Size : 105 MB
%Total Time: 28 seconds
%163 reads of 21 channels (105 MB total) - 7.4 s
%Remaining time is mostly writing

%Converting the file to h5 format
%--------------------------------
if false
tic;
adinstruments.convert(file_path,'format','h5');
toc;
end

if false
tic;
h = load(mat_fpath,'data__chan_3_rec_4');
toc;
end
%# Values: 91,434,500 - 730 MB in memory - on disk maybe 50 MB
%Channel read time: 2.637 seconds



if false
tic
wtf = adinstruments.readFile(h5_fpath);
toc

c = wtf.channel_specs(3);

tic
data = c.getAllData(2);
toc

tic
h = load(mat_fpath,'data__chan_3_rec_2');
toc
end

file_obj  = h5m.file.open(h5_fpath);

keyboard

group_obj = h5m.group.open(file_obj,'/data__chan_3_rec_2');




