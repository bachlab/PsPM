function extractRecordToNewFile(source_file_path,record_id,varargin)
%
%   adi.extractRecordToNewFile(source_file_path,record_id,varargin)
%
%
%   This is a bit buggy but I think it works ...
%
%   Optional Inputs:
%   ----------------
%   new_file_path:
%   channels : cell array
%       Names of channels whose data you would like to replace
%   data : cell array
%       Each element holds the new data to write to that channel
%

%{
%Example code:
%--------------------------------------------------------------------------
source_file_path = 'F:\GSK\Rat_Expts\2014\edited\140919_J_01_Wistar_PudStim.adicht'
record_id = 7;

file_h = adi.readFile(source_file_path);

eus_chan = file_h.getChannelByName('eus'); 

raw_eus_data = eus_chan.getData(record_id,'return_object',false);

raw_eus_data = 5*raw_eus_data;

adi.extractRecordToNewFile(file_h,record_id,'channels',{eus_chan.name},'data',{raw_eus_data})
%--------------------------------------------------------------------------
%}

%TODO: Add on ability to not include channels
%TODO: Allow passing in a file reference for the source file path
%TODO: Allow passing in a time limit
%TODO: Allow channel specs objects for channels
%TODO: Allow non-cell array inputs for channels and data

in.new_file_path = '';
in.channels = {};
in.data = {};
in = adi.sl.in.processVarargin(in,varargin);

if isobject(source_file_path)
    file_h = source_file_path;
    source_file_path = file_h.file_path;
else
    file_h = adi.readFile(source_file_path);
end

if isempty(in.new_file_path)
    [root_path,file_name] = fileparts(source_file_path);
    new_file_name = sprintf('%s_record_%d.adicht',file_name,record_id);
    in.new_file_path = fullfile(root_path,new_file_name);
end

fw = adi.createFile(in.new_file_path,false);


chan_writer_handles = cell(1,file_h.n_channels);

for iChan = 1:file_h.n_channels
    cur_chan_info = file_h.channel_specs(iChan);
    temp = fw.addChannel(iChan,cur_chan_info.name,...
        cur_chan_info.fs(record_id),cur_chan_info.units{record_id});
   chan_writer_handles{iChan} = temp;
end

fw.startRecord();

for iChan = 1:file_h.n_channels
    cur_chan_writer = chan_writer_handles{iChan};
    cur_chan_reader = file_h.channel_specs(iChan);
    I = find(strcmp(in.channels,cur_chan_reader.name));
    if isempty(I)
        temp_data = cur_chan_reader.getData(record_id,'return_object',false,'leave_raw',true);
    else
        temp_data = single(in.data{I});
    end
    cur_chan_writer.addSamples(temp_data);
end

fw.stopRecord();

fw.save();
fw.close();

end