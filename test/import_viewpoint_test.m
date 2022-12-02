classdef import_viewpoint_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for import_viewpoint, PsPM TestEnvironment
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  properties (Constant)
    funcpath = pspm_path('Import', 'viewpoint');
    files = {...
      fullfile('ImportTestData', 'viewpoint', 'viewpoint_test_data.txt'),...
      fullfile('ImportTestData', 'viewpoint', 'viewpoint_test_data_with_events.txt')...
      };
  end
  methods
    function test_import_viewpoint_on_file(this, fn)
      import matlab.unittest.constraints.IsEqualTo
      import matlab.unittest.constraints.RelativeTolerance
      addpath(this.funcpath);
      data = import_viewpoint(fn);
      rmpath(this.funcpath);
      [datalines, eventlines, header] = read_datafile(fn, 22);
      header_parts = split(header, sprintf('\t'));
      marker_index = find(strcmp(header_parts, 'MRK'));
      this.verifyEqual(size(data{1}.dataraw, 1), numel(datalines));
      this.verifyEqual(size(data{1}.channels, 1), numel(datalines));
      % check column equality manually
      % ------------------------------------------
      cols_to_check = {'ALX', 'ALY', 'APW'};
      manual_mat = get_manual_matrix(datalines, header, cols_to_check);
      for i = 1:numel(cols_to_check)
        col = cols_to_check{i};
        import_idx = find(strcmp(data{1}.dataraw_header, col));
        this.verifyEqual(manual_mat(:, i), data{1}.dataraw(:, import_idx));
      end
      % find channels
      % ------------------------------------------------------------
      timecol = data{1}.dataraw(:, 1);
      blink_A_chan = find(strcmp(data{1}.channels_header, 'blink_A'));
      blink_B_chan = find(strcmp(data{1}.channels_header, 'blink_B'));
      sacc_A_chan = find(strcmp(data{1}.channels_header, 'saccade_A'));
      sacc_B_chan = find(strcmp(data{1}.channels_header, 'saccade_B'));
      datacols = true(size(data{1}.channels_header));
      datacols([blink_A_chan blink_B_chan sacc_A_chan sacc_B_chan]) = false;
      datacols_A = datacols & contains(data{1}.channels_header, '_A');
      datacols_B = datacols & contains(data{1}.channels_header, '_B');
      % go through blinks, saccades, and check if data is set to NaN
      % correctly and blink/saccade periods are 1.
      % ---------------------------------------------------------------------------
      for i = 1:numel(eventlines)
        line = eventlines{i};
        parts = split(line, sprintf('\t'));
        if any(strncmp(parts{3}, {'A:Blink', 'A:Saccade', 'B:Blink', 'B:Saccade'},numel(parts{3})))...
            && strcmp(parts{3}(end-2:end), 'sec')
          tend = to_num(parts{2});
          foridx = strfind(line, 'for');
          secidx = strfind(line, 'sec');
          duration = to_num(line(foridx + numel('for') : secidx - 1));
          tbeg = round(tend - duration, 4);
          begidx = find(timecol == tbeg);
          endidx = find(timecol == tend);
          if strncmp(parts{3}, 'A:Blink', numel('A:Blink'))
            this.verifyTrue(all(data{1}.channels(begidx : endidx, blink_A_chan) == 1));
          elseif strncmp(parts{3}, 'B:Blink', numel('B:Blink'))
            this.verifyTrue(all(data{1}.channels(begidx : endidx, blink_B_chan) == 1));
          elseif strncmp(parts{3}, 'A:Saccade', numel('A:Saccade'))
            this.verifyTrue(all(data{1}.channels(begidx : endidx, sacc_A_chan) == 1));
          elseif strncmp(parts{3}, 'B:Saccade', numel('B:Saccade'))
            this.verifyTrue(all(data{1}.channels(begidx : endidx, sacc_B_chan) == 1));
          end
        end
      end
      % go through messages and check if their times and names are correct
      % ---------------------------------------------------------------------------
      msg_counter = 1;
      for line = datalines
        parts = strsplit(line{1},'\t');
        if marker_index <= length(parts)
          msg = parts{marker_index};
        else
          msg = [];
        end
        if ~isempty(msg)
          tbeg = to_num(parts{2});
          this.verifyEqual(tbeg, data{1}.marker.times(msg_counter));
          this.verifyEqual(msg, data{1}.marker.name{msg_counter});
          msg_counter = msg_counter + 1;
        end
      end
    end
  end
  methods (Test)
    function test_import_viewpoint(this)
      for f = this.files
        this.test_import_viewpoint_on_file(f{1});
      end
    end
  end
end
function mat = get_manual_matrix(datalines, header, cols_to_get)
indices = [];
header_parts = split(header, sprintf('\t'));
for col = cols_to_get
  indices(end + 1) = find(strcmp(header_parts, col{1}));
end
mat = zeros(numel(datalines), numel(indices));
for i = 1:numel(datalines)
  part = split(datalines{i}, sprintf('\t'));
  for j = 1:numel(indices)
    mat(i, j) = to_num(part{indices(j)});
  end
end
end
function [datalines, eventlines, header] = read_datafile(fn, n_lines_before_data)
% Simply and manually read the datafile
fid = fopen(fn);
for i = 1:n_lines_before_data
  fgetl(fid);
end
header = fgetl(fid);
tline = fgetl(fid);
while ~strncmp(tline, '10', 2)
  tline = fgetl(fid);
end
datalines = {};
eventlines = {};
while isstr(tline)
  if strncmp(tline, '10', 2)
    datalines{end + 1} = tline;
  else
    eventlines{end + 1} = tline;
  end
  tline = fgetl(fid);
end
fclose(fid);
end
function a = to_num(str)
a = str2num(str);
if isempty(a)
  a = NaN;
end
end