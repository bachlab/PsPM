classdef file_viewer
    %
    %   Class:
    %   adi.file_viewer
    %
    
    properties
    end
    
    methods
        function obj = file_viewer(file_path)
            %
            %   obj = adi.file_viewer(file_path)
            %
            %   See Also:
            %   ---------
            %   adi.view
            
            %TODO:
            %---------------------------
            %- Display comments in panel
            %   - click on comment to go to comment
            %X DONE Add title to figue window
            %- manual ylims - create nice interface for this
            %- support panning
            %- build in processing support - filtering
            %- add support for adding a channel
            %- reorder channels
            %- display comments on figures
            %- allow saving viewing settings into a file for 
            %   later retrieval
            
            f = adi.readFile(file_path);
            h_figure = figure;
            
            for iChannel = 1:f.n_channels
                cur_channel_name = f.channel_names{iChannel};
                chan_obj = f.getChannelByName(cur_channel_name,'partial_match',false);
                
                %TODO: Allow array retrieval of data for multiple records
                all_chan_data = cell(1,f.n_records);
                %all_chan_data = cell(1,1);
                for iRecord = 1:f.n_records
                   if ~isnan(chan_obj.dt(iRecord))
                      all_chan_data{iRecord} = chan_obj.getData(iRecord);
                   else
                       error('This causes problems with offsets, need to fix this')
                      all_chan_data{iRecord} = []; 
                   end
                end
                
                subplot(f.n_channels,1,iChannel);
                plot([all_chan_data{:}])
                
            end
            
            set(h_figure,'name',file_path);
            sl.plot.postp.linkFigureAxes(h_figure,'x');
            
            h_axes = sl.hg.figure.getAxes(h_figure);
            
            set(h_axes,'YLimMode','manual');
            
            scroll = sl.plot.big_data.scrollbar(gca);
            
            sl.plot.postp.autoscale(h_axes)

            
            keyboard
           
        end
    end
    
end

