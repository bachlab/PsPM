function cfg_add_module(arg)
% Calls the specified module in matalabbatch

% $Id: cfg_add_module.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

mod_cfg_id = cfg_util('tag2mod_cfg_id',arg);
cjob = cfg_util('initjob');
mod_job_id = cfg_util('addtojob', cjob, mod_cfg_id);
cfg_util('harvest', cjob, mod_job_id);
cfg_ui('local_showjob', findobj(0,'tag','cfg_ui'), cjob);