classdef (Hidden) channel_writer
    %
    %   Class:
    %   adi.channel_writer
    %
    %   This class facilities writing a channel to the binary file format.
    %   More details can be found in adi.binary_file_writer
    %
    %   See Also:
    %   adi.binary_file_writer
    
    
    %{
        Each channel header has the following format:
        type name description
        char Title[32] channel title
        char Units[32] units name
        double scale see text
        double offset see text
        double RangeHigh see text
        double RangeLow see text
    %}
    
    properties
        name
        units
        data
        fs
        %These are only needed for 16 bit data, although they must be in
        %the binary.
        scale  = 1
        offset = 0
    end
    
    methods
        function obj = channel_writer(channel_name,units,fs,data)
            %TODO: Check name size
            obj.name  = channel_name;
            obj.units = units;
            obj.data  = data;
            obj.fs    = fs;
        end
        function writeHeader(obj,fid)
            %pass
            
            temp_title = zeros(1,32,'uint8');
            temp_units = zeros(1,32,'uint8');
            temp_title(1:length(obj.name)) = uint8(obj.name);
            temp_units(1:length(obj.units)) = uint8(obj.units);
            
            fwrite(fid,temp_title,'*char');
            fwrite(fid,temp_units,'*char');
            fwrite(fid,obj.scale,'double');
            fwrite(fid,obj.offset,'double');
            %Range high and low ... - not currently used
            fwrite(fid,Inf,'double');
            fwrite(fid,-Inf,'double');
        end
    end
    
end

