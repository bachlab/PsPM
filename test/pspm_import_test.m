classdef pspm_import_test <  matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_import function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  methods (Test)
    function invalid_inputargs(this)
      datafile = 'string';
      datatype = 'smr';
      this.verifyWarning(@()pspm_import(datafile, datatype), ...
      'ID:invalid_input', 'invalid_input test 1'); %no import variable
      import = 'foo';
      this.verifyWarning(@()pspm_import(datafile, datatype, import), ...
      'ID:invalid_input', 'invalid_input test 2'); %no cell or struct import variable
      clear import;
      import{1}.type = 'scr';
      datatype = 'foo';
      this.verifyWarning(@()pspm_import(datafile, datatype, import), ...
      'ID:invalid_chantype', 'invalid_input test 3'); %invalid chantype
      datatype = 'smr';
      datafile = 5;
      this.verifyWarning(@()pspm_import(datafile, datatype, import), ...
      'ID:invalid_input', 'invalid_input test 4'); %no char filname
    end
    function invalid_import_struct(this)
      tc = pspm_get_biograph_test;
      tc.setup_path;
      tc.define_testcases;
      datafile = tc.testcases{1}.pth;
      datatype = 'biograph';
      import{1}.type = 'scr';
      import{2}.type = 'hb';
      this.verifyWarning(@()pspm_import(datafile, datatype, import), ...
      'ID:ivalid_import_struct', 'invalid_import_struct test 1'); %datatype doesn't support multiple channels
      clear import;
      import{1}.type = 'hr';
      this.verifyWarning(@()pspm_import(datafile, datatype, import), ...
      'ID:ivalid_import_struct', 'invalid_import_struct test 2'); %not allowed channel type
      datatype = 'mat';
      this.verifyWarning(@()pspm_import(datafile, datatype, import), ...
      'ID:ivalid_import_struct', 'invalid_import_struct test 3'); %no samplerate given
      datafile = 'foo';
      import{1}.sr = 100;
      this.verifyWarning(@()pspm_import(datafile, datatype, import), ...
      'ID:nonexistent_file', 'invalid_import_struct test 4');
    end
    function one_datafile(this)
      tc{1} = pspm_get_smr_test;
      tc{2} = pspm_get_labchartmat_in_test;
      tc{1}.setup_path;
      for k = 1:length(tc)
        tc{k}.define_testcases;
        options = struct();
        [sts, outfile] = pspm_import(tc{k}.testcases{1}.pth, tc{k}.datatype, tc{k}.testcases{1}.import, options);
        if ~(isprop(tc{k}, 'blocks') && tc{k}.blocks)
          this.verifyTrue(pspm_load_data(outfile{1},'none') == 1);
          delete(outfile{1});
        else
          for blk = 1:tc{k}.testcases{1}.numofblocks
            this.verifyTrue(pspm_load_data(outfile{1, blk},'none') == 1);
            delete(outfile{1, blk});
          end
        end
      end
    end
  end
end
