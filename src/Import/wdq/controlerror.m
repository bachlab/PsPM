%This function is triggered by the event ControlError for the ReadDataqFile
%control.  You must register the event ControlError as controlerror so that it will
%call controlerror.m when the event fires.
function controlerror(varargin)   %varargin holds a variable number of arguments
disp(varargin)                    %display the error