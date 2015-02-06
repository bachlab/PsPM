function Ch=readdataq(fname)
% Read a DATAQ .wdq or .wdc file into variable "Ch" 
% Ch = ReadDataq('junk.wdq')
% fname is the path and filename of the Dataq file
% Returns structure aray:
%   Ch = 
%      SR: sample rate, Hz
%     Npt: No points per channel
%     Nch: No. channels
%   Units: EUTag - units description eg {'kN'  'V'}
%    Data: Matrix of the time history data, each channel in a column
%   Fname: File path & name
%
%   by  Steve Grobler, Sinclair Knight Merz, Perth, Australia 
%       sgrobler@skm.com.au         September 2005
%       Based on ReadDataqFile.m from www.dataq.com
%       Tested on .wdc files with 2-5 channels, 4.5-2.2 million data points
%       each channel. Use at your own risk!
%
% You must have the DATAQ ActiveX controls installed on your machine to use this program.
% You can download the ActiveX control for free at http://www.dataq.com/develop/
% It may also call the files dataqfileerror.m endoffile.m controlerror.m which
% are available with ReadDataqFile.m from www.dataq.com

% check that 1 argument is supplied
error(nargchk(1, 1, nargin))
 
figure      %this line is optional but it ensures the control is created ina new figure that can be closed later 

%Create the dataqsdk object in a figure window
readdataqfile = actxcontrol('DATAQFILE.ReadDataqFileCtrl.1');

%Register the ReadDataqFile Events
readdataqfile.registerevent({'FileError','dataqfileerror';'EndofFile','endoffile';'ControlError','controlerror'})

%Select the WinDaq file to read 
set(readdataqfile, 'FileName',fname);

%Open the WinDaq file
readdataqfile.Open

%Get the sample rate
Ch.SR=readdataqfile.SampleRate;
% Get No. channels, No. Points, EU tags, file name
Ch.Npt=readdataqfile.TotalDataPoints;
Ch.Nch=readdataqfile.ChannelCount;
Ch.Fname=fname;
for i=1:Ch.Nch
    Ch.Units(i)=cellstr(readdataqfile.EUTag(i-1));
end

% Get the data
blok=32767;                     % No. of points to read at a time - maximum is 32767
Ch.Data=NaN(Ch.Nch,Ch.Npt);     % Initialise and pre-size the variable to hold the data

if Ch.Npt<=blok  % if No. points is less than 32767, read the whole lot
    Ch.Data=readdataqfile.GetData(Ch.Npt, 1);

else             %if No. points is more than 32767, read in blocks of 32767 at a time
    for i=1:floor(Ch.Npt/blok)
        Ch.Data(:,(i-1)*blok+1:i*blok)=readdataqfile.GetData(blok, 1);
        readdataqfile.MoveTo(blok,1);
    end
    
    if rem(Ch.Npt,blok)>0   % read in whatever is left that does not form a full block of 32767 points
        Ch.Data(:,(i)*blok+1:end)=readdataqfile.GetData(rem(Ch.Npt,blok), 1);
    end
end

% Close the dataq file and the figure window
readdataqfile.Close
close;

% Re-shape so that each column represents a channel (instead of each row)
Ch.Data=Ch.Data';

 

