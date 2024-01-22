function t001_speedWritingAndWriting
%
%   adi.tests.t001_speedWritingAndWriting
%
%   STATUS:

FILE_PATH = 'C:\Data\GSK\ChrisRaw\140121 pelvic nerve recordings.adicht';
SAVE_DIR  = 'D:\Data\HDF5_test';

%Things to vary:
%- chunk size
%- compression level
%- shuffle or no shuffle

quick_test = false;
if quick_test
    pct_chunk_sizes = 0.5; %0.05:0.05:1;
    compression_levels = 1; %0:9;
    shuffle_options = false; %[true false];
    n_repeats = 1;
else
    pct_chunk_sizes    = 0.2:0.2:1;
    compression_levels = [0 1:2:9];
    shuffle_options    = [true, false];
    n_repeats = 3;
end

n_chunk_sizes = length(pct_chunk_sizes);
n_compression = length(compression_levels);
n_shuffle     = length(shuffle_options);



write_times = zeros(n_chunk_sizes,n_compression,n_shuffle,n_repeats);
file_sizes  = write_times;

[~,file_name] = fileparts(FILE_PATH);
results_path = fullfile(SAVE_DIR,[file_name '_results.mat']);

for iRepeat = 1:n_repeats
    for iChunkPct = 1:n_chunk_sizes
        for iCompression = 1:n_compression
            for iShuffle = 1:n_shuffle
                fprintf('Converting %s, %d, %d, %d, %d\n',datestr(now), iRepeat,iCompression,iChunkPct,iShuffle)
                options = adi.h5_conversion_options;
                options.chunk_length_pct = pct_chunk_sizes(iChunkPct);
                options.use_shuffle      = shuffle_options(iShuffle);
                options.deflate_value    = compression_levels(iCompression);
                t = tic;
                
                
                %            suffix = sprintf('c%d_len%d_s%d',...
                %                options.deflate_value,...
                %                options.chunk_length,...
                %                options.use_shuffle);
                
                suffix = sprintf('_c%d_p%d_s%d',iCompression,iChunkPct,iShuffle);
                
                save_path = fullfile(SAVE_DIR,[file_name suffix '.h5']);
                
                adi.convert(FILE_PATH,...
                    'save_path',save_path,...
                    'conversion_options',options);
                toc(t) %For display
                elapsed_time = toc(t);
                write_times(iChunkPct,iCompression,iShuffle,iRepeat) = elapsed_time;
                
                temp = dir(save_path);
                file_sizes(iChunkPct,iCompression,iShuffle,iRepeat) = temp.bytes;
            end
        end
    end
    save(results_path,'file_sizes','write_times','pct_chunk_sizes',...
        'compression_levels','shuffle_options');
end




