classdef import_smi_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for import_smi, PsPM TestEnvironment
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  properties (Constant)
    funcpath = pspm_path('Import', 'smi');
    sample_file = fullfile('ImportTestData', 'smi', 'smi_data_2.txt');
    event_file = fullfile('ImportTestData', 'smi', 'smi_data_2_events.txt');
  end
  methods
    function test_import_smi_on_file(this, fn)
      import matlab.unittest.constraints.IsEqualTo
      import matlab.unittest.constraints.RelativeTolerance
      addpath(this.funcpath);
      data = import_smi(fn{:});
      rmpath(this.funcpath);
      n_userevent = 1;
      [datalines, header] = read_datafile(fn{1}, 38);
      this.verifyEqual(size(data{1}.raw, 1), numel(datalines));
      this.verifyEqual(size(data{1}.channels, 1), numel(datalines));
      % check column equality manually
      % ------------------------------------------
      cols_to_check = {'L Mapped Diameter [mm]', 'R Mapped Diameter [mm]', 'L POR X [px]', 'L POR Y [px]',...
        'R POR X [px]', 'R POR Y [px]', 'L Dia X [px]', 'L Dia Y [px]', 'R Dia X [px]', 'R Dia Y [px]',...
        'L Raw X [px]', 'L Raw Y [px]', 'R Raw X [px]', 'R Raw Y [px]'};
      manual_mat = get_manual_matrix(datalines, header, cols_to_check);
      for i = 1:numel(cols_to_check)
        col = cols_to_check{i};
        import_idx = find(strcmp(data{1}.raw_columns, col));
        this.verifyEqual(manual_mat(:, i), data{1}.raw(:, import_idx));
      end
      if numel(fn) > 1
        this.verifyEqual(size(data{1}.markers, 1), n_userevent);
        eventlines = read_eventfile(fn{2}, 23);
        % find channels
        % ------------------------------------------------------------
        timecol = data{1}.raw(:, 1);
        blink_l_chan = find(strcmp(data{1}.channels_columns, 'L Blink'));
        blink_r_chan = find(strcmp(data{1}.channels_columns, 'R Blink'));
        sacc_l_chan = find(strcmp(data{1}.channels_columns, 'L Saccade'));
        sacc_r_chan = find(strcmp(data{1}.channels_columns, 'R Saccade'));
        datacols = true(size(data{1}.channels_columns));
        datacols([blink_l_chan blink_r_chan sacc_l_chan sacc_r_chan]) = false;
        datacols_l = datacols & contains(data{1}.channels_columns, 'L ');
        datacols_r = datacols & contains(data{1}.channels_columns, 'R ');
        % go through blinks, saccades, and check if data is set to NaN
        % correctly and blink/saccade periods are 1.
        %
        % go through messages and check if their times and names are correct
        % ---------------------------------------------------------------------------
        msg_counter = 1;
        for line = eventlines
          parts = split(line, sprintf('\t'));
          if any(strcmp(parts{1}, {'Blink L', 'Blink R', 'Saccade L', 'Saccade R'}))
            tbeg = to_num(parts{4});
            tend = to_num(parts{5});
            begidx = find(timecol == tbeg);
            endidx = find(timecol == tend);
            if strcmp(parts{1}, 'Blink L')
              this.verifyTrue(all(data{1}.channels(begidx : endidx, blink_l_chan) == 1));
            elseif strcmp(parts{1}, 'Blink R')
              this.verifyTrue(all(data{1}.channels(begidx : endidx, blink_r_chan) == 1));
            elseif strcmp(parts{1}, 'Saccade L')
              this.verifyTrue(all(data{1}.channels(begidx : endidx, sacc_l_chan) == 1));
            elseif strcmp(parts{1}, 'Saccade R')
              this.verifyTrue(all(data{1}.channels(begidx : endidx, sacc_r_chan) == 1));
            end
          elseif strcmp(parts{1}, 'UserEvent')
            tbeg = int64(to_num(parts{4}));
            msg = parts{5};
            msg = msg(1 + numel('# Message: ') : end);
            this.verifyEqual(tbeg, data{1}.markers(msg_counter));
            this.verifyEqual(msg, data{1}.markerinfos.name{msg_counter});
            msg_counter = msg_counter + 1;
          end
        end
      else
        % check raw data is same as channels
        % ------------------------------------------
        for col = cols_to_check
          channels_idx = find(strcmp(data{1}.channels_columns, col{1}));
          dataraw_idx = find(strcmp(data{1}.raw_columns, col{1}));
          this.verifyEqual(data{1}.raw(:, dataraw_idx), data{1}.channels(:, channels_idx));
        end
      end
    end
  end
  methods (Test)
    function test_import_smi(this)
      this.test_import_smi_on_file({this.sample_file});
      this.test_import_smi_on_file({this.sample_file, this.event_file});
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
function [datalines, header] = read_datafile(fn, n_lines_before_data)
% Simply and manually read the datafile
fid = fopen(fn);
for i = 1:n_lines_before_data
  fgetl(fid);
end
header = fgetl(fid);
datalines = {};
tline = fgetl(fid);
while isstr(tline)
  datalines{end + 1} = tline;
  tline = fgetl(fid);
end
fclose(fid);
end
function eventlines = read_eventfile(fn, n_lines_before_data)
% Simply and manually read the eventfile
fid = fopen(fn);
for i = 1:n_lines_before_data
  fgetl(fid);
end
eventlines = {};
tline = fgetl(fid);
while isstr(tline)
  eventlines{end + 1} = tline;
  tline = fgetl(fid);
end
end
function a = to_num(str)
a = str2num(str);
if isempty(a)
  a = NaN;
end
end