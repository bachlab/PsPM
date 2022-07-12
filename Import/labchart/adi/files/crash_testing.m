%Running this code enough will cause the program to crash
%
%   I think this suggests that if the file is somehow open in on place that
%   it shouldn't be opened again in another. 
%
%   Suggested fix: When trying to open a file, see if it is in memory.
%   Problem: I'm not sure how to hold onto the file and yet not allow the
%   object to be destroyed.

%EXPT_ID = '141010_J'; %crashes on Palidin
%EXPT_ID = '140414_C'; %might crash, needs more testing
%EXPT_ID = ''140724_C'; %can crash, takes some work

for i = 1:100
EXPT_ID = '141010_J';
c = dba.GSK.cmg_expt(EXPT_ID);
pres_data = c.getData('pres');
c2 = dba.GSK.cmg_expt(EXPT_ID);
pres_data2 = c2.getData('pres');

clear c
clear c2
clear pres_data
clear pres_data2

c = dba.GSK.cmg_expt(EXPT_ID);
pres_data = c.getData('pres');
end