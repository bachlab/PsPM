function import_data = scr_cfg_import

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

% Get filetype
fileoptions={settings.import.datatypes.long};
chantypesDescription = {settings.chantypes.description};


%% Predefined struct
% Channel/Column Search
chan_search      = cfg_const;
chan_search.name = 'Search';
chan_search.tag  = 'chan_search';
chan_search.val  = {true};
chan_search.help = {'Search for channel by its name - this only works if the channel names are unambiguous.'};

% Sample Rate
sample_rate         = cfg_entry;
sample_rate.name    = 'Sample Rate';
sample_rate.tag     = 'sample_rate';
sample_rate.strtype = 'r';
sample_rate.num     = [1 1];
sample_rate.help    = {'Sample rate in Hz (i. e. samples per second).'};

% Transfer function
file         = cfg_files;
file.name    = 'File';
file.tag     = 'file';
file.num     = [1 1];
file.filter  = '.*\.(mat|MAT)$';
file.help    = {['Enter the name of the .mat file that contains the transfer function constants. ' ...
    'This file needs to contain the following variables: ''c'' is the transfer constant: data = c * ' ...
    '(total conductance in mcS); ''Rs'' is the series resistance in Ohm (usually 0), and ''offset'' any ' ...
    'offset in the data (usually 0).']};

transf_const         = cfg_entry;
transf_const.name    = 'Transfer Constant';
transf_const.tag     = 'transf_const';
transf_const.strtype = 'r';
transf_const.num     = [1 1];
transf_const.help    = {['Constant by which the measured conductance is multiplied ' ...
    'to give the recorded signal (and by which the signal needs to be divided to give ' ...
    'the original conductance).']};

offset         = cfg_entry;
offset.name    = 'Offset';
offset.tag     = 'offset';
offset.strtype = 'r';
offset.num     = [1 1];
offset.help    = {'Fixed offset (signal at 0 conductance).'};

resistor         = cfg_entry;
resistor.name    = 'Series Resistor';
resistor.tag     = 'resistor';
resistor.strtype = 'r';
resistor.num     = [1 1];
resistor.help    = {'Resistance of any resistors in series with the subject.'};

recsys           = cfg_menu;
recsys.name      = 'Recording System';
recsys.tag       = 'recsys';
recsys.values    = {'conductance', 'resistance'};
recsys.labels    = {'conductance', 'resistance'};
recsys.val       = {'conductance'};
recsys.help      = {['Choose whether the recorded voltage (U) was ', ...
    'calculated from ''resistance'' (R, U=R*c=c/G) or from ''conductance'' , ', ...
    '(G, U=G*c=c/R).']};

input       = cfg_branch;
input.name  = 'Input';
input.tag   = 'input';
input.val   = {transf_const,offset,resistor, recsys};
input.help  = {'Enter the transfer constants manually.'};
    
none      = cfg_const;
none.name = 'None';
none.tag  = 'none';
none.val  = {true};
none.help = {['No transfer function. Use this only if you are not interested in ' ...
    'absolute values, and if the recording settings were the same for all subjects.']};

transfer         = cfg_choice;
transfer.name    = 'Transfer Function';
transfer.tag     = 'transfer';
transfer.values  = {file,input,none};
transfer.help    = {'Enter the conversion from recorded data to Microsiemens.'};


%% Datatype dependend items
datatype_item = cell(1,length(fileoptions));
for datatype_i=1:length(fileoptions)
    
    %% Settings
    if settings.import.datatypes(datatype_i).autosr == 1, samplerate = -1; else samplerate = 0; end;
    multioption  = settings.import.datatypes(datatype_i).multioption; % If more than one channel can be defined
    description  = settings.import.datatypes(datatype_i).chandescription;
    description  = regexprep(description,'(\<\w)','${upper($1)}'); % Capitalize description
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
        
        importtype_item{importtype_i}.val = {chan_nr};
        
        % Check for sample rate
        if samplerate == 0
            importtype_item{importtype_i}.val = [importtype_item{importtype_i}.val,{sample_rate}];
        end
        
        % Check for transfer function
        if strcmp(chantypes(importtype_i), 'scr')
            importtype_item{importtype_i}.val = [importtype_item{importtype_i}.val,{transfer}];
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
    datafile.help    = {''};
    
    datatype_item{datatype_i}       = cfg_branch;
    datatype_item{datatype_i}.name  = fileoptions{datatype_i};
    datatype_item{datatype_i}.tag   = short;
    datatype_item{datatype_i}.help  = help;
    if multioption == 1
        datatype_item{datatype_i}.val   = {datafile,importchan};
    else
        datatype_item{datatype_i}.val   = {datafile,importtype};
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
import_data.prog = @scr_cfg_run_import;
import_data.vout = @scr_cfg_vout_import;
import_data.help = {['Import external data files for use by PsPM. First, specify the ' ...
    'data type. Then, other fields will come up as required for this data type. The ' ...
    'imported data will be written to a new .mat file, prepended with ''scr_''.']};

function vout = scr_cfg_vout_import(job)
vout = cfg_dep;
vout.sname      = 'Output File';
vout.src_output = substruct('()',{':'});