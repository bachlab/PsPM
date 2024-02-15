%This function is triggered by the event FileError for the ReadDataqFile
%control.  You must register the event FileError as newdata so that it will
%call newdata.m when the event fires.
function dataqfileerror(varargin)   %varargin holds a variable number of arguments
disp(varargin)                      %display the error