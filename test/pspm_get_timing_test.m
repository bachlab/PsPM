classdef pspm_get_timing_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_get_timing function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)


  methods (Test)
    function invalid_inputargs(this)
      this.verifyWarning(@()pspm_get_timing('epochs'), 'ID:invalid_input', 'invalid_inputargs test 1');
      this.verifyWarning(@()pspm_get_timing('onsets', 'str'), 'ID:invalid_input', 'invalid_inputargs test 2');
      this.verifyWarning(@()pspm_get_timing('foo'), 'ID:invalid_input', 'invalid_inputargs test 3');

      intiming{1}.names = {'name1', 'name2'};
      intiming{1}.onsets = [[1 2], [3 4]];
      this.verifyWarning(@()pspm_get_timing('onsets', intiming, 'samples'), 'ID:invalid_input');

      intiming{1}.names = {'name1', 'name2'};
      intiming{1}.onsets = {[1 2]};
      this.verifyWarning(@()pspm_get_timing('onsets', intiming, 'samples'), 'ID:number_of_elements_dont_match');

      intiming{1}.names = {'name1', 'name2'};
      intiming{1}.onsets = {'string', [3 4]};
      this.verifyWarning(@()pspm_get_timing('onsets', intiming, 'samples'), 'ID:no_numeric_vector');

      intiming{1}.names = {'name1', 'name2'};
      intiming{1}.onsets = {[1 2], [3 4]};
      intiming{1}.durations = 0;
      this.verifyWarning(@()pspm_get_timing('onsets', intiming, 'samples'), 'ID:number_of_elements_dont_match');

      intiming2{1}.names = {'name1', 'name2'};
      intiming2{1}.onsets = {[-1 2], [3 4]};
      this.verifyWarning(@()pspm_get_timing('onsets', intiming2, 'samples'), 'ID:invalid_input');

      intiming2{1}.names = {'name1', 'name2'};
      intiming2{1}.onsets = {[1 2], [3.7 4]};
      this.verifyWarning(@()pspm_get_timing('onsets', intiming2, 'samples'), 'ID:invalid_input');

      clear intiming intiming2;

      fn_mat = 'testfile1243536.mat';
      epochs = [1 4.5; 3.5 5; 3 6];
      save(fn_mat, 'epochs');
      this.verifyWarning(@()pspm_get_timing('epochs', fn_mat, 'samples'), 'ID:no_integers');
      delete(fn_mat);
    end

    function case_epochs(this)
      fn_mat = 'testfile1243534.mat';
      fn_txt = 'testfile2435243.txt';

      %matfile input
      epochs = [1 4; 2 5; 3 6];
      save(fn_mat, 'epochs');
      [sts, outtiming] = pspm_get_timing('epochs', fn_mat, 'samples');
      this.verifyTrue(sts==1);
      this.verifyEqual(outtiming, epochs);
      delete(fn_mat);

      %spm input
      onsets{1} = [1 2 3]';
      onsets{2} = [4 5 6]';
      save(fn_mat, 'onsets');
      [sts, outtiming] = pspm_get_timing('epochs', fn_mat, 'samples');
      this.verifyTrue(sts==1);
      this.verifyEqual(outtiming, [onsets{1}, onsets{2}]);
      delete(fn_mat);

      %textfile input
      dlmwrite(fn_txt, epochs);
      [sts, outtiming] = pspm_get_timing('epochs', fn_txt, 'samples');
      this.verifyTrue(sts==1);
      this.verifyEqual(outtiming, epochs);
      delete(fn_txt);

      %matrix input
      [sts, outtiming] = pspm_get_timing('epochs', epochs, 'samples');
      this.verifyTrue(sts==1);
      this.verifyEqual(outtiming, epochs);
    end

    function case_onsets(this)
      fn_mat = 'testfile1243538.mat';

      %test 1
      names = {'name1', 'name2'};
      onsets = {[1 2], [3 4]};
      pmod.name = {'name3', 'name4'};
      pmod.param = {[2 3], [4 5]};
      pmod.poly = {2, 2};
      save(fn_mat, 'names', 'onsets', 'pmod');

      [sts, outtiming] = pspm_get_timing('onsets', fn_mat, 'samples');

      this.verifyTrue(sts==1);
      this.verifyEqual(outtiming.onsets, onsets);
      this.verifyEqual(outtiming.names, names);
      this.verifyTrue(isfield(outtiming, 'durations'));
      this.verifyEqual(outtiming.pmod.param, {[2 3], [4 9], [4 5], [16 25]});

      delete(fn_mat);

      %test 2
      names = {'name1', 'name2'};
      onsets = {[1 2 3], [3 4 5]};
      durations = {[3 4 5]', [5 6 7]'};
      pmod.name = {'name3', 'name4'};
      pmod.param = {[2 3 4], [4 5 6]};
      pmod.poly = {2, 1};
      save(fn_mat, 'names', 'onsets', 'pmod', 'durations');

      [sts, outtiming] = pspm_get_timing('onsets', fn_mat, 'samples');

      this.verifyTrue(sts==1);
      this.verifyEqual(outtiming.onsets, onsets);
      this.verifyEqual(outtiming.names, names);
      this.verifyTrue(isfield(outtiming, 'durations'));
      this.verifyEqual(outtiming.durations, durations);
      this.verifyEqual(outtiming.pmod.param, {[2 3 4], [4 9 16], [4 5 6]});

      delete(fn_mat);

      %test3
      names = {'Condition A'  'Condition B'};
      onsets = {[1; 2; 4; 5; 9; 10; 12; 13; 15; 18; 19; 20; 21; 23; 24; 25; 26; 27; 29; 31; 36; 37; 39; 43; 44];...
        [3; 6; 7; 8; 11; 14; 16; 17; 22; 28; 30; 32; 33; 34; 35; 38; 40; 41; 42; 45]};
      markerinfo.value = [1;1;2;1;1;2;2;2;1;1;2;1;1;2;1;2;2;1;1;1;1;2;1;1;1;1;1;2;1;2;1;2;2;2;2;1;1;2;1;2;2;2;1;1;2];
      markerinfo.name ={'Condition A','Condition A','Condition B','Condition A','Condition A',...
      'Condition B','Condition B','Condition B','Condition A','Condition A',...
      'Condition B','Condition A','Condition A','Condition B','Condition A',...
      'Condition B','Condition B','Condition A','Condition A','Condition A',...
      'Condition A','Condition B','Condition A','Condition A','Condition A',...
      'Condition A','Condition A','Condition B','Condition A','Condition B',...
      'Condition A','Condition B','Condition B','Condition B','Condition B',...
      'Condition A','Condition A','Condition B','Condition A','Condition B',...
      'Condition B','Condition B','Condition A','Condition A','Condition B'};
      markervalue = [1 2];
      fn_mat = struct('markerinfo',markerinfo,'markervalues',markervalue,'names',{names});

      [sts, outtiming] = pspm_get_timing('onsets', fn_mat, 'markervalues');

      this.verifyTrue(sts==1);
      this.verifyEqual(outtiming.onsets, onsets);
      this.verifyEqual(outtiming.names, names);
      this.verifyTrue(isfield(outtiming, 'durations'));

    end

    function case_events(this)
      intiming{1} = [1 2; 3 4; 4 6];

      [sts, outtiming] = pspm_get_timing('events', intiming);
      this.verifyTrue(sts==1);
      this.verifyEqual(outtiming, intiming);

      intiming{2} = [1; 4; 6];

      [sts, outtiming] = pspm_get_timing('events', intiming);
      this.verifyTrue(sts==1);
      this.verifyEqual(outtiming, intiming);

      intiming{3} = [1 2 4; 3 4 8; 4 6 9];
      this.verifyWarning(@()pspm_get_timing('events', intiming), 'ID:invalid_vector_size');

      intiming{3} = [1 2 ; 3 4 ; 4 6; 9 9 ];
      this.verifyWarning(@()pspm_get_timing('events', intiming), 'ID:invalid_vector_size');
    end
  end

end