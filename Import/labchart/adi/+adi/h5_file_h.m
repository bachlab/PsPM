classdef (Hidden) h5_file_h < handle
    %
    %   Class:
    %   adi.h5_file_h
    
    properties
        file_path
        m %Structure containing the meta data
    end
    
    methods
        function obj = h5_file_h(file_path)
            %
            %    obj = adi.h5_file_h(file_path)
            %
            %    See Also:
            %    adi.readFile
            
            %TODO: Since we are not using this right away, we might
            %want to try and get the file path if it were evaluated
            %currently (in case it is relative)
            obj.file_path = file_path;
            %obj.m = h5m.file.open(file_path);
            
            
            %The general approach used below is to read all meta
            %information into memory now. We attempt to mimic the format
            %used when saving to a 'mat' format so that we can use the same
            %SDK interface.
            %
            %In general I really dislike this approach and will eventually
            %revert to functions that read and write structs. Also, the
            %encapsulation is currently shot and needs to be fixed (writing
            %and reading are separated)
            %==============================================================
            
            %File
            %-------------------------------------
            rf = @(attr)h5readatt(file_path,'/file',attr);
            file_struct = struct(...
                'n_records',    rf('n_records'),...
                'n_channels',   rf('n_channels'));
            
            %Records
            %--------------------------------------
            rr = @(attr)num2cell(h5readatt(file_path,'/record_meta',attr));
            
            record_struct = struct(...
                'n_ticks',      rr('n_ticks'),...
                'tick_dt',      rr('tick_dt'),...
                'record_start', rr('record_start'),...
                'data_start',   rr('data_start'),...
                'trigger_minus_rec_start_samples', rr('trigger_minus_rec_start_samples'))';
            
            %Comments
            rco = @(attr)num2cell(h5readatt(file_path,'/comments',attr));
            
            rs = @(attr,group_name)cellstr(char(h5readatt(file_path,group_name,attr)));
            
            %            temp = h5readatt(file_path,'/comments','str');
            %            comment_strs = cellstr(char(temp));
            
            comment_struct = struct(...
                'str',      rs('str','/comments'),...
                'id',       rco('id'),...
                'tick_position',rco('tick_position'),...
                'channel',  rco('channel'),...
                'record',   rco('record'),...
                'tick_dt',  rco('tick_dt'))';
            
            %Channels
            %-----------------------------
            rch1 = @(attr)h5readatt(file_path,'/channel_meta',attr);
            rch2 = @(attr)num2cell(rch1(attr));
            
            id        = rch2('id');
            n_rows    = length(id);
            
            dt        = num2cell(rch1('dt'),2);
            n_samples = num2cell(rch1('n_samples'),2);
            
            units_temp = cellstr(char(rch1('units')));

            n_records   = length(record_struct);
            units_temp2 = reshape(units_temp,[n_rows n_records]);
            units = num2cell(units_temp2,2);
            
            %dt - separate by rows
            %n_samples - " "
            %units - yikes ... - by rows, but also char
            channel_struct = struct(...
                'units',    units,...
                'name',     rs('name','/channel_meta'),...
                'id',       id,...
                'dt',       dt,...
                'n_samples',n_samples)';
            
            obj.m = struct(...
                'file_meta',        file_struct,...
                'record_meta',      record_struct,...
                'channel_meta',     channel_struct,...
                'comments',         comment_struct);
            
        end
    end
    
end

