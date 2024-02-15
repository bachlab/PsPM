classdef (Hidden) file < handle
    %
    %   Class:
    %   adi.file
    %
    %   ***** This object should be instantiated via adi.readFile  *****
    %
    %   This is the root class for a Labchart file. It holds meta
    %   data and classes with more meta data. The channel classes can
    %   be used to actually get data.
    %
    %   See Also:
    %   adi.readFile
    
    properties
        file_path  %Full path to the file from which this class was populated.
    end
    
    properties (Hidden)
       file_h 
    end
    
    properties
        n_records
        n_channels %# of channels in the file (across all records). This may
        %be reduced if some channels have no data and the input options to 
        %the constructor specify to remove empty channels.
        records       %adi.record
        channel_specs %adi.channel These classes hold information
        %about each of the channels used.
    end
    
    properties (Dependent)
        channel_names
    end
    
    methods
        function value = get.channel_names(obj)
            temp = obj.channel_specs;
            if isempty(temp)
                value = {};
            else
                value = {temp.name};
            end
        end
    end
    
    %Constructor
    %--------------------------------
    methods
        function obj = file(file_path,file_h,sdk,in)
            %
            %   This should be created by adi.readFile
            %
            %   Inputs:
            %   -------
            %   file_path : str
            %       The path of the file (for reference).
            %   file_h : adi.file_handle
            %       A reference to the actual file.
            %   sdk: {adi.sdk, adi.h5_file_sdk, mat_file_sdk}
            %       Calls are made to the SDK to interact with the file.
            %   in : adi.file_read_options
            %       Options for reading the file.
            %
            %   See Also:
            %   adi.readFile
            
            obj.file_path = file_path;
            obj.file_h    = file_h;
            
            %Could try switching these to determine what is causing
            %the crash. Is it records or the first call to the sdk after
            %opening? Currently those 2 are the same. Flipping these 2
            %lines could disambiguate the situation.
            obj.n_records   = sdk.getNumberOfRecords(file_h);
            temp_n_channels = sdk.getNumberOfChannels(file_h);
            
            
            
            %Get record objects
            %-------------------------------------------
            temp = cell(1,obj.n_records);
            
            for iRec = 1:obj.n_records
                temp{iRec} = adi.record(file_h,sdk,iRec);
            end
            
            obj.records = [temp{:}];
            
            %Get channel objects
            %-------------------------------------------
            temp = cell(1,temp_n_channels);
            
            for iChan = 1:temp_n_channels
                temp{iChan} = adi.channel(file_h,sdk,iChan,obj.records,file_path);
            end
            
            obj.channel_specs = [temp{:}];
            
            if in.remove_empty_channels
                obj.channel_specs = obj.channel_specs.removeEmptyObjects();
            end
            
            if ~isempty(in.channels_remove)
               mask = ismember(in.channels_remove,obj.channel_names);
               if ~all(mask)
                   %Some of the channels that were requested to be removed
                   %are not in the file
                  %TODO: Print warning message 
               end
               
               mask = ismember(obj.channel_names,in.channels_remove);
               obj.channel_specs(mask) = [];
            end
            obj.n_channels = length(obj.channel_specs);
        end
    end
    methods
        function all_comments = getAllComments(obj)
           all_records = obj.records;
           all_comments = [all_records.comments]; 
        end
        function summarizeRecords(obj)
            %x Not Yet Implemented
            %For each record:
            %# of comments
            %which channels contain data
            %duration of the record
            keyboard
        end
        function chan = getChannelByName(obj,channel_name,varargin)
            %x Returns channel object for a given channel name 
            %
            %   chan = ad_sdk.adi.getChannelByName(obj,channel_name,varargin)
            %
            %   See Also:
            %   adi.channel.getChannelByName()
            
            in.case_sensitive = false;
            in.partial_match  = true;
            in.multiple_channel_rule = 'error';
            in = adi.sl.in.processVarargin(in,varargin);
            
            temp = obj.channel_specs;
            if isempty(temp)
                error('Requested channel: %s, not found',channel_name)
            end
            
            chan = temp.getChannelByName(channel_name,in);
        end
    end
    
    %TODO: These should be in their own class
    %adi.io.mat.file &
    %adi.io.h5.file
    %
    %Currently the SDK takes care of the loading, which bridges the gap
    %of knowledge of the file contents ... i.e. this file knows write
    %contents but the SDK needs to know how to read
    %File Methods
    methods
        function save_path = exportToHDF5File(obj,save_path,conversion_options)
            %x Exports contents to a HDF5 file.
            %
            %   This is similiar to the v7.3 mat files but by calling the
            %   HDF5 library functions directly we can control how the data
            %   are saved.
            %
            %   See Also:
            %   adi.record.exportToHDF5File
            %   adi.channel.exportToHDF5File
            
            if nargin < 3 || isempty(conversion_options)
                conversion_options = adi.h5_conversion_options;
            end
            
            if ~exist('save_path','var') || isempty(save_path)
               save_path = adi.sl.dir.changeFileExtension(obj.file_path,'h5');
            else
               save_path = adi.sl.dir.changeFileExtension(save_path,'h5'); 
            end
            
            if strcmp(save_path,obj.file_path)
               error('Conversion path and file path are the same') 
            end
            
            if exist(save_path,'file')
               delete(save_path); 
            end
            
            adi.sl.dir.createFolderIfNoExist(fileparts(save_path));
            
            %TODO: I'd eventually like to use the h5m library I'm writing.
            %This would change the calls to h5writteatt
            
            fobj = h5m.file.create(save_path);
            h5m.group.create(fobj,'file');
            
            %TODO: Replace with h5m library when ready
            h5writeatt(save_path,'/','version',1);
            h5writeatt(save_path,'/file','n_records',obj.n_records)
            h5writeatt(save_path,'/file','n_channels',obj.n_channels)
            
            obj.records.exportToHDF5File(fobj,save_path,conversion_options);
            obj.channel_specs.exportToHDF5File(fobj,save_path,conversion_options);
            
        end
        function save_path = exportToMatFile(obj,save_path,conversion_options)
            %
            %   Converts the file to a mat file.
            %
            %   This is rediculously SLOW. Unfortunately we don't have much
            %   control over how mat files are saved, even though the
            %   underlying HDF5 format provides tons of flexibility. To
            %   remedy this problem the HDF5 conversion code was created.
            
            if nargin < 3 || isempty(conversion_options)
                conversion_options = adi.mat_conversion_options;
            end
            
            if ~exist('save_path','var') || isempty(save_path)
               save_path = adi.sl.dir.changeFileExtension(obj.file_path,'mat');
            else
               save_path = adi.sl.dir.changeFileExtension(save_path,'mat'); 
            end
            
            
            
            if strcmp(save_path,obj.file_path)
               error('Conversion path and file path are the same') 
            end
            
            adi.sl.dir.createFolderIfNoExist(fileparts(save_path));
            
            if exist(save_path,'file')
               delete(save_path); 
            end
            
            %http://www.mathworks.com/help/matlab/ref/matfile.html
            m = matfile(save_path);
            
            m.file_version = 1;
            m.file_meta    = struct('n_records',obj.n_records,'n_channels',obj.n_channels);
            
            obj.records.exportToMatFile(m,conversion_options);
            obj.channel_specs.exportToMatFile(m,conversion_options)
            
        end
    end
    
end

