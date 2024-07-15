function trim = pspm_cfg_trim

%% Standard items
datafile         = pspm_cfg_selector_datafile;
channel          = pspm_cfg_selector_channel('marker');
overwrite        = pspm_cfg_selector_overwrite;

%% Specific items

%% Items for reference: File
file_from         = cfg_entry;
file_from.name    = 'From (seconds after file start)';
file_from.tag     = 'from';
file_from.strtype = 'r';
file_from.num     = [1 1];
file_from.help    = {'Choose a positive value.'};

file_to         = cfg_entry;
file_to.name    = 'To (seconds after file start)';
file_to.tag     = 'to';
file_to.strtype = 'r';
file_to.num     = [1 1];
file_to.help    = {'Choose a positive value larger than the ''from'' value.'};

%% Items for reference: First/Last Marker
fl_mrk_from         = cfg_entry;
fl_mrk_from.name    = 'From (seconds after first marker)';
fl_mrk_from.tag     = 'from';
fl_mrk_from.strtype = 'r';
fl_mrk_from.num     = [1 1];
fl_mrk_from.help    = {'Choose a positive (after first marker) or negative (before first marker) value.'};

fl_mrk_to         = cfg_entry;
fl_mrk_to.name    = 'To (seconds after last marker)';
fl_mrk_to.tag     = 'to';
fl_mrk_to.strtype = 'r';
fl_mrk_to.num     = [1 1];
fl_mrk_to.help    = {'Choose a positive (after last marker) or negative (before last marker) value.'};

%% Items for reference: Any Marker
any_mrk_from_nr         = cfg_entry;
any_mrk_from_nr.name    = 'Marker Number x';
any_mrk_from_nr.tag     = 'mrkno';
any_mrk_from_nr.strtype = 'i';
any_mrk_from_nr.num     = [1 1];
any_mrk_from_nr.help    = {'Choose an integer value.'};

any_mrk_to_nr         = cfg_entry;
any_mrk_to_nr.name    = 'Marker Number y';
any_mrk_to_nr.tag     = 'mrkno';
any_mrk_to_nr.strtype = 'i';
any_mrk_to_nr.num     = [1 1];
any_mrk_to_nr.help    = {'Choose an integer value.'};

any_mrk_from         = cfg_entry;
any_mrk_from.name    = 'Seconds after Marker x';
any_mrk_from.tag     = 'mrksec';
any_mrk_from.strtype = 'r';
any_mrk_from.num     = [1 1];
any_mrk_from.help    = {'Choose a positive (after this marker) or negative (before this marker) value.'};

any_mrk_to         = cfg_entry;
any_mrk_to.name    = 'Seconds after Marker y';
any_mrk_to.tag     = 'mrksec';
any_mrk_to.strtype = 'r';
any_mrk_to.num     = [1 1];
any_mrk_to.help    = {'Choose a positive (after this marker) or negative (before this marker) value.'};

ref_any_mrk_from         = cfg_branch;
ref_any_mrk_from.name    = 'From';
ref_any_mrk_from.tag     = 'from';
ref_any_mrk_from.val     = {any_mrk_from_nr,any_mrk_from};
ref_any_mrk_from.help    = {'Choose marker number and trimming point in seconds after this marker.'};

ref_any_mrk_to         = cfg_branch;
ref_any_mrk_to.name    = 'To';
ref_any_mrk_to.tag     = 'to';
ref_any_mrk_to.val     = {any_mrk_to_nr,any_mrk_to};
ref_any_mrk_to.help    = {'Choose marker number and trimming point in seconds after this marker.'};

%% Items for reference: Marker according to vales or names

mrk_vals_from_name         = cfg_entry;
mrk_vals_from_name.name    = 'First marker with value or name x';
mrk_vals_from_name.tag     = 'mrval';
mrk_vals_from_name.strtype = 's';
mrk_vals_from_name.help    = {'Either choose a numeric marker value or a marker name.'};

mrk_vals_to_name         = cfg_entry;
mrk_vals_to_name.name    = 'First marker with value or name y';
mrk_vals_to_name.tag     = 'mrval';
mrk_vals_to_name.strtype = 's';
mrk_vals_from_name.help    = {'Either choose a numeric marker value or a marker name.'};

