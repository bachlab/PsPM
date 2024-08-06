function trim = pspm_cfg_trim

%% Standard items
datafile         = pspm_cfg_selector_datafile;
channel          = pspm_cfg_selector_channel('marker');
overwrite        = pspm_cfg_selector_overwrite;

%% Specific items
from         = cfg_entry;
from.name    = 'From (seconds after chosen reference)';
from.tag     = 'from';
from.strtype = 'r';
from.num     = [1 1];
from.help    = pspm_cfg_help_format('pspm_trim', 'from');

to         = cfg_entry;
to.name    = 'To (seconds after chosen reference)';
to.tag     = 'to';
to.strtype = 'r';
to.num     = [1 1];
to.help    = pspm_cfg_help_format('pspm_trim', 'to');


%% Items for reference: Any Marker
ref_any_mrk_no         = cfg_entry;
ref_any_mrk_no.name    = 'Marker numbers';
ref_any_mrk_no.tag     = 'mrkno';
ref_any_mrk_no.strtype = 'i';
ref_any_mrk_no.num     = [2 1];
ref_any_mrk_no.help    = {'Enter 2 reference marker numbers.'};

%% Items for reference: Marker according to vales or names

mrk_vals_from         = cfg_entry;
mrk_vals_from.name    = 'Start marker, with unique value or name';
mrk_vals_from.tag     = 'mrkval_from';
mrk_vals_from.strtype = 's';
mrk_vals_from.help    = {'Either choose a numeric marker value or a marker name.'};

mrk_vals_to         = cfg_entry;
mrk_vals_to.name    = 'End marker, with unique value or name';
mrk_vals_to.tag     = 'mrkval_to';
mrk_vals_to.strtype = 's';
mrk_vals_to.help    = {'Either choose a numeric marker value or a marker name.'};


%% Reference
ref_file         = cfg_const;
ref_file.name    = 'File';
ref_file.tag     = 'ref_file';
ref_file.val     = {'file'};
ref_file.help    = {};

ref_fl_mrk         = cfg_branch;
ref_fl_mrk.name    = 'First/last marker';
ref_fl_mrk.tag     = 'ref_mrk';
ref_fl_mrk.val     = {channel};
ref_fl_mrk.help    = {};

ref_any_mrk         = cfg_branch;
ref_any_mrk.name    = 'Marker numbers';
ref_any_mrk.tag     = 'ref_any_mrk';
ref_any_mrk.val     = {ref_any_mrk_no,channel};
ref_any_mrk.help    = {};

ref_mrk_vals         = cfg_branch;
ref_mrk_vals.name    = 'Marker values or names';
ref_mrk_vals.tag     = 'ref_mrk_vals';
ref_mrk_vals.val     = {mrk_vals_from,mrk_vals_to,channel};
ref_mrk_vals.help    = {};

%% Reference Choice
ref         = cfg_choice;
ref.name    = 'Reference';
ref.tag     = 'ref';
ref.values  = {ref_file,ref_fl_mrk,ref_any_mrk,ref_mrk_vals};
ref.help    = pspm_cfg_help_format('pspm_trim', 'reference');

%% Executable branch
trim      = cfg_exbranch;
trim.name = 'Trim';
trim.tag  = 'trim';
trim.val  = {datafile,ref,from,to,overwrite};
trim.prog = @pspm_cfg_run_trim;
trim.vout = @pspm_cfg_vout_outfile;
trim.help = pspm_cfg_help_format('pspm_trim');
