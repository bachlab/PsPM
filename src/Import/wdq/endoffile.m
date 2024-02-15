%This function is triggered by the event EndofFile for the ReadDataqFile
%control.  You must register the event EndofFile as endoffile so that it will
%call endoffile.m when the event fires.
function endoffile(varargin)            %varargin holds a variable number of arguments
disp('End of file has been reached!')   %display end of file message