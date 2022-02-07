function import_data = pspm_cfg_import

%% Initialise
global settings
if isempty(settings), pspm_init; end

% Get filetype
fileoptions={settings.import.datatypes.long};
chantypesDescription = {settings.chantypes.description};
chantypesData = {settings.chantypes.data};


%% Predefined struct
% Channel/Column Search
chan_search      = cfg_const;
chan_search.name = 'Search';
chan_search.tag  = 'chan_search';
chan_search.val  = {true};
chan_search.help = {['Search for channel by its name - this only works if the ', ...
    'channel names are unambiguous.']};

% Sample Rate
sample_rate         = cfg_entry;
sample_rate.name    = 'Sample Rate';
sample_rate.tag     = 'sample_rate';
sample_rate.strtype = 'r';
sample_rate.num     = [1 1];
sample_rate.help    = {'Sample rate in Hz (i. e. samples per second).'};

% Transfer function
scr_file         = cfg_files;
scr_file.name    = 'File';
scr_file.tag     = 'file';
scr_file.num     = [1 1];
scr_file.filter  = '.*\.(mat|MAT)$';
scr_file.help    = {['Enter the name of the .mat file that contains the ', ...
    'transfer function constants. This file needs to contain the ', ...
    'following variables: ''c'' is the transfer constant: ', ...
    'data = c * (measured total conductance in mcS or total resistance ', ...
    'in MOhm); ''Rs'' is the series resistance in Ohm (usually 0), ', ...
    'and ''offset'' any offset in the data (stated in data units, ', ...
    'usually 0) and optionally, a variable ''recsys'' to whether the ', ...
    'recorded signal is proportional to measured ''resistance'' ', ...
    '(R, data=R*c=c/G) or from ''conductance'' (G, data=G*c=c/R).']};

scr_transf_const         = cfg_entry;
scr_transf_const.name    = 'Transfer Constant';
scr_transf_const.tag     = 'transfer_const';
scr_transf_const.strtype = 'r';
scr_transf_const.num     = [1 1];
scr_transf_const.help    = {['Constant by which the measured conductance or ', ...
    'resistance is multiplied to give the recorded signal ', ...
    '(and by which the signal needs to be divided to give the original ', ...
    'conductance/resistance): data = c * (measured total conductance ', ...
    'in mcS or total resistance in MOhm).']};

scr_offset         = cfg_entry;
scr_offset.name    = 'Offset';
scr_offset.tag     = 'offset';
scr_offset.strtype = 'r';
scr_offset.num     = [1 1];
scr_offset.help    = {'Fixed offset in data units (i. e. measured signal when ', ...
    'true conductance is zero, i.e. when the measurement circuit is open).'};

scr_resistor         = cfg_entry;
scr_resistor.name    = 'Series Resistor';
scr_resistor.tag     = 'resistor';
scr_resistor.strtype = 'r';
scr_resistor.num     = [1 1];
scr_resistor.help    = {'Resistance of any resistors in series with the ', ...
    'subject, given in Ohm.'};

scr_recsys           = cfg_menu;
scr_recsys.name      = 'Recording System';
scr_recsys.tag       = 'recsys';
scr_recsys.values    = {'conductance', 'resistance'};
scr_recsys.labels    = {'conductance', 'resistance'};
scr_recsys.val       = {'conductance'};
scr_recsys.help      = {['Choose whether the recorded signal is proportional ', ...
    'to measured ''resistance'' (R, data=R*c=c/G) or from ''conductance'' ', ...
    '(G, data=G*c=c/R).']};

scr_input       = cfg_branch;
scr_input.name  = 'Input';
scr_input.tag   = 'input';
scr_input.val   = {scr_transf_const,scr_offset,scr_resistor, scr_recsys};
scr_input.help  = {'Enter the transfer constants manually.'};
    
none      = cfg_const;
none.name = 'None';
none.tag  = 'none';
none.val  = {true};
none.help = {['No transfer function. Use this only if you are not interested in ' ...
    'absolute values, and if the recording settings were the same for all subjects.']};

scr_transfer         = cfg_choice;
scr_transfer.name    = 'Transfer Function';
scr_transfer.tag     = 'scr_transfer';
scr_transfer.values  = {scr_file,scr_input,none};
scr_transfer.help    = {['Enter the conversion from recorded data to ', ...
    'Microsiemens or Megaohm.']};

