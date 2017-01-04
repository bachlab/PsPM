classdef (Hidden) record < handle
    %
    %   Class:
    %   adi.record
    %
    %   Labchart Record
    %
    %   A new record is created in a file whenever settings are changed, or
    %   whenever the users stops (then starts) a recording.
    
    properties
        id        %record number (1 based)
        n_ticks   %# of samples of highest sampling rate channel
        comments  %adi.comment
        tick_dt   %The highest sampling rate of any channel in this record.
        tick_fs   %Sampling frequency, computed for convenience from tick_dt
        duration
        record_start %(Matlab time) Time in which the record started according
        %to Labchart. This is not always the time in which data collection
        %for that record started.
        
        data_start  %(Matlab time) Time at which the data that was collected 
        %during the record was collected. This may not correspond to the
        %record_start if a trigger delay was involved. This also apparently
        %changes when data are extracted from a file into another file
        
        data_start_str
        
        trigger_minus_rec_start %(seconds) How long after the record
        %started did the data start
    end
    
    properties (Hidden)
       file_h %adi.file_handle
       trigger_minus_rec_start_samples
    end
    
    methods
        function obj = record(file_h,sdk,record_id)
           %
           %
           %    Inputs:
           %    -------
           %    file_h : .file_handle, .h5_file_h, .mat_file_h
           
           
           obj.file_h = file_h;
           obj.id     = record_id;
                      
           obj.n_ticks  = sdk.getNTicksInRecord(file_h,record_id);
           
           %This is not channel specific, the channel input is not actually
           %used according to:
           %    http://forum.adi.com/viewtopic.php?f=7&t=563
           obj.tick_dt  = sdk.getTickPeriod(file_h,record_id,1);
           obj.tick_fs  = 1./obj.tick_dt;
           
           obj.duration = obj.n_ticks*obj.tick_dt;
           
           [obj.record_start,obj.data_start,obj.trigger_minus_rec_start_samples] = ...
                      sdk.getRecordStartTime(file_h,record_id,obj.tick_dt);

           obj.trigger_minus_rec_start = -1*obj.trigger_minus_rec_start_samples*obj.tick_dt;   
                  
           obj.data_start_str = datestr(obj.data_start);
           

           
           obj.comments = sdk.getAllCommentsForRecord(file_h,obj.id,obj.tick_dt,obj.trigger_minus_rec_start);
        end
    end
    
    %These conversion calls should be initiated by the file object
    methods (Hidden)
        function exportToHDF5File(objs,fobj,save_path,conversion_options)
            %
            %
            %   Make sure to also update:
            %   adi.h5_file_h
           group_name = '/record_meta';
           h5m.group.create(fobj,'record_version');
           h5writeatt(save_path,'/record_version','version',1);
           
           h5m.group.create(fobj,group_name);
           %TODO: Rewrite with h5m library
           h5writeatt(save_path,group_name,'n_ticks',[objs.n_ticks]);
           h5writeatt(save_path,group_name,'tick_dt',[objs.tick_dt]);
           h5writeatt(save_path,group_name,'record_start',[objs.record_start]);
           h5writeatt(save_path,group_name,'data_start',[objs.data_start]);
           h5writeatt(save_path,group_name,'trigger_minus_rec_start_samples',[objs.trigger_minus_rec_start_samples]);
           
           all_comments = [objs.comments];
           if ~isempty(all_comments)
              exportToHDF5File(all_comments,fobj,save_path,conversion_options)
           end
        end
        function exportToMatFile(objs,m,conversion_options)
            
           m.record_version = 1; 
           m.record_meta = struct(...
               'n_ticks',       {objs.n_ticks}, ...
               'tick_dt',       {objs.tick_dt},...
               'record_start',  {objs.record_start},...
               'data_start',    {objs.data_start},...
               'trigger_minus_rec_start_samples',{objs.trigger_minus_rec_start_samples});
           
           all_comments = [objs.comments];
           if ~isempty(all_comments)
              exportToMatFile(all_comments,m,conversion_options)
           end
        end
    end
    
end

