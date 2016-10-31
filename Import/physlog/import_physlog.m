function [sts, out] = import_physlog(fn)
% DESCRIPTION:
%   This function was written in order to provide a scanphyslog import 
%   function in the PsPM environment. The function is kept very slim and
%   some ideas were taken from other functions (such as the event handling
%   bitand() from [1]). This function should be called by pspm_get_physlog.
%
%   [1] http://www.mathworks.com/matlabcentral/fileexchange/
%       42100-readphilipsscanphyslog-filename--channels--skipprep-
%
% FORMAT: [sts, out] = import_physlog(fn)
%
% INPUT: 
%   fn:                 (=Filename) Is the path to the according
%                       scanphyslog file.
%
% OUTPUT:      
%   sts:                Defines whether the function went through without 
%                       any problems or not. If sts == 1 there were no 
%                       errors. If sts ~= 1 there have been errors.
%   
%   out:                Is a struct() with 4 fields (record_date, 
%                       record_time, trigger, data)
%       record_date:    Contains the record date of the corresponding file.
%                       This value is read from the file header.
%
%       record_time:    Contains the record time of the corresponding file.
%                       As record_date, this value is also read out of the
%                       file header.
%       
%       trigger:        Is a struct() with three fields:
%               val:    Contains the event column converted from
%                       hex to dec. 
%               sr:     Defines the sample rate of the data contained in
%                       .trigger.
%               t:      Contains for each trigger one continuous channel
%                       with the corresponding event. The channels are:
%                       (according to philips event settings)
%
%                           .t{:,1} = Trigger ECG
%                           .t{:,2} = Trigger PPU
%                           .t{:,3} = Trigger Respiration
%                           .t{:,4} = Measurement ('slice onset')
%                           .t{:,5} = start of scan sequence (decimal 16)
%                           .t{:,6} = end of scan sequence (decimal 32)
%                           .t{:,7} = Trigger external
%                           .t{:,8} = Calibration
%                           .t{:,9} = Manual start
%                           .t{:,10} = Reference ECG Trigger
%
%                       Channel 4 apparently is only set when the scan
%                       software is patched accordingly.
%
%       data:           Is 6x1 cell structure in PsPM data like fashion. It
%                       contains: 
%                           
%                           - again a data field with all the data
%                             values of the corresponding channel in 
%                             nx1 double format. 
%                           - a header field which sepecifies sr, chantype
%                             and units of the corresponding data channel.
%     
%__________________________________________________________________________
% PsPM 3.1
% (C) 2008-2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% set output
sts = -1;
out = struct();

% read header
if exist(fn, 'file')
    fileID = fopen(fn,'rt');
else
    warning('ID:invalid_input', 'File ''%s'' not found.', fn);
    return;
end;

end_hdr = false;

out.record_date = datetime('now','Format','dd-MMM-yyyy');
out.record_time = datetime('now','Format','HH:mm:ss');

while ~end_hdr && ~feof(fileID)
    l = fgets(fileID);
    % still header?
    if isempty(regexpi(l, '^##'))
        end_hdr = true;
    else
        expr = '^##\s*\w*\s+(\d\d-\d\d-\d\d\d\d)\s+(\d\d:\d\d:\d\d)\s*$';
        [tokens] = regexp(l, expr, 'tokens');
        % is date time
        if ~isempty(tokens)
            out.record_date = datetime(tokens{1}{1},'Format','dd-MMM-yyyy', ... 
                'InputFormat','dd-MM-yyyy');
            out.record_time = datetime(tokens{1}{2},'Format','HH:mm:ss');
        end;
    end;
end;

fseek(fileID, 0, 'bof');

% specify read-in
delimiter = ' ';
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
sr = 500;

% read actual data
fileID = fopen(fn,'r');
try
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, ...
    'ReturnOnError', false, 'commentstyle', '#', 'MultipleDelimsAsOne',1);
catch
    fclose('all');
    warning('ID:invalid_input', 'Cannot read file ''%s''.', fn); return;
end;
fclose('all');

% handle triggers
% 0x0001 = 0000.0000.0000.0001 = Trigger ECG
% 0x0002 = 0000.0000.0000.0010 = Trigger PPU
% 0x0004 = 0000.0000.0000.0100 = Trigger Respiration
% 0x0008 = 0000.0000.0000.1000 = Measurement ('slice onset')
% 0x0010 = 0000.0000.0001.0000 = start of scan sequence (decimal 16)
% 0x0020 = 0000.0000.0010.0000 = end of scan sequence (decimal 32)
% 0x0040 = 0000.0000.0100.0000 = Trigger external
% 0x0080 = 0000.0000.1000.0000 = Calibration
% 0x0100 = 0000.0001.0000.0000 = Manual start
% 0x8000 = 1000.0000.0000.0000 = Reference ECG Trigger

trig = struct();
trig.val = int16(hex2dec(dataArray{:,10}));
trig.t{:,1} = double(bitand(trig.val, 1) ~= 0); % ECG
trig.t{:,2} = double(bitand(trig.val, 2) ~= 0); % PPU
trig.t{:,3} = double(bitand(trig.val, 4) ~= 0); % Respiration
trig.t{:,4} = double(bitand(trig.val, 8) ~= 0); % Measurement
trig.t{:,5} = double(bitand(trig.val, 16) ~= 0); % start of scan sequence
trig.t{:,6} = double(bitand(trig.val, 32) ~= 0); % end of scan sequence
trig.t{:,7} = double(bitand(trig.val, 64) ~= 0); % external
trig.t{:,8} = double(bitand(trig.val, 128) ~= 0); % calibration
trig.t{:,9} = double(bitand(trig.val, 512) ~= 0); % manual start
trig.t{:,10} = double(bitand(trig.val, int16(32768)) ~= 0); % reference ecg trigger

out.trigger = trig;
out.trigger.sr = sr;

% convert data into double values
for j = 1:numel(dataArray)
    dataArrayDouble(:,j) = str2double(dataArray{j});
end;

dataArrayDouble(:,sum(~isnan(dataArrayDouble))==0) = [];

% set data, unit & samplerate
for j = 1:6
    out.data{j,1}.data      = dataArrayDouble(:,j);
    out.data{j,1}.header.sr = sr;
end
for j = 1:4
    out.data{j,1}.header.chantype = 'ecg';
    out.data{j,1}.header.units    = 'volt';
end
out.data{5,1}.header.chantype = 'ppu';
out.data{5,1}.header.units    = 'volt';
out.data{6,1}.header.chantype = 'resp';
out.data{6,1}.header.units    = 'PSI';

sts = 1;

