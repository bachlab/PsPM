classdef (Hidden) comment < handle
    %
    %   Class:
    %   adi.comment
    %
    %   Holds a comment.
    %
    %   NOTE: Comments can be moved after they are placed. I think
    %   this means that the comments might not be ordered by ID.
    %
    %   Also comments can be deleted, which might cause gaps in the ID
    %   numbering as well.
    
    properties
        str  %The string content of the comment
        id   %The number associated with the comment, starts at ????
        tick_position %?????????
        %TODO: Add time since start of record and experiment ...
        channel %-1 indicates all channels
        record  %(#, not a pointer)
        tick_dt
        trigger_minus_rec_start %(in seconds)
    end
    
    properties (Dependent)
        time %Time in seconds since the start of the record.
    end
    
    properties
       d1 = '------ Options -----'
       time_relative_to_file = true
    end
    
    methods
        function value = get.time(obj)
            if obj.time_relative_to_file
                value = obj.tick_position*obj.tick_dt;
            else
                value = obj.tick_position*obj.tick_dt + obj.trigger_minus_rec_start;
            end
        end
    end
    
    methods
        function obj = comment(comment_string,tick_pos,channel,comment_num,record_id,tick_dt,trigger_minus_rec_start)
            
            obj.str           = comment_string;
            obj.id            = comment_num;
            obj.tick_position = tick_pos;
            obj.channel       = channel;
            obj.record        = record_id;
            obj.tick_dt       = tick_dt;
            obj.trigger_minus_rec_start = trigger_minus_rec_start;
        end
        %         function objs = sortByID(objs)
        %
        %         end
        function changeTimeBasis(objs)
            
        end
        function pretty_print(objs)
            %
            %
            %   Example Output:
            %
            % Format
            % ID : time : str
            % Record #04
            % 002: 315.85: start pump
            % 003: 318.85: 5 ml/hr
            % 004: 1624.55: stop pump
            % 008: 1952.00: qp 1
            % 005: 2088.35: start pump
            % 006: 2782.95: stop pump
            % 007: 3011.50: qp 2
            
            all_records = [objs.record];
            [u,uI] = adi.sl.array.uniqueWithGroupIndices(all_records);
            
            n_records = length(u);
            
            fprintf('Format\n');
            fprintf('ID : time : str\n');
            
            for iRecord = 1:n_records
                cur_record_indices = uI{iRecord};
                cur_record         = u(iRecord);
                n_indices          = length(cur_record_indices);
                
                fprintf('Record #%02d\n',cur_record);
                for iComment = 1:n_indices
                    cur_obj = objs(cur_record_indices(iComment));
                    fprintf('%03d: %0.2f: %s\n',cur_obj.id,cur_obj.time,cur_obj.str);
                end
            end
        end
        function objs_out = filterByIDs(objs_in,ids_to_get,varargin)
            %
            %
            %   objs_out = filterByIDs(objs_in,ids_to_get,varargin)
            
            in.order = 'input_id';
            %Other orders: NYI
            % - object order 1st object, 2nd 3rd, etc (based on order of
            % objs_in => sort loc before returning ...
            in = adi.sl.in.processVarargin(in,varargin);
            
            all_ids = [objs_in.id];
            
            [mask,loc] = ismember(ids_to_get,all_ids);
            
            if ~all(mask)
               error('One of the requested ids is missing') 
            end
            
            objs_out = objs_in(loc);
            
            
        end
        function objs_out = filterByRecord(objs_in,record_id)
           keep_mask = [objs.record] == record_id;
           objs_out  = objs_in(keep_mask);
        end
        function objs_out = filterByTime(objs_in,time_range)
            times     = [objs_in.time];
            keep_mask = times >= time_range(1) & times <= time_range(2);
            objs_out  = objs_in(keep_mask);            
        end
        function objs_out = filterByChannel(objs_in,channel_id)
           channels  = [kept_objs.channel];
           keep_mask = channels == -1 | channels == channel_id;
           objs_out  = objs_in(keep_mask);
        end
    end
    methods
        function exportToHDF5File(objs,fobj,save_path,conversion_options)
           group_name = '/comments';
           h5m.group.create(fobj,'comment_version');
           h5writeatt(save_path,'/comment_version','version',1);
           
           h5m.group.create(fobj,group_name);
           
           %TODO: Rewrite with h5m library           
           %TODO: This needs to be fixed
           h5writeatt(save_path,group_name,'str',int16(char({objs.str})));

           h5writeatt(save_path,group_name,'id',[objs.id]);
           h5writeatt(save_path,group_name,'tick_position',[objs.tick_position]);
           h5writeatt(save_path,group_name,'channel',[objs.channel]);
           h5writeatt(save_path,group_name,'record',[objs.record]); 
           h5writeatt(save_path,group_name,'tick_dt',[objs.tick_dt]); 
        end
        function exportToMatFile(objs,m,conversion_options)
            
           m.comment_version = 1;
           
           m.comments = struct(...
                'str',              {objs.str},... 
                'id',               {objs.id},...
                'tick_position',    {objs.tick_position},...
                'channel',          {objs.channel},...
                'record',           {objs.record},...
                'tick_dt',          {objs.tick_dt});

        end
    end
    
end

