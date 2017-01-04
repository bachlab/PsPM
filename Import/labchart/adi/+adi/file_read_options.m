classdef file_read_options < handle
    %
    %   Class:
    %   adi.file_read_options
    %
    %   Contains reading options. Currently this is for all file formats.
    
    properties %All file formats:
       %adi.file
       remove_empty_channels = true; %If true, channels without data for 
       %all records are removed.
       channels_remove = {} %TODO: On setting ensure it is a cell array
       %
       %    This should be a cell array of channels which you wish to not
       %    include when reading the file.
       
       %conversion_max_
    end
    
    properties %Mat file format only
       load_all_mat_on_start = true; %Not yet linked to the method
       %See: adi.mat_file_h
    end
    
    methods
    end
    
end

