function time=SONMaxTime(fh)
% SONMAXTIME returns the maximum time for data in a file
% 
% TIME=SONMAXTIME(FH)
% where FH is the SON file handle. TIME is returned in clock ticks
%
% ML/05/05

time=calllib('son32','SONMaxTime', fh);