mrk_vals_from         = cfg_entry;
mrk_vals_from.name    = 'Seconds after first marker with value/name x';
mrk_vals_from.tag     = 'mrksec';
mrk_vals_from.strtype = 'r';
mrk_vals_from.num     = [1 1];
mrk_vals_from.help    = {'Choose a positive (after this marker) or negative (before this marker) value.'};

mrk_vals_to         = cfg_entry;
mrk_vals_to.name    = 'Seconds after first marker with value/name y';
mrk_vals_to.tag     = 'mrksec';
mrk_vals_to.strtype = 'r';
mrk_vals_to.num     = [1 1];
mrk_vals_to.help    = {'Choose a positive (after this marker) or negative (before this marker) value.'};


ref_mrk_vals_from         = cfg_branch;
ref_mrk_vals_from.name    = 'From';
ref_mrk_vals_from.tag     = 'from';
ref_mrk_vals_from.val     = {mrk_vals_from_name,mrk_vals_from};
ref_mrk_vals_from.help    = {'Choose value or name used to  find the first',...
                             ' marker with that value/name. This will be the from',...
                             ' marker. Choose the trimming point in seconds',...
                             ' after this marker.'};

ref_mrk_vals_to         = cfg_branch;
ref_mrk_vals_to.name    = 'To';
ref_mrk_vals_to.tag     = 'to';
ref_mrk_vals_to.val     = {mrk_vals_to_name,mrk_vals_to};
ref_mrk_vals_to.help    = {'Choose value or name used to  find the first',...
                           ' marker with that value/name. This will be the to',...
                           ' marker. Choose the trimming point in seconds',...
                           ' after this marker.'};

%% Reference
ref_file         = cfg_branch;
ref_file.name    = 'File';
ref_file.tag     = 'ref_file';
ref_file.val     = {file_from,file_to};
ref_file.help    = {'Trim from xx seconds after file start to xx seconds after file start.'};

ref_fl_mrk         = cfg_branch;
ref_fl_mrk.name    = 'First/Last Marker';
ref_fl_mrk.tag     = 'ref_mrk';
ref_fl_mrk.val     = {fl_mrk_from,fl_mrk_to,channel};
ref_fl_mrk.help    = {'Trim from xx seconds after first marker to xx seconds after last marker.'};

ref_any_mrk         = cfg_branch;
ref_any_mrk.name    = 'Any Marker';
ref_any_mrk.tag     = 'ref_any_mrk';
ref_any_mrk.val     = {ref_any_mrk_from,ref_any_mrk_to,channel};
ref_any_mrk.help    = {['Trim from xx seconds after any marker of your choice to xx ' ...
    'seconds after any marker of your choice.']};

ref_mrk_vals         = cfg_branch;
ref_mrk_vals.name    = 'Marker according to values or names';
ref_mrk_vals.tag     = 'ref_mrk_vals';
ref_mrk_vals.val     = {ref_mrk_vals_from,ref_mrk_vals_to,channel};
ref_mrk_vals.help    = {['Trim from xx seconds after first marker with value or name yy  to xx ' ...
    'seconds after first marker of value or name zz.']};
%% Reference Choice
ref         = cfg_choice;
ref.name    = 'Reference';
ref.tag     = 'ref';
ref.values  = {ref_file,ref_fl_mrk,ref_any_mrk,ref_mrk_vals};
ref.help    = {['Choose your reference for trimming: file start, first/last marker, ' ...
    'or a user-defined marker (specifying the marker nr. or the value/name a marker must hold).'...
    ' All trimming is defined in seconds after this reference ' ...
    '- choose negative values if you want to trim before the reference.']};

%% Executable branch
trim      = cfg_exbranch;
trim.name = 'Trim';
trim.tag  = 'trim';
trim.val  = {datafile,ref,overwrite};
trim.prog = @pspm_cfg_run_trim;
trim.vout = @pspm_cfg_vout_outfile;
trim.help = {['Trim away unnessecary data, for example before an experiment started, ' ...
    'or after it ended. Trim points can be defined in seconds with respect to start of ' ...
    'the data file, in seconds with respect to first and last marker (if markers exist), ' ...
    'or in seconds with respect to a user-defined marker. The resulting data will be written ' ...
    'to a new file, prepended with ''t''.']};
