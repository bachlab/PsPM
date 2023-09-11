classdef pspm_glm_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_glm function
  % PsPM TestEnvironment
  % ● Authorship
  % (C) 2014 Linus Rüttimann (University of Zurich)
  properties (TestParameter)
    shiftbf = {0, 5};
    norm = {0, 1};
    cutoff = {0, .5, .95};
    nan_percent = {0,.25,.5,.75,.95};
  end
  methods (Test)
    function invalid_input(this)
      options = struct();
      %missing input
      this.verifyWarning(@()pspm_glm(), 'ID:invalid_input');
      model.datafile = 'infile';
      model.modelfile = 'outfile';
      model.timing = 'foo';
      this.verifyWarning(@()pspm_glm(model, options), 'ID:invalid_input');
      %faulty input
      model.timeunits = 'foo';
      this.verifyWarning(@()pspm_glm(model, options), 'ID:invalid_input');
      model.timeunits = 'seconds';
      model.timing = zeros(10,2);
      this.verifyWarning(@()pspm_glm(model, options), 'ID:invalid_input');
      model.timing = struct('names', {{'foo'}}, 'onsets', {{1}});
      %modelspec
      model.modelspec = 'foo';
      this.verifyWarning(@()pspm_glm(model, options), 'ID:invalid_input');
      model.modelspec = 'scr';
      %channel
      model.channel = 'foo';
      this.verifyWarning(@()pspm_glm(model, options), 'ID:invalid_input');
      model.channel = 1;
      %normalisation
      model.norm = 'no';
      this.verifyWarning(@()pspm_glm(model, options), 'ID:invalid_input');
      model.norm = 1;
      %files
      model.datafile = {'f1', 'f2'};
      model.timing = 'f3';
      this.verifyWarning(@()pspm_glm(model, options), 'ID:number_of_elements_dont_match');
      %generate testdata
      pspm_tf = 'testfile489423.mat';
      mcond_tf = 'testfile687514.mat';
      names = {'condition a', 'condition b'};
      onsets = {[1 2 3], [4 5 6]};
      save(mcond_tf, 'names', 'onsets');
      clear names onsets
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'marker';
      pspm_testdata_gen(channels, 10, pspm_tf);
      model.timing = mcond_tf;
      model.datafile = pspm_tf;
      %filter
      model.filter.direction = 'uni';
      model.filter.sr = 200;
      model.filter.lpfreq = 100;
      model.filter.lporder = 1;
      model.filter.hpfreq = 20;
      model.filter.hporder = 1;
      model.filter.down = 'bla';
      this.verifyWarning(@()pspm_glm(model, options), 'ID:invalid_input'); %filt.down is not numeric
      model.filter.down = 50;
      %basis functions
      model.bf.fhandle = 'foohandle';
      this.verifyWarning(@()pspm_glm(model, options), 'ID:invalid_fhandle');
      model = rmfield(model,'bf');
      %missing values
      model.missing.foo = [];
      this.verifyWarning(@()pspm_glm(model, options), 'ID:invalid_input');
      model = rmfield(model, 'missing');
      model.missing = {'n1','n2'};
      this.verifyWarning(@()pspm_glm(model, options), 'ID:number_of_elements_dont_match');
      model.missing = ones(5,2);
      %nuisance regressors
      model.nuisance.foo = [];
      this.verifyWarning(@()pspm_glm(model, options), 'ID:invalid_input');
      model = rmfield(model, 'nuisance');
      model.nuisance = {'n1','n2'};
      this.verifyWarning(@()pspm_glm(model, options), 'ID:number_of_elements_dont_match');
      nuisance_tf = 'testdatafile867643.mat';
      model.nuisance = nuisance_tf;
      foovar = 3;
      save(nuisance_tf, 'foovar');
      this.verifyWarning(@()pspm_glm(model, options), 'ID:invalid_file_type');
      R = ones(10,2);
      save(nuisance_tf, 'R');
      this.verifyWarning(@()pspm_glm(model, options), 'ID:number_of_elements_dont_match');
      %delete testdata
      delete(pspm_tf);
      delete(mcond_tf);
      delete(nuisance_tf);
    end
    function glm = test1(this, shiftbf, norm)
      %test pspm_glm with only kronecker delta function as basis
      %function
      cond1_pmod2 = 1;
      cond1_pmod1 = 1;
      cond1 = 1;
      offset = 0;
      sr = 100;
      duration = 10+shiftbf;
      model.norm = norm;
      model.modelfile = 'testdatafile987654.mat';
      model.datafile = 'testdatafile897654.mat';
      model.timeunits = 'seconds';
      model.filter = struct('lpfreq', 'none', 'lporder', 1,  ...
        'hpfreq', 'none', 'hporder', 1, ...
        'down', sr, ...
        'direction', 'uni');
      model.bf.fhandle = @(td) pspm_glm_test.kron_delta(td,duration,0,0,shiftbf);
      %test 1
      model.timing.names{1} = 'condition a';
      model.timing.onsets{1} = [1 2 3 5 7]';
      Y = pspm_glm_test.testdata_gen(model.timing.onsets{1}, cond1, offset, 0,  sr, duration);
      pspm_glm_test.save_datafile(Y, sr, duration, model.datafile);
      % correct out shiftbf
      model.timing.onsets{1} = model.timing.onsets{1} + shiftbf;
      expected = [cond1 offset]';
      if norm
        expected = expected * ((1-mean(Y))/std(Y));
      end
      glm{1} = this.test_stats(model, expected, 'Test 1.1.1.1.1.1 (no pmods)');
      %delete testdata
      delete(model.datafile);
      delete(model.modelfile);
      %test 2
      model.timing.pmod.name{1} = 'pmod 1';
      pmod1 = [-2 -1 0 1 2];
      model.timing.pmod.param{1} = (pmod1-mean(pmod1))/std(pmod1);
      model.timing.onsets{1} = [1 2 3 5 7]';
      Y = Y + pspm_glm_test.testdata_gen(model.timing.onsets{1}, cond1_pmod1 *  model.timing.pmod.param{1} , 0, 0,  sr, duration);
      pspm_glm_test.save_datafile(Y, sr, duration, model.datafile);
      % correct out shiftbf
      model.timing.onsets{1} = model.timing.onsets{1} + shiftbf;
      expected = [cond1 cond1_pmod1 offset]';
      if norm
        expected = expected * ((1-mean(Y))/std(Y));
      end
      glm{2} = this.test_stats(model, expected, 'Test 1.1.1.1.1.2 (one orthogonal pmod)');
      %delete testdata
      delete(model.datafile);
      delete(model.modelfile);
      %test 3
      model.timing.pmod.name{2} = 'pmod 2';
      pmod2 = [1 2 0 2 1];
      model.timing.pmod.param{2} = (pmod2-mean(pmod2))/std(pmod2); %orthogonal to param 1
      model.timing.onsets{1} = [1 2 3 5 7]';
      Y = Y + pspm_glm_test.testdata_gen(model.timing.onsets{1}, cond1_pmod2 *  model.timing.pmod.param{2} , 0, 0,  sr, duration);
      pspm_glm_test.save_datafile(Y, sr, duration, model.datafile);
      % correct out shiftbf
      model.timing.onsets{1} = model.timing.onsets{1} + shiftbf;
      expected = [cond1 cond1_pmod1 cond1_pmod2 offset]';
      if norm
        expected = expected * ((1-mean(Y))/std(Y));
      end
      glm{3} = this.test_stats(model, expected, 'Test 1.1.1.1.1.3 (two orthogonal pmods)');
      %delete testdata
      delete(model.datafile);
      delete(model.modelfile);
    end
    function glm = test2(this, shiftbf, norm)
      %test pspm_glm with only kronecker delta function as basis
      %function
      cond2_pmod2 = 1;
      cond2_pmod1 = 1;
      cond1_pmod1 = 1;
      cond2 = 1;
      cond1 = 1;
      offset = 0;
      sr = 100;
      duration = 10+shiftbf;
      model.norm = norm;
      model.modelfile = 'testdatafile987654.mat';
      model.datafile = 'testdatafile897654.mat';
      model.timeunits = 'seconds';
      model.filter = struct('lpfreq', 'none', 'lporder', 1,  ...
        'hpfreq', 'none', 'hporder', 1, ...
        'down', sr, ...
        'direction', 'uni');
      model.bf.fhandle = @(td) pspm_glm_test.kron_delta(td,duration,0,0,shiftbf);
      %test 1
      model.timing.names{1} = 'condition a';
      model.timing.onsets{1} = [1 2 3 5 7]';
      model.timing.names{2} = 'condition b';
      model.timing.onsets{2} = [1.5 2.5 4 8]';
      Y = pspm_glm_test.testdata_gen(model.timing.onsets{1}, cond1, offset, 0,  sr, duration) + pspm_glm_test.testdata_gen(model.timing.onsets{2}, cond2, 0, 0,  sr, duration);
      pspm_glm_test.save_datafile(Y, sr, duration, model.datafile);
      % correct out shiftbf
      model.timing.onsets{1} = model.timing.onsets{1} + shiftbf;
      model.timing.onsets{2} = model.timing.onsets{2} + shiftbf;
      expected = [cond1 cond2 offset]';
      if norm
        expected = expected * ((1-mean(Y))/std(Y));
      end
      glm{1} = this.test_stats(model, expected, 'Test 1.1.1.1.2.1 (two cond, no pmods)');
      %delete testdata
      delete(model.datafile);
      delete(model.modelfile);
      %test 2
      model.timing.pmod(2).name{1} = 'pmod 2.1';
      pmod = [-1 0 0 1];
      model.timing.pmod(2).param{1} = (pmod-mean(pmod))/std(pmod);
      model.timing.onsets{2} = [1.5 2.5 4 8]';
      model.timing.onsets{1} = [1 2 3 5 7]';
      Y = Y + pspm_glm_test.testdata_gen(model.timing.onsets{2}, cond2_pmod1 *  model.timing.pmod(2).param{1} , 0, 0,  sr, duration);
      pspm_glm_test.save_datafile(Y, sr, duration, model.datafile);
      % correct out shiftbf
      model.timing.onsets{1} = model.timing.onsets{1} + shiftbf;
      model.timing.onsets{2} = model.timing.onsets{2} + shiftbf;
      expected = [cond1 cond2 cond2_pmod1 offset]';
      if norm
        expected = expected * ((1-mean(Y))/std(Y));
      end
      glm{2} = this.test_stats(model, expected, 'Test 1.1.1.1.2.2 (2 cond, 1. cond: no pmod, 2. cond: 1 pmod)');
      %delete testdata
      delete(model.datafile);
      delete(model.modelfile);
      %test 3
      model.timing.pmod(1).name{1} = 'pmod 1.1';
      pmod2 = [1 2 0 2 1];
      model.timing.pmod(1).param{1} = (pmod2-mean(pmod2))/std(pmod2); %orthogonal to param 1
      model.timing.onsets{2} = [1.5 2.5 4 8]';
      model.timing.onsets{1} = [1 2 3 5 7]';
      Y = Y + pspm_glm_test.testdata_gen(model.timing.onsets{1}, cond1_pmod1 *  model.timing.pmod(1).param{1} , 0, 0,  sr, duration);
      model.timing.pmod(2).name{2} = 'pmod 2.2';
      pmod = [1 -2 2 1];
      model.timing.pmod(2).param{2} = (pmod-mean(pmod))/std(pmod);
      Y = Y + pspm_glm_test.testdata_gen(model.timing.onsets{2}, cond2_pmod2 *  model.timing.pmod(2).param{2} , 0, 0,  sr, duration);
      pspm_glm_test.save_datafile(Y, sr, duration, model.datafile);
      % correct out shiftbf
      model.timing.onsets{1} = model.timing.onsets{1} + shiftbf;
      model.timing.onsets{2} = model.timing.onsets{2} + shiftbf;
      expected = [cond1, cond1_pmod1, cond2, cond2_pmod1, cond2_pmod2, offset]';
      if norm
        expected = expected * ((1-mean(Y))/std(Y));
      end
      glm{3} = this.test_stats(model, expected, 'Test 1.1.1.1.2.3 (2 cond, 1. cond: 1 pmod, 2. cond: 2 pmod)');
      %delete testdata
      delete(model.datafile);
      delete(model.modelfile);
    end
    function glm = test3(this, shiftbf, norm)
      %test pspm_glm with only kronecker delta function as basis
      %function
      nuis2 = 1;
      nuis1 = 1;
      cond1 = 1;
      offset = 0;
      sr = 100;
      duration = 10+shiftbf;
      model.norm = norm;
      model.modelfile = 'testdatafile987654.mat';
      model.datafile = 'testdatafile897654.mat';
      model.timeunits = 'seconds';
      model.filter = struct('lpfreq', 'none', 'lporder', 1,  ...
        'hpfreq', 'none', 'hporder', 1, ...
        'down', sr, ...
        'direction', 'uni');
      model.bf.fhandle = @(td) pspm_glm_test.kron_delta(td,duration,0,0,shiftbf);
      %test 1
      model.timing.names{1} = 'condition a';
      model.timing.onsets{1} = [1 2 3 5 7]';
      Y = pspm_glm_test.testdata_gen(model.timing.onsets{1}, cond1, offset, 0,  sr, duration);
      model.nuisance = 'testdatafile8798.mat';
      t = (sr^-1:sr^-1:duration)';
      R = [sin(2*pi*t),cos(2*pi*t)];
      save(model.nuisance,'R')
      Y = Y + nuis1 * R(:,1);
      Y = Y + nuis2 * R(:,2);
      pspm_glm_test.save_datafile(Y, sr, duration, model.datafile);
      % correct out shiftbf
      model.timing.onsets{1} = model.timing.onsets{1} + shiftbf;
      expected = [cond1 nuis1 nuis2 offset]';
      if norm
        expected = expected * ((1-mean(Y))/std(Y));
      end
      glm{1} = this.test_stats(model, expected, 'Test 1.1.1.2 (1 cond, 2 nuisance)');
      %delete testdata
      delete(model.datafile);
      delete(model.modelfile);
      delete(model.nuisance);
    end
    function glm = test4(this, shiftbf, norm)
      %test pspm_glm with only kronecker delta function as basis
      %function
      cond1 = 1;
      offset2 = 0;
      offset1 = 0;
      sr = 100;
      duration = 10+ shiftbf;
      model.norm = norm;
      model.modelfile = 'testdatafile987654.mat';
      model.datafile{1} = 'testdatafile897654.mat';
      model.datafile{2} = 'testdatafile897655.mat';
      model.filter = struct('lpfreq', 'none', 'lporder', 1,  ...
        'hpfreq', 'none', 'hporder', 1, ...
        'down', sr, ...
        'direction', 'uni');
      model.bf.fhandle = @(td) pspm_glm_test.kron_delta(td,duration,0,0,shiftbf);
      model.timing{1}.names{1} = 'condition a';
      model.timing{1}.onsets{1} = [1 2 3 5 7]';
      model.timing{2}.names{1} = 'condition a';
      model.timing{2}.onsets{1} = [1 2 3 5 7]';
      Y1 = pspm_glm_test.testdata_gen(model.timing{1}.onsets{1}, cond1, offset1, 0,  sr, duration);
      pspm_glm_test.save_datafile(Y1, sr, duration, model.datafile{1}, model.timing{1}.onsets{1});
      Y2 = pspm_glm_test.testdata_gen(model.timing{2}.onsets{1}, cond1, offset2, 0,  sr, duration);
      pspm_glm_test.save_datafile(Y2, sr, duration, model.datafile{2} , model.timing{2}.onsets{1});
      % correct out shiftbf
      model.timing{1}.onsets{1} = model.timing{1}.onsets{1} + shiftbf;
      model.timing{2}.onsets{1} = model.timing{2}.onsets{1} + shiftbf;
      %test 1
      model.timeunits = 'seconds';
      expected = [cond1 offset1 offset2]';
      if norm
        expected = expected * ((1-mean([Y1,Y2]))/std([Y1,Y2]));
      end
      glm{1} = this.test_stats(model, expected, 'Test 1.1.2.1 (2 sessions, 1 cond, tu: seconds)');
      %delete testdata
      delete(model.modelfile);
      %test 2
      model.timeunits = 'samples';
      model.timing{1}.onsets{1} = sr * model.timing{1}.onsets{1};
      model.timing{2}.onsets{1} = sr * model.timing{2}.onsets{1};
      expected = [cond1 offset1 offset2]';
      if norm
        expected = expected * ((1-mean([Y1,Y2]))/std([Y1,Y2]));
      end
      glm{2} = this.test_stats(model, expected, 'Test 1.1.2.2 (2 sessions, 1 cond, tu: samples)');
      %delete testdata
      delete(model.modelfile);
      %test 3
      model.timeunits = 'markers';
      model.timing{1}.onsets{1} = [1 2 3 4 5];
      model.timing{2}.onsets{1} = [1 2 3 4 5];
      expected = [cond1 offset1 offset2]';
      if norm
        expected = expected * ((1-mean([Y1,Y2]))/std([Y1,Y2]));
      end
      glm{3} = this.test_stats(model, expected, 'Test 1.1.2.3 (2 sessions, 1 cond, tu: markers)');
      %delete testdata
      delete(model.datafile{1});
      delete(model.datafile{2});
      delete(model.modelfile);
    end
    function glm = test5(this, shiftbf, norm)
      %test pspm_glm with only kronecker delta function as basis
      %function
      bf2 = 1;
      bf1 = 1;
      offset = 0;
      sr = 100;
      duration = 10 + shiftbf;
      model.norm = norm;
      model.modelfile = 'testdatafile987654.mat';
      model.datafile = 'testdatafile897654.mat';
      model.timeunits = 'seconds';
      model.filter = struct('lpfreq', 'none', 'lporder', 1,  ...
        'hpfreq', 'none', 'hporder', 1, ...
        'down', sr, ...
        'direction', 'uni');
      model.bf.fhandle = @(td) pspm_glm_test.kron_delta(td,duration,[0 1],0,shiftbf);
      model.timing.names{1} = 'condition a';
      model.timing.onsets{1} = [1 3 5 7]';
      Y = pspm_glm_test.testdata_gen(model.timing.onsets{1}, bf1, offset, 0,  sr, duration) + pspm_glm_test.testdata_gen(model.timing.onsets{1} + 1, bf2, 0, 0,  sr, duration);
      %test 1
      pspm_glm_test.save_datafile(Y, sr, duration, model.datafile);
      % correct out shiftbf
      model.timing.onsets{1} = model.timing.onsets{1}+shiftbf;
      expected = [bf1 bf2 offset]';
      if norm
        expected = expected * ((1-mean(Y))/std(Y));
      end
      glm{1} = this.test_stats(model, expected, 'Test 1.2.1 (2 bf)');
      %delete testdata
      delete(model.modelfile);
      %test 2
      model.missing = [1.5 2.5; 4.2 5.2];
      model.timing.onsets{1} = [1 3 5 7]';
      pspm_glm_test.save_datafile(Y, sr, duration, model.datafile);
      % correct out shiftbf
      model.timing.onsets{1} = model.timing.onsets{1}+shiftbf;
      expected = [bf1 bf2 offset]';
      if norm
        expected = expected * ((1-mean(Y))/std(Y));
      end
      glm{2} = this.test_stats(model, expected, 'Test 1.2.2 (2bf, missing)');
      %delete testdata
      delete(model.datafile);
      delete(model.modelfile);
    end
    function glm = test6(this)
      model.modelfile = 'testdatafile987654.mat';
      model.datafile{1} = 'testdatafile897654.mat';
      model.datafile{2} = 'testdatafile897655.mat';
      model.timing{1} = 'testdatafile8597657.mat';
      model.timing{2} = 'testdatafile8597658.mat';
      model.timeunits = 'seconds';
      model.filter = struct('lpfreq', 50, 'lporder', 1,  ...
        'hpfreq', 10, 'hporder', 1, ...
        'down', 100, ...
        'direction', 'uni');
      timing1.names{1} = 'cond a';
      timing1.onsets{1} = [1 3 5 7]';
      timing1.duration{1} = 0.1;
      timing1.pmod(1).name{1} = 'pmod a1';
      timing1.pmod(1).param{1} = [2 1 5 7]';
      timing1.pmod(1).poly{1} = 2;
      timing1.pmod(1).name{2} = 'pmod a2';
      timing1.pmod(1).param{2} = [1 1.5 9 8]';
      timing1.pmod(1).poly{2} = 3;
      timing1.names{2} = 'cond b';
      timing1.onsets{2} = [1.5 3.1 4 5.6 7 9]';
      timing2.names{1} = 'cond a';
      timing2.onsets{1} = [1 3 5 7]';
      timing2.duration{1} = 0.1;
      timing2.pmod(1).name{1} = 'pmod a1';
      timing2.pmod(1).param{1} = [2 1 5 7]';
      timing2.pmod(1).poly{1} = 2;
      timing2.pmod(1).name{2} = 'pmod a2';
      timing2.pmod(1).param{2} = [1 1.5 9 8]';
      timing2.pmod(1).poly{2} = 3;
      timing2.names{2} = 'cond b';
      timing2.onsets{2} = [1 4 6 7.5 8]';
      save(model.timing{1}, '-struct', 'timing1');
      save(model.timing{2}, '-struct', 'timing2');
      Y1 = rand(200*10,1);
      pspm_glm_test.save_datafile(Y1, 200, 10, model.datafile{1});
      Y2 = rand(200*10,1);
      pspm_glm_test.save_datafile(Y2, 200, 10, model.datafile{2});
      glm = pspm_glm(model, struct());
      %tests
      exptected_number_of_stats = 16;
      this.verifyEqual(length(glm.stats),exptected_number_of_stats, sprintf('test6: glm.stats does not have the expected number (%i) of elements', exptected_number_of_stats));
      this.verifyEqual(length(glm.names),exptected_number_of_stats, sprintf('test6: glm.names does not have the same number of elements as glm.stats'));
      %delete files
      delete(model.modelfile);
      delete(model.datafile{1});
      delete(model.datafile{2});
      delete(model.timing{1});
      delete(model.timing{2});
    end
  end
  methods(Test, ParameterCombination='exhaustive')
    function glm = test_extract_missing(this, cutoff, nan_percent)
      bf1 = 1;
      offset = 0;
      sr = 100;
      duration = 200;
      segment_length = 10-1/sr;
      model.modelfile = 'test_extract_missing_model.mat';
      model.datafile = 'test_extract_missing_data.mat';
      model.timeunits = 'seconds';
      model.filter = struct(...
        'lpfreq', 'none', 'lporder', 1,  ...
        'hpfreq', 'none', 'hporder', 1, ...
        'down', sr,'direction', 'uni');
      model.bf.fhandle = @(td) pspm_glm_test.kron_delta(td,duration,[0 1],0,0);
      model.timing.names{1} = 'cond_a';
      model.timing.onsets{1} = [10 40 70 100]';
      model.timing.names{2} = 'cond_b';
      model.timing.onsets{2} = [20 50 80 110]';
      model.timing.names{3} = 'cond_c';
      model.timing.onsets{3} = [30 60 90 120]';
      Y1 = pspm_glm_test.testdata_gen(model.timing.onsets{1}, bf1, offset, 0,  sr, duration);
      Y2 = pspm_glm_test.testdata_gen(model.timing.onsets{2}, bf1, offset, 0,  sr, duration);
      Y3 = pspm_glm_test.testdata_gen(model.timing.onsets{3}, bf1, offset, 0,  sr, duration);
      Y =Y1 + Y2 +Y3;
      if nan_percent >0
        nr_samples = size(Y,1);
        nr_nan_toadd = round(nan_percent *  nr_samples);
        idx_replace = randsample(nr_samples, nr_nan_toadd);
        Y(idx_replace) = NaN;
        new_nan_percent = sum(isnan(Y))/nr_samples * 100;
      else
        new_nan_percent = nan_percent * 100;
      end
      %t
      pspm_glm_test.save_datafile(Y, sr, duration, model.datafile);
      % test
      glm = pspm_glm(model, struct('exclude_missing', struct('segment_length',segment_length,'cutoff',cutoff)));
      exptected_number_of_conditions = 3;
      this.verifyEqual(length(glm.stats_missing),exptected_number_of_conditions, sprintf('test_extract_missing: glm.stats_missing does not have the expected number (%i) of elements', exptected_number_of_conditions));
      this.verifyEqual(length(glm.stats_exclude),exptected_number_of_conditions, sprintf('test_extract_missing: glm.stats_exclude does not have the expected number (%i) of elements', exptected_number_of_conditions));
      this.verifyTrue((abs(mean(glm.stats_missing)-new_nan_percent) < 1), sprintf('test_extract_missing: mean of glm.stats_missing (%i) does not correspond to expected nan_percentage (%i)', mean(glm.stats_missing), new_nan_percent));
      check_values = glm.stats_missing > cutoff;
      this.verifyTrue(all(glm.stats_exclude == check_values), sprintf('test_extract_missing: glm.stats_exclude does not exclude the right conditions'));
      % clean up
      delete(model.datafile);
      delete(model.modelfile);
    end
  end
  methods
    %this function does the actual tests for test 1 to 5
    function glm = test_stats(this, model, expected_stats, test_name)
      % update known files
      rehash;
      %call pspm_glm
      options = struct('marker_chan_num', 'marker');
      glm = pspm_glm(model, options);
      %check if output is equal the timing
      actual = glm.stats;
      this.verifyEqual(length(actual),length(expected_stats), sprintf('%s: glm.stats does not have the expected number (%i) of elements', test_name, length(expected_stats)));
      this.verifyEqual(length(glm.names),length(actual), sprintf('%s: glm.names does not have the same number of elements as glm.stats', test_name));
      this.report(actual, expected_stats, glm.names, test_name);
      err = norm(actual - expected_stats)/norm(expected_stats);
      tol = 0.01;
      this.verifyLessThanOrEqual(err,0.01, sprintf('%s: The relative error is greater than %2.2f%%', test_name, tol*100));
    end
  end
  methods (Static)
    %kronecker delta basis function
    function [y, x] = kron_delta(td,d,tau, zero_padding, shift)
      % td: sample interval
      % d: duration
      % tau: amount of columns (amount of rows: floor(d/td)
      if nargin < 5, shift = 0; end
      if nargin < 4, zero_padding = 0; end
      if nargin < 3, tau = 0; end
      if nargin < 2, d = 10; end
      y = zeros(floor(d/td)+1,length(tau));
      x = -shift:td:d-shift;
      for i=1:length(tau)
        y(floor(tau(i)/td)+1,i) = 1;
      end
      if zero_padding == 1
        y = [zeros(floor(d/td),1);y];
      end
    end
    %returns a signal vector with signal(onsets) = scal + offset and
    %signal = offset everywhere else
    function signal = testdata_gen(onsets, scal, offset,  onsets_duration, sr, duration)
      if nargin < 6, duration = 10; end
      if nargin < 5, sr = 100; end
      if nargin < 4
        onsets_duration = zeros(size(onsets));
      elseif isscalar(onsets_duration)
        onsets_duration = onsets_duration .* ones(size(onsets));
      end
      if nargin < 3, offset = 0; end
      if nargin < 2
        scal = ones(size(onsets));
      elseif isscalar(scal)
        scal = scal .* ones(size(onsets));
      end
      signal = zeros(sr*duration,1);
      for i = 1:length(onsets)
        signal(floor(onsets(i)*sr):floor((onsets(i)+onsets_duration(i))*sr)) = scal(i);
      end
      signal = signal + offset;
    end
    %saves a datavector to a file
    function save_datafile(Y, sr, duration, fn, onsets)
      infos.duration = duration;
      data{1}.data = Y;
      data{1}.header.sr = sr;
      data{1}.header.chantype = 'scr';
      data{1}.header.units = 'unknown';
      if nargin > 4
        data{2}.data = onsets;
        data{2}.header.sr = 1;
        data{2}.header.chantype = 'marker';
        data{2}.header.units = 'events';
      end
      save(fn, 'data', 'infos');
    end
    %displays the expected and actual stats (is beeing used in test 1
    %to 5
    function report(actual, expected, names, header)
      if nargin==4
        fprintf('\n<strong>%s:</strong>\n', header);
      end
      fprintf('\n');
      fprintf('%28s\t|\tactual\t\texpected\n','stats');
      fprintf('--------------------------------|---------------------------\n');
      for i=1:length(actual)
        fprintf('%30s\t|\t%f\t%f\n',names{i},actual(i), expected(i))
      end
      err = norm(actual - expected)/norm(expected);
      fprintf('\nrelative error: %2.2f%%\n\n', err *100);
    end
  end
end
