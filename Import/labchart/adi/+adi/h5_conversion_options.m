classdef h5_conversion_options < handle
    %
    %   Class:
    %   adi.h5_conversion_options
    %
    %   See Also:
    %   adi.channel.exportToHDF5File
    
    properties
        max_samples_per_read = 1e8
        deflate_value = 3 %(0 - 9 for gzip
        %0 - no compression
        %9 - most compression
        %
        %   NOTE: At some point with gzip the data fail to compress any
        %   more.
        use_shuffle   = false
        chunk_length  = 1e8 %Ideally this would be linked to 
        %'max_samples_per_read' but for now this is ok
    end
    
    properties (Dependent)
       chunk_length_pct
    end
    
    methods
        function set.chunk_length_pct(obj,value)
           obj.chunk_length = round(obj.max_samples_per_read*value);   
        end
    end
    
end

