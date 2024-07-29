classdef pspm_path_test < pspm_testcase
  % ● Description
  % unittest class for the pspm_path function
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  %     2022 Teddy
  properties(Constant)
    pspm_root_dir = pspm_path();
  end
  methods(Test)
    function test_pspm_path(this)
      this.verifyEqual(pspm_path(''), this.pspm_root_dir);
      this.verifyEqual(pspm_path('', ''), this.pspm_root_dir);
      this.verifyEqual(pspm_path('a'), [this.pspm_root_dir filesep 'a']);
      this.verifyEqual(pspm_path('Z'), [this.pspm_root_dir filesep 'Z']);
      this.verifyEqual(pspm_path('', 'a', '', ''), [this.pspm_root_dir filesep 'a']);
      this.verifyEqual(pspm_path('a', 'b'), [this.pspm_root_dir filesep 'a' filesep 'b']);
      this.verifyEqual(pspm_path('a', 'B'), [this.pspm_root_dir filesep 'a' filesep 'B']);
      this.verifyEqual(pspm_path('/abc'), [this.pspm_root_dir filesep 'abc']);
      this.verifyEqual(pspm_path('/abc/'), [this.pspm_root_dir filesep 'abc' filesep]);
      this.verifyEqual(pspm_path('/abc', '/def'), [this.pspm_root_dir filesep 'abc' filesep 'def']);
      this.verifyEqual(pspm_path('/abc/', '/def/'), [this.pspm_root_dir filesep 'abc' filesep 'def' filesep]);
      this.verifyError(@()pspm_path(5), 'ID:invalid_input');
      this.verifyError(@()pspm_path('a', 'b', 5), 'ID:invalid_input');
    end
  end
end