eyelink_trackdist         = cfg_entry;
eyelink_trackdist.name    = 'Eyetracker distance';
eyelink_trackdist.tag     = 'eyelink_trackdist';
eyelink_trackdist.val     = {-1};
eyelink_trackdist.num     = [1 1];
eyelink_trackdist.strtype = 'r';
eyelink_trackdist.help    = {['Distance between eyetracker camera and ', ...
    'recorded eyes. Disabled if 0 or less (use only if you are interested ', ...
    'in relative values), then pupil data will remain unchanged. If ', ...
    'enabled (> 0) the data will be converted from arbitrary units to ', ...
    'length units.']};

distance_unit           = cfg_menu;
distance_unit.name      = 'Distance unit';
distance_unit.tag       = 'distance_unit';
distance_unit.values    = {'mm', 'cm', 'm', 'inches'};
distance_unit.labels    = {'mm', 'cm', 'm', 'inches'};
distance_unit.val       = {'mm'};
distance_unit.help      = {['The unit in which the eyetracker distance ', ...
    'is given and to which the pupil data should be converted.']};

viewpoint_target_unit           = cfg_menu;
viewpoint_target_unit.name      = 'Target unit';
viewpoint_target_unit.tag       = 'viewpoint_target_unit';
viewpoint_target_unit.values    = {'mm', 'cm', 'm', 'inches'};
viewpoint_target_unit.labels    = {'mm', 'cm', 'm', 'inches'};
viewpoint_target_unit.val       = {'mm'};
viewpoint_target_unit.help      = {['The unit to which the gaze data should be converted.']};

smi_target_unit           = cfg_menu;
smi_target_unit.name      = 'Target unit';
smi_target_unit.tag       = 'smi_target_unit';
smi_target_unit.values    = {'mm', 'cm', 'm', 'inches'};
smi_target_unit.labels    = {'mm', 'cm', 'm', 'inches'};
smi_target_unit.val       = {'mm'};
smi_target_unit.help      = {['The unit to which the data should be converted.']};

smi_stimulus_resolution           = cfg_entry;
smi_stimulus_resolution.name      = 'Stimulus Resolution';
smi_stimulus_resolution.tag       = 'smi_stimulus_resolution';
smi_stimulus_resolution.val       = {[-1 -1]};
smi_stimulus_resolution.num       = [1 2];
smi_stimulus_resolution.help      = {['The resolution of the stimulus window. This field is required' ...
                                      'to perform px to mm conversions for gaze channels']};

delimiter           = cfg_entry;
delimiter.name      = 'Delimiter';
delimiter.tag       = 'delimiter';
delimiter.strtype   = 's';
delimiter.help      = {'The delimiter to be used for file reading, leave blank to use any whitespace character.'};

header_lines           = cfg_entry;
header_lines.name      = 'Header lines';
header_lines.tag       = 'header_lines';
header_lines.strtype   = 'r';
header_lines.val       = {1};
header_lines.help      = {'The number of lines used by the header. By default 1.'};

channel_names_line         = cfg_entry;
channel_names_line.name    = 'Channel names line';
channel_names_line.tag     = 'channel_names_line';
channel_names_line.strtype = 'r';
channel_names_line.val     = {1};
channel_names_line.help    = {'The line number where the channel/column names are specified. By default 1.'};

exclude_columns           = cfg_entry;
exclude_columns.name      = 'Exclude columns';
exclude_columns.tag       = 'exclude_columns';
exclude_columns.strtype   = 'r';
exclude_columns.val       = {0};
exclude_columns.help      = {['The number of columns which have to be excluded for the importing. By default 0. ',...
                              'It is usefull if the first columns have non numeric data (e.g. timestamps). ', ...
                              'Be aware that if you exclude some columns you have to adapt the channel number.']};

