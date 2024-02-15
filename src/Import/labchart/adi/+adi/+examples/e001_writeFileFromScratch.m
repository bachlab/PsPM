function e001_writeFileFromScratch
%
%   adi.examples.e001_writeFileFromScratch
%
% In this file I wrote many more eus samples than presssure but the
% Labchart loader didn't show all of the eus data
%
%   I'm not sure why this is occuring but the big lesson seems to be that
%   the program doesn't completely freak out if this happens
%
%   TODO: See if we can do this from a template file

N_RECORDS = 4;

%file_path = 'C:\Users\RNEL\Desktop\merge_adi_test\wtf.adicht';
file_path = 'C:\Users\Jim\Desktop\merge_adi_test\wtf.adicht';

if exist(file_path,'file')
    delete(file_path)
end

fw = adi.createFile(file_path);
%fw : adi.file_writer

%fw.addComment(1,300,'Does this actually work?')
%fw.addComment(7,300,'Does this actually work?')

pres_w = fw.addChannel(1,'Pressure',1000,'cmH2O');
eus_w  = fw.addChannel(2,'eus',200,'uV');

for iRecord = 1:2 %N_RECORDS
fw.startRecord;

%fprintf(2,'Pressure \n');
pres_w.addSamples((1:1000)/1000)
pres_w.addSamples((1:1000)/1000)
pres_w.addSamples((1:1000)/1000)
pres_w.addSamples((1:1000)/1000)
pres_w.addSamples((1:1000)/1000)
%t=0:0.001:2;  

%fprintf(2,'Onto EUS \n');
t = 0.001:0.001:1;

y=chirp(t,0,1,150); 
eus_w.addSamples(y);

%fw.addComment(1,2,'Cheeseburgers are great');

c_number = fw.addComment(iRecord,3,'Testing3','channel',1);
fw.addComment(iRecord,4,'Testing4');
fw.addComment(iRecord,5,'Testing5');

fw.stopRecord;
end



fw.save;
clear fw