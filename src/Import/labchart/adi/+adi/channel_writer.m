classdef (Hidden) channel_writer < handle
    %
    %   Class:
    %   adi.channel_writer
    %
    %   This is meant to be an interface
    %
    %   adi.setChannelName(file_h,channel,channel_name)
    %   adi.sdk.setChannelInfo
    %   adi.sdk.addChannelSamples
    
    
    properties
        id
    end
    %*** These are currently not write safe - they don't get updated
    properties
        name
        fs
        units
        enabled = true
        samples_per_record
    end
    
    properties (Hidden)
        parent %adi.file_writer
    end
    
    properties (Dependent)
       duration_per_record
       last_record_duration
       current_record 
    end
    
    methods
        function value = get.duration_per_record(obj)
           value = obj.samples_per_record./obj.fs; 
        end
        function value = get.current_record(obj)
           value = obj.parent.current_record; 
        end
        function value = get.last_record_duration(obj)
           all_durations = obj.duration_per_record;
           if isempty(all_durations)
               value = NaN;
           else
               value = all_durations(end);
           end
        end
    end
    
    methods
        function obj = channel_writer(file_writer_obj,id,name,fs,units)
            %
            %
            %    adi.channel_writer(file_writer_obj,id,name,fs,units)
            
            obj.parent = file_writer_obj;
            obj.id = id;
            obj.name = name;
            obj.fs = fs;
            obj.units = units;
            
            obj.updateName();
            obj.updateInfo();
        end
        function initializeRecord(objs,record_number)
            %
            %   initializeRecord(objs,record_number)
            %
           for iObj = 1:length(objs)
               obj = objs(iObj);
               if length(obj.samples_per_record) < record_number
                   temp = obj.samples_per_record;
                   obj.samples_per_record = zeros(1,record_number);
                   obj.samples_per_record(1:length(temp)) = temp;
               end
           end
        end
        function updateName(obj)
            file_h = obj.parent.file_h;
            adi.sdk.setChannelName(file_h,obj.id,obj.name);
        end
        function updateInfo(obj)
            writer_h = obj.parent.data_writer_h;
            adi.sdk.setChannelInfo(writer_h,obj.id,1/obj.fs,obj.units,'enabled_for_record',obj.enabled);
        end
        function addSamples(obj,data)
            %
            %   addSamples(obj,data)
            
            cur_record_local = obj.current_record;
            n_samples = length(data);
            obj.samples_per_record(cur_record_local) = obj.samples_per_record(cur_record_local) + n_samples;
            
            writer_h = obj.parent.data_writer_h;
            adi.sdk.addChannelSamples(writer_h,obj.id,data)
        end
    end
    
end

