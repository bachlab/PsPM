function cfg_defaults = cfg_mlbatch_defaults

% function cfg_defaults = cfg_mlbatch_defaults
% This file contains defaults that control the behaviour and appearance 
% of matlabbatch.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: cfg_mlbatch_defaults.m 701 2015-01-22 14:36:13Z tmoser $

rev = '$Rev: 701 $'; %#ok

% Font definition for cfg_ui user interface
% cfg_defaults.cfg_ui.Xfont is a font struct as returned by uisetfont
% lfont: used in lists, value edit dialogues etc.
cfg_defaults.cfg_ui.lfont.FontAngle  = 'normal';
cfg_defaults.cfg_ui.lfont.FontName   = get(0,'factoryTextFontName');
cfg_defaults.cfg_ui.lfont.FontSize   = 12;
cfg_defaults.cfg_ui.lfont.FontUnits  = 'points';
cfg_defaults.cfg_ui.lfont.FontWeight = 'normal';
% bfont: used for buttons
cfg_defaults.cfg_ui.bfont.FontAngle  = get(0, 'factoryUicontrolFontAngle');
cfg_defaults.cfg_ui.bfont.FontName   = get(0,'factoryUicontrolFontName');
cfg_defaults.cfg_ui.bfont.FontSize   = get(0, 'factoryUicontrolFontSize');
cfg_defaults.cfg_ui.bfont.FontUnits  = get(0, 'factoryUicontrolFontUnits');
cfg_defaults.cfg_ui.bfont.FontWeight = get(0, 'factoryUicontrolFontWeight');
% Toggle ExpertEdit mode. Value can be 'on' or 'off'
cfg_defaults.cfg_ui.ExpertEdit = 'off';

% cfg_util
% Parallel execution of independent modules
% Currently, this does not run modules in parallel, but it may reorder
% execution order of modules: all modules without dependencies will be run
% before modules with dependencies will be harvested again. If some modules
% have side effects (e.g. "Change Directory") that are not encoded as
% dependency, this may lead to unwanted results. Disabling parallel
% execution incurs an overhead during job execution because the job
% must be harvested more often.
cfg_defaults.cfg_util.runparallel = false;

% Message defaults
cfg_defaults.msgdef.identifier  = 'cfg_defaults:defaultmessage';
cfg_defaults.msgdef.level       = 'info'; % one of 'info', 'warning', 'error'
cfg_defaults.msgdef.destination = 'stdout'; % one of 'none', 'stdout',
                                            % 'stderr', 'syslog'. Errors
                                            % will always be logged to
                                            % the command window, and
                                            % additionally to syslog, if specified
cfg_defaults.msgdef.verbose     = 'off';
cfg_defaults.msgdef.backtrace   = 'off';

cfg_defaults.msgcfg(1)             = cfg_defaults.msgdef;
cfg_defaults.msgcfg(1).identifier  = 'matlabbatch:run:jobfailederr';
cfg_defaults.msgcfg(1).level       = 'error';
cfg_defaults.msgcfg(2)             = cfg_defaults.msgdef;
cfg_defaults.msgcfg(2).identifier  = 'matlabbatch:cfg_util:addapp:done';
cfg_defaults.msgcfg(2).destination = 'none';

cfg_defaults.msgtpl( 1)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl( 1).identifier  = '^matlabbatch:subsasgn';
cfg_defaults.msgtpl( 1).level       = 'error';
cfg_defaults.msgtpl( 2)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl( 2).identifier  = '^matlabbatch:subsref';
cfg_defaults.msgtpl( 2).level       = 'error';
cfg_defaults.msgtpl( 3)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl( 3).identifier  = '^matlabbatch:constructor';
cfg_defaults.msgtpl( 3).level       = 'error';
cfg_defaults.msgtpl( 4)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl( 4).identifier  = '^matlabbatch:deprecated';
cfg_defaults.msgtpl( 4).destination = 'none';
cfg_defaults.msgtpl( 5)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl( 5).identifier  = '^MATLAB:nargchk';
cfg_defaults.msgtpl( 5).level       = 'error';
cfg_defaults.msgtpl( 6)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl( 6).identifier  = '^matlabbatch:usage';
cfg_defaults.msgtpl( 6).level       = 'error';
cfg_defaults.msgtpl( 7)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl( 7).identifier  = '^matlabbatch:setval';
cfg_defaults.msgtpl( 7).destination = 'none';
cfg_defaults.msgtpl( 8)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl( 8).identifier  = '^matlabbatch:run:nomods';
cfg_defaults.msgtpl( 8).level       = 'info';
cfg_defaults.msgtpl( 9)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl( 9).identifier  = '^matlabbatch:cfg_struct2cfg';
cfg_defaults.msgtpl( 9).destination = 'none';
cfg_defaults.msgtpl(10)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl(10).identifier  = '^MATLAB:inputdlg';
cfg_defaults.msgtpl(10).level       = 'error';
cfg_defaults.msgtpl(11)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl(11).identifier  = '^MATLAB:listdlg';
cfg_defaults.msgtpl(11).level       = 'error';
cfg_defaults.msgtpl(12)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl(12).identifier  = '^MATLAB:num2str';
cfg_defaults.msgtpl(12).level       = 'error';
cfg_defaults.msgtpl(13)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl(13).identifier  = '^matlabbatch:ok_subsasgn';
cfg_defaults.msgtpl(13).destination = 'none';
cfg_defaults.msgtpl(14)             = cfg_defaults.msgdef;
cfg_defaults.msgtpl(14).identifier  = 'matlabbatch:checkval:numcheck:transposed';
cfg_defaults.msgtpl(14).destination = 'none';
