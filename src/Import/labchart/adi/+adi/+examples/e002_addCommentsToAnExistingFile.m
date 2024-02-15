function e002_addCommentsToAnExistingFile()
%
%   Why doesn't this work???
%
%   Is there some problem with modifying old adicht files that
%   weren't created with the sdk?

file_path = 'C:\temp\example_labchart_file.adicht';

fw = adi.editFile(file_path);

%fw.addComment(1,300,'Does this actually work?')
fw.addComment(7,300,'Does this actually work?')


%Fails on this line
fw.save