classdef pspm_find_channel_test < matlab.unittest.TestCase
  % SCR_FIND_CHANNEL_TEST
  % unittest class for the pspm_find_channel function
  % SCRalyze TestEnvironment
  % (C) 2013 Linus R¸ttimann (University of Zurich)
  properties
  end

  methods (Test)
    function invalid_inputargs(this)
      this.verifyWarning(@()pspm_find_channel('str','scr'), 'ID:invalid_input', 'invalid_inputargs test 1');
      headercell = {'heart', 'scr', 'pupil'};
      this.verifyWarning(@()pspm_find_channel(headercell, 'str'), 'ID:not_allowed_channeltype', 'invalid_inputargs test 2');
      this.verifyWarning(@()pspm_find_channel(headercell, 4), 'ID:invalid_input', 'invalid_inputargs test 3');
    end

    function valid_inputargs(this)
      headercell = {'heart', 'scr', 'pupil', 'mark', 'gsr', 'eda'};
      this.verifyEqual(pspm_find_channel(headercell, 'pupil'), 3);
      act_val = this.verifyWarning(@()pspm_find_channel(headercell, 'resp'), 'ID:no_matching_channels');
      this.verifyEqual(act_val, 0);
      act_val = this.verifyWarning(@()pspm_find_channel(headercell, 'scr'), 'ID:multiple_matching_channels');
      this.verifyEqual(act_val, -1);
      act_val = this.verifyWarningFree(@()pspm_find_channel(headercell, {'mark', 'str', 'bla'}));
      this.verifyEqual(act_val, 4);
      act_val = this.verifyWarningFree(@()pspm_find_channel(headercell, {'call', 'str', 'me'}));
      this.verifyEqual(act_val, 0);
      act_val = this.verifyWarningFree(@()pspm_find_channel(headercell, {'scr', 'gsr', 'eda'}));
      this.verifyEqual(act_val, -1);
    end
  end
end