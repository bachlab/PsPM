function save_physio_file(physio_filepath, physio_data)
% Save the physio data into a .mat file with 'data' struct

data = physio_data;
% 'info' struct will be added later as per your instruction
save(physio_filepath, 'data');
end
