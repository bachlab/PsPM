classdef pspm_get_physlog_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_physlog function
  % ● Authorship
  % (C) 2015 Tobias Moser (University of Zurich)
  properties
    testcases;
    fhandle = @pspm_get_physlog
  end
  methods
    function define_testcases(this)
      % only testcase at the moment since this is the only kind of
      % data we are able to produce
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/physlog/SCANPHYSLOG20150821194530.log';
      this.testcases{1}.import{1} = struct('type', 'ecg', 'channel', 1);
      this.testcases{1}.import{2} = struct('type', 'ecg', 'channel', 2);
      this.testcases{1}.import{3} = struct('type', 'ecg', 'channel', 3);
      this.testcases{1}.import{4} = struct('type', 'ecg', 'channel', 4);
      this.testcases{1}.import{5} = struct('type', 'ppu', 'channel', 5);
      this.testcases{1}.import{6} = struct('type', 'resp', 'channel', 6);
      this.testcases{1}.import{7} = struct('type', 'marker', 'channel', 1);
      this.testcases{1}.import{8} = struct('type', 'marker', 'channel', 2);
      this.testcases{1}.import{9} = struct('type', 'marker', 'channel', 3);
      this.testcases{1}.import{10} = struct('type', 'marker', 'channel', 4);
      this.testcases{1}.import{11} = struct('type', 'marker', 'channel', 5);
      this.testcases{1}.import{12} = struct('type', 'marker', 'channel', 6);
      this.testcases{1}.import{13} = struct('type', 'marker', 'channel', 7);
      this.testcases{1}.import{14} = struct('type', 'marker', 'channel', 8);
      this.testcases{1}.import{15} = struct('type', 'marker', 'channel', 9);
      this.testcases{1}.import{16} = struct('type', 'marker', 'channel', 10);
    end
  end
  methods (Test)
    function invalid_input(this)
      % invalid path
      this.verifyWarning(@() this.fhandle(''), 'ID:invalid_input');
      % not a physlogfile
      fn = 'ImportTestData/nwdq/sc4b26.WDQ';
      this.verifyWarning(@() this.fhandle(fn, {}), 'ID:invalid_input');
      fn = 'ImportTestData/physlog/SCANPHYSLOG20150821194530.log';
      % data chan does not exist
      import{1} = struct('type', 'ecg', 'channel', 8);
      import = this.assign_chantype_number(import);
      this.verifyWarning(@() this.fhandle(fn, import), 'ID:channel_not_contained_in_file');
      % trigger chan does not exist
      import{1} = struct('type', 'marker', 'channel', 11);
      import = this.assign_chantype_number(import);
      this.verifyWarning(@() this.fhandle(fn, import), 'ID:channel_not_contained_in_file');
    end
  end
end