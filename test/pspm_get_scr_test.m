classdef pspm_get_scr_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_get_scr function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  methods (Test)
    function no_transferparams(testCase)
      channel.chantype = 'scr';
      outfile = pspm_testdata_gen(channel, 10);
      exp_data = outfile.data{1}.data;
      import.data = exp_data;
      import.sr = 100;
      [sts, data] = pspm_get_scr(import);
      testCase.verifyEqual(sts, 1);
      testCase.verifyTrue(isfield(data,'data'));
      testCase.verifyTrue(~isempty(data.data));
      testCase.verifyTrue(isfield(data.header,'units'));
      testCase.verifyTrue(isfield(data.header,'sr'));
      testCase.verifyTrue(isfield(data.header,'chantype'));
      testCase.verifyEqual(data.header.sr, import.sr);
      testCase.verifyEqual(data.header.chantype, 'scr');
    end
    function struct_transferparams(testCase)
      channel.chantype = 'scr';
      outfile = pspm_testdata_gen(channel, 10);
      exp_data = outfile.data{1}.data;
      import.data = exp_data;
      import.sr = 100;
      import.transfer.Rs = 10;
      import.transfer.offset = 1;
      testCase.verifyWarning(@()pspm_get_scr(import), 'ID:no_conversion_constant');
      import.transfer.c = 2;
      [sts, data] = pspm_get_scr(import);
      testCase.verifyEqual(sts, 1);
      testCase.verifyTrue(isfield(data,'data'));
      testCase.verifyTrue(~isempty(data.data));
      testCase.verifyTrue(isfield(data.header,'units'));
      testCase.verifyTrue(isfield(data.header,'sr'));
      testCase.verifyTrue(isfield(data.header,'chantype'));
      testCase.verifyEqual(data.header.sr, import.sr);
      testCase.verifyEqual(data.header.chantype, 'scr');
      import.transfer = rmfield(import.transfer, 'Rs');
      import.transfer = rmfield(import.transfer, 'offset');
      testCase.verifyWarningFree(@()pspm_get_scr(import));
    end
    function file_transferparams(testCase)
      filename = 'transpa7875.mat';
      channel.chantype = 'scr';
      outfile = pspm_testdata_gen(channel, 10);
      exp_data = outfile.data{1}.data;
      import.data = exp_data;
      import.sr = 100;
      import.transfer = filename;
      testCase.verifyWarning(@()pspm_get_scr(import), 'ID:nonexistent_file');
      c = 2; offset = 1; Rs = 10; recsys = 'conductance';
      save(filename, 'c', 'offset', 'Rs', 'recsys');
      [sts, data] = pspm_get_scr(import);
      testCase.verifyEqual(sts, 1);
      testCase.verifyTrue(isfield(data,'data'));
      testCase.verifyTrue(~isempty(data.data));
      testCase.verifyTrue(isfield(data.header,'units'));
      testCase.verifyTrue(isfield(data.header,'sr'));
      testCase.verifyTrue(isfield(data.header,'chantype'));
      testCase.verifyEqual(data.header.sr, import.sr);
      testCase.verifyEqual(data.header.chantype, 'scr');
      delete(filename);
    end
  end
end