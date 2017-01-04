classdef file_writer < handle
    %
    %   Class:
    %   adi.binary.file_writer
    %
    %   This is meant to handle the binary file format which is publically
    %   available online. The binary format only supports writing one 
    %   record. There is no SDK for this format. Instead low 
    %   level read/write options are used.
    %   
    %   This was written RATHER HASTILY. It works but it isn't pretty.
    %
    %   Limitations of Binary Format:
    %   -----------------------------
    %   - no record support
    %   - no comment support
    %   - all channels are written to file at the same rate (leads to
    %   larger file sizes)
    %   - channel data are not compressed
    %
    %   Example Code:
    %   -------------
    %   file_path = 'C:\repos\test_bin.adibin';
    %   obj = adi.binary_file_writer(file_path)
    %   %FORMAT: channel name, units, sampling_rate, data
    %   obj.addNewChannel('Pressure','cmH2O',1000,1:2000);
    %   obj.addNewChannel('EUS EMG Corrected','mV',20000,1:40000);
    %   obj.addNewChannel('Stim','V',20000,1:40000);
    %   obj.write();
    %
    %   See Also:
    %   adi.binary.channel_writer
        
    %{
        %Test code:
        %----------
        file_path = 'C:\repos\test_bin.adibin';
        obj = adi.binary.file_writer(file_path)
        obj.addNewChannel('Pressure','cmH2O',1000,1:1000);
        obj.addNewChannel('EUS EMG Corrected','mV',20000,1:20000);
        obj.addNewChannel('Stim','V',20000,1:20000);
        obj.write();
    %}
    
    properties
       file_path
       date_number = now
       pre_trigger_time = 0 %pre_rigger time in seconds
       %time_channel - 1 => time included, how would that happen?
       %which one is the time channel?
       %
       channels = []
       samples_per_channel %We take the channel with the highest sampling rate
    end
    
    properties (Dependent)
       fs %Check all channels, use the highest rate
       n_channels
    end
    
    methods
        function value = get.n_channels(obj)
           value = length(obj.channels); 
        end
        function value = get.fs(obj)
           if isempty(obj.channels)
               value = NaN;
           else
               value = max([obj.channels.fs]);
           end
        end
        function value = get.samples_per_channel(obj)
           if isempty(obj.channels)
               value = NaN;
           else
               [~,I] = max([obj.channels.fs]);
               value = length(obj.channels(I).data);
           end 
        end
    end
    
    methods
        function obj = file_writer(file_path)
            %
            %   obj = adi.binary.file_writer(file_path)
            %
            %   See the examples at the top of this file
           obj.file_path = file_path; 
        end
        function addNewChannel(obj,channel_name,units,fs,data)
            %TODO: one could provide the object instead. => addChannel
            temp = adi.binary_channel_writer(channel_name,units,fs,data);
            if isempty(obj.channels)
                obj.channels = temp;
            else
                obj.channels = [obj.channels temp];
            end
        end
        function write(obj)
           %Checks:
           %- at least 1 channel is defined
           
           %{
           File Header
            The file header has the following format:
            type name description
            char magic[4] “CFWB”
            long Version 1
            double secPerTick sample period in
            seconds
            long Year 4-digit year
            long Month month 1-12
            long Day day of month 1-31
            long Hour hour 0-23
            long Minute minute 0-59
            double Seconds seconds
            double trigger pre-trigger time in
            seconds
            long NChannels number of channels
            long SamplesPer
            Channel
            number of samples per
            channel
            long TimeChannel 1 => time included
            long DataFormat 1 = double
            2 = float
            3 = short
            The file header has a size of 68 bytes. Note that the sample period (secPerTick) is the
            reciprocal of the sampling rate, so for example 0.01 represents 100 samples per second.
           %}
           
            if exist(obj.file_path,'file')
               error('Please delete existing file before running this code') 
            end
           
            fid = fopen(obj.file_path,'w'); 
           
            fwrite(fid, 'CFWB', '*char');
            fwrite(fid, 1, 'long');
            fwrite(fid, 1/obj.fs, 'double');
            
            [Y,MO,D,H,MI,S] = datevec(obj.date_number);
            
            fwrite(fid, Y, 'long'); 
            fwrite(fid, MO, 'long'); 
            fwrite(fid, D, 'long'); 
            fwrite(fid, H, 'long');
            fwrite(fid, MI, 'long'); 
            fwrite(fid, S, 'double') 
            fwrite(fid, obj.pre_trigger_time, 'double');
            fwrite(fid, length(obj.channels), 'long');
            fwrite(fid, obj.samples_per_channel, 'long');
            fwrite(fid, false, 'long');
            fwrite(fid, 2, 'long'); %Float
           
            fs_max = obj.fs;
            final_data = zeros(obj.n_channels,obj.samples_per_channel,'single');
            for iChan = 1:obj.n_channels
               cur_channel = obj.channels(iChan); 
               cur_channel.writeHeader(fid);
               if cur_channel.fs == fs_max
                   final_data(iChan,:) = single(cur_channel.data);
               else
                   temp_data = cur_channel.data;
                   if size(temp_data,1) > size(temp_data,2)
                       temp_data = temp_data';
                   end
                   n_up = fs_max/cur_channel.fs;
                   sample_and_held_data = repmat(temp_data,[n_up 1]);
                   
                   final_data(iChan,:) = single(sample_and_held_data(:));
                   
               end
            end

            fwrite(fid,final_data(:),'float32');
            
            fclose(fid);
            
        end
    end
    
end

