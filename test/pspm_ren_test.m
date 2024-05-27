classdef pspm_ren_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_rename function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
  end
  methods (Test)
    function invalid_input(this)
      this.verifyWarning(@()pspm_rename('fn'), 'ID:invalid_input');
      this.verifyWarning(@()pspm_rename({'fn1', 'fn2'}, {'rfn1', 'rfn2', 'rfn3'}), 'ID:invalid_input');
    end
    function char_valid_input(this)
      fn = 'testdata_ren_1.mat';
      rfn = 'rtestdata_ren_1.mat';
      channels.chantype = 'scr';
      pspm_testdata_gen(channels, 10, fn);
      [sts, newfilename] = pspm_rename(fn, rfn);
      [sts, infos, data] = pspm_load_data(newfilename);
      this.verifyTrue(strcmpi(newfilename,rfn), '''newfilename'' has not the expected value');
      this.verifyTrue(sts == 1, 'sts is negativ');
      this.verifyTrue(isfield(infos, 'rendate'), 'the field infos.rendate is missing');
      this.verifyTrue(isfield(infos, 'newname'), 'the field infos.newname is missing');
      this.verifyTrue(~exist(fn, 'file'), 'the original file has not been deleted');
      delete(rfn);
    end
  end
end