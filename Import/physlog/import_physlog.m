function [sts, out] = import_physlog(fn)

% set output
sts = -1;
out = struct();

% read header
fileID = fopen(fn,'rt');
end_hdr = false;

% ## Sat 08-08-2015 12:41:09
% datetime('11-Nov-2015','Format','dd-MMM-yyyy');
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
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, ...
    'ReturnOnError', false, 'commentstyle', '#', 'MultipleDelimsAsOne',1);
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
trig.t{:,1} = bitand(trig.val, 1) ~= 0; % ECG
trig.t{:,2} = bitand(trig.val, 2) ~= 0; % PPU
trig.t{:,3} = bitand(trig.val, 4) ~= 0; % Respiration
trig.t{:,4} = bitand(trig.val, 8) ~= 0; % Measurement
trig.t{:,5} = bitand(trig.val, 16) ~= 0; % start of scan sequence
trig.t{:,6} = bitand(trig.val, 32) ~= 0; % end of scan sequence
trig.t{:,7} = bitand(trig.val, 64) ~= 0; % external
trig.t{:,8} = bitand(trig.val, 128) ~= 0; % calibration
trig.t{:,9} = bitand(trig.val, 512) ~= 0; % manual start
trig.t{:,10} = bitand(trig.val, int16(32768)) ~= 0; % reference ecg trigger

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