%% Datatype dependend items
datatype_item = cell(1,length(fileoptions));
for datatype_i=1:length(fileoptions)
    
    %% Settings
    if settings.import.datatypes(datatype_i).autosr == 1
        samplerate = -1; 
    else 
        samplerate = 0; 
    end
    % If more than one channel can be defined
    multioption  = settings.import.datatypes(datatype_i).multioption; 
    description  = settings.import.datatypes(datatype_i).chandescription;
    % Capitalize description
    description  = regexprep(description,'(\<\w)','${upper($1)}');
    searchoption = settings.import.datatypes(datatype_i).searchoption;
    automarker   = settings.import.datatypes(datatype_i).automarker;
    chantypes    = settings.import.datatypes(datatype_i).chantypes;
    short        = settings.import.datatypes(datatype_i).short;
    ext          = settings.import.datatypes(datatype_i).ext;
    help         = {settings.import.datatypes(datatype_i).help};

    
    %% Channel/Column Number
    % Default Channel Nr.
    chan_nr_def         = cfg_const;
    chan_nr_def.name    = ['Default ' description ' Number'];
    chan_nr_def.tag     = 'chan_nr_def';
    chan_nr_def.val     = {0};
    chan_nr_def.help    = {''};
    
    % Sepcify Channel/Column Nr.
    chan_nr_spec         = cfg_entry;
    chan_nr_spec.name    = ['Specify ' description ' Number'];
    chan_nr_spec.tag     = 'chan_nr_spec';
    chan_nr_spec.strtype = 'i';
    chan_nr_spec.num     = [1 1];
    chan_nr_spec.help    = {'Specify the n-th channel. This counts the number of channels actually recorded.'};
    
    % Channel/Column Nr. (variable choice options)
    chan_nr        = cfg_choice;
    chan_nr.name   = [description ' Number'];
    chan_nr.tag    = 'chan_nr';
    chan_nr.help   = {['Specify where in the original file to find the channel. You can ' ...
        'either specify a number (i. e. the n-th channel in the file), or search for ' ...
        'this channel by its name. Note: the channel number refers to the n-th recorded ' ...
        'channel, not to its number during acquisition (if you did not save all recorded ' ...
        'channels, these might be different for some data types).']};
    
    %% Flank option for 'event' channel types
    flank_option        = cfg_menu;
    flank_option.name   = 'Flank of the event impulses to import';
    flank_option.tag    = 'flank_option';
    flank_option.values = {'ascending', 'descending', 'all', 'both', 'default'};
    flank_option.labels = {'ascending', 'descending', 'both', 'middle', 'default'};
    flank_option.val    = {'default'};
    flank_option.help   = {['The flank option specifies which of the rising edge(ascending), ', ...
        'falling edge(descending), both edges or their mean(middle) of a marker impulse should ', ...
        'be imported into the marker channel. The default option is to select the middle of ', ...
        'the impulse, some exceptions are Eyelink, ViewPoint and SensoMotoric Instruments data ', ...
        'for which the default are respectively ''both'', ''ascending'', ''ascending''. ',...
        'If the numbers of rising and falling edges differ, PsPM will throw an error. ']};
   
    %% Channel/Column Type Items
    importtype_item = cell(1,length(chantypes));
    for importtype_i=1:length(chantypes)
        importtype_item{importtype_i}       = cfg_branch;
        % Find channeltype description
        chantypesDescIdx = find(strcmp({settings.chantypes.type},chantypes{importtype_i}));
        if ~isempty(chantypesDescIdx)
            importtype_item{importtype_i}.name = chantypesDescription{chantypesDescIdx};
        else
            importtype_item{importtype_i}.name  = chantypes{importtype_i};
        end
        importtype_item{importtype_i}.tag   = chantypes{importtype_i};
        importtype_item{importtype_i}.help  = {''};
        
        % Check for different Channel/Column options
        if strcmp(chantypes(importtype_i), 'marker') && automarker
            % Def->0
            chan_nr_def.val = {0};
            chan_nr.val    = {chan_nr_def};
            chan_nr.values = {chan_nr_def};
        elseif searchoption
            if multioption
                % Choice: Search->0; Spec->Nr
                chan_nr.val    = {};
                chan_nr.values = {chan_search,chan_nr_spec};
            else
                % Choice: Search->0; Def->1
                chan_nr_def.val = {1};
                chan_nr.val    = {};
                chan_nr.values = {chan_search,chan_nr_def};
            end
        else
            if multioption
                % Spec->Nr
                chan_nr.val    = {chan_nr_spec};
                chan_nr.values = {chan_nr_spec};
            else
                % Def->1
                chan_nr_def.val = {1};
                chan_nr.val    = {chan_nr_def};
                chan_nr.values = {chan_nr_def};
            end
        end
        
        if strcmp(chantypesData{chantypesDescIdx}, 'events')
            importtype_item{importtype_i}.val = {chan_nr,flank_option};
        else
            importtype_item{importtype_i}.val = {chan_nr};
        end
        
        
        % Check for sample rate
        if samplerate == 0
            importtype_item{importtype_i}.val = [importtype_item{importtype_i}.val,{sample_rate}];
        end
        
        % Check for scr transfer function
        if strcmp(chantypes(importtype_i), 'scr')
            importtype_item{importtype_i}.val = [importtype_item{importtype_i}.val,{scr_transfer}];
        end
        
    end
    
    importtype         = cfg_choice;
    importtype.name    = [description ' Type'];
    importtype.tag     = 'importtype';
    importtype.values  = importtype_item;
    importtype.help    = {'Specify the type of data in this channel.'};
    
    if multioption == 1
        importchan         = cfg_repeat;
        importchan.name    = [description 's'];
        importchan.tag     = 'importchan';
        importchan.values  = {importtype};
        importchan.num     = [1 Inf];
        importchan.help    = {'Define all channels that you want to import.'};
    end
    
    
    % Data File
    datafile         = cfg_files;
    datafile.name    = 'Data File(s)';
    datafile.tag     = 'datafile';
    datafile.num     = [1 Inf];
    if strcmpi(ext, 'any')
        datafile.filter ='.*';
    else
        datafile.filter  = ['.*\.(' ext '|' upper(ext) ')$'];
    end
    datafile.help    = {settings.datafilehelp} ;

    if any(strcmpi(settings.import.datatypes(datatype_i).short, 'smi'))
        input_file = cfg_files;
        input_file.name = 'Sample and optional Event Files';
        input_file.num = [1 2];
        input_file.tag = 'datafile';
        if strcmpi(ext, 'any')
            event_file.filter ='.*';
        else
            event_file.filter  = ['.*\.(' ext '|' upper(ext) ')$'];
        end

        datafile         = cfg_repeat;
        datafile.name    = 'Data File(s)';
        datafile.tag     = 'datafile';
        datafile.num     = [1 Inf];
        datafile.help    = {settings.datafilehelp} ;
        datafile.values  = {input_file};
    end
    
    datatype_item{datatype_i}       = cfg_branch;
    datatype_item{datatype_i}.name  = fileoptions{datatype_i};
    datatype_item{datatype_i}.tag   = short;
    datatype_item{datatype_i}.help  = help;
    if multioption == 1
        datatype_item{datatype_i}.val   = {datafile,importchan};
    else
        datatype_item{datatype_i}.val   = {datafile,importtype};
    end

    % For eyelink: add stuff
    % TODO: this is a very bad (unsustainable/unmaintainable) way of doing this.
    % Refactor this part by even possibly dividing pspm_cfg_import to several files.
    if any(strcmp(settings.import.datatypes(datatype_i).short, 'eyelink'))
        datatype_item{datatype_i}.val = ...
            [datatype_item{datatype_i}.val, {eyelink_trackdist, distance_unit}];
    end

    if any(strcmpi(settings.import.datatypes(datatype_i).short, 'viewpoint'))
        datatype_item{datatype_i}.val = [datatype_item{datatype_i}.val, {viewpoint_target_unit}];
    end
    
    if any(strcmpi(settings.import.datatypes(datatype_i).short, 'smi'))
        datatype_item{datatype_i}.val = [datatype_item{datatype_i}.val, {smi_target_unit, smi_stimulus_resolution}];
    end
    
    if any(strcmpi(settings.import.datatypes(datatype_i).short, 'txt'))
        datatype_item{datatype_i}.val = [datatype_item{datatype_i}.val, {header_lines,channel_names_line,exclude_columns}];
    end
    
    if any(strcmpi(settings.import.datatypes(datatype_i).short, 'csv'))
        datatype_item{datatype_i}.val = [datatype_item{datatype_i}.val, {header_lines,channel_names_line,exclude_columns}];
    end
    
    if any(strcmpi(settings.import.datatypes(datatype_i).short, 'dsv'))
        datatype_item{datatype_i}.val = [datatype_item{datatype_i}.val, {delimiter,header_lines,channel_names_line,exclude_columns}];
    end
end

%% Data type
datatype         = cfg_choice;
datatype.name    = 'Data Type';
datatype.tag     = 'datatype';
datatype.values  = datatype_item;
datatype.help    = {''};

%% Overwrite file
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite Existing File';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Overwrite existing file?'};

%% Executable branch
import_data      = cfg_exbranch;
import_data.name = 'Import';
import_data.tag  = 'import';
import_data.val  = {datatype, overwrite};
import_data.prog = @pspm_cfg_run_import;
import_data.vout = @pspm_cfg_vout_import;
import_data.help = {['Import external data files for use by PsPM. First, specify the ' ...
    'data type. Then, other fields will come up as required for this data type. The ' ...
    'imported data will be written to a new .mat file, prepended with ''pspm_''.']};

function vout = pspm_cfg_vout_import(job)
vout = cfg_dep;
vout.sname      = 'Output File';
vout.src_output = substruct('()',{':'});
