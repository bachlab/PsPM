classdef pspm_ren_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_ren function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
  end
  methods (Test)
    function invalid_input(this)
      this.verifyWarning(@()pspm_ren('fn'), 'ID:invalid_input');
      this.verifyWarning(@()pspm_ren({'fn1', 'fn2'}, {'rfn1', 'rfn2', 'rfn3'}), 'ID:invalid_input');
    end
    function char_valid_input(this)
      fn = 'testdata_ren_1.mat';
      rfn = 'rtestdata_ren_1.mat';
      channels.channeltype = 'scr';
      pspm_testdata_gen(channels, 10, fn);
      newfilename = pspm_ren(fn, rfn);
      [sts, infos, data] = pspm_load_data(newfilename);
      this.verifyTrue(strcmpi(newfilename,rfn), '''newfilename'' has not the expected value');
      this.verifyTrue(sts == 1, 'sts is negativ');
      this.verifyTrue(isfield(infos, 'rendate'), 'the field infos.rendate is missing');
      this.verifyTrue(isfield(infos, 'newname'), 'the field infos.newname is missing');
      this.verifyTrue(~exist(fn, 'file'), 'the original file has not been deleted');
      delete(rfn);
    end
    function cell_valid_input(this)
      fn{1} = 'testdata_ren_2.mat';
      fn{2} = 'rtestdata_ren_2.mat';
      rfn{1} = 'testdata_ren_3.mat';
      rfn{2} = 'rtestdata_ren_3.mat';
      channels.channeltype = 'scr';
      pspm_testdata_gen(channels, 10, fn{1});
      pspm_testdata_gen(channels, 10, fn{2});
      newfilename = pspm_ren(fn, rfn);
      for k = 1:numel(fn)
        [sts, infos, data] = pspm_load_data(newfilename{k});
        this.verifyTrue(strcmpi(newfilename{k},rfn{k}), '''newfilename'' has not the expected value');
        this.verifyTrue(sts == 1, 'sts is negativ');
        this.verifyTrue(isfield(infos, 'rendate'), 'the field infos.rendate is missing');
        this.verifyTrue(isfield(infos, 'newname'), 'the field infos.newname is missing');
        this.verifyTrue(~exist(fn{k}, 'file'), 'the original file has not been deleted');
        delete(rfn{k});
      end
    end
  end
end