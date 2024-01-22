classdef (Hidden) test_SDK
    %
    %   Class:
    %   adi.test_SDK
    %
    %   Run as:
    %   adi.test_SDK.run_tests
    
    properties
    end
    
    methods (Static)
        function run_tests()
           %
           %
           %    adi.test_SDK.run_tests
           %
           %    See Also:
           
           %This is a simple write test which eventually should be moved to
           %its own function ...
           
           

        end
        function writeChannelTest()
           
            
           COPY_BLANK = false;
           %This option is temporary as I was having problems getting
           %things to work.
           
           %If true a blank Labchart file - created in Labchart 8 - is
           %copied from this repo to the destination location and a
           %openFile with read/write support is called. 
           %If false then a create_file command is issued instead.
           
           %This code might move or the function might be renamed ...
           temp_file_path = [tempname() '.adicht'];
           fprintf(2,'Temporary file being created at:\n%s',temp_file_path)
           
           file_writer = adi.createFile(temp_file_path,'copy_blank_when_new',COPY_BLANK);
           
           fw = file_writer; %Let's shorten things
           
           pres_chan = fw.addChannel(1,'pressure',1000,'cmH20');
           
           fw.startRecord();
           
           pres_chan.addSamples(1:1000);
           
           fw.stopRecord();
           
           fw.save();
           fw.close();
           
           %TODO: I think I need to delete the temp file from the disk 
        end
    end
    
end

