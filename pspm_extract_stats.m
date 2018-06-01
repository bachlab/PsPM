function [sts, out_cond,out_vec] = pspm_extract_stats(varargin)

%   FORMAT:
%       [sts, segments] = pspm_extract_segments('manual', data_fn, chan, timing, segment_length, options)
%       [sts, segments] = pspm_extract_segments('auto', glm, segment_length, options)

%   ARGUMENTS:
%       mode:               Tells the function in which mode get the
%                           settings from. Either 'manual' or 'auto'.
%       glm:                Path to the glm file. 
%       data_fn:            Path or cell of paths to data files from which
%                           the segments should be extracted. Each file
%                           will be treated as session. Onset values are
%                           averaged through conditions and sessions.
%       chan:               Channel number or cell of channel numbers which
%                           defines which channel should be taken to
%                           extract the segments. Chan should correspond to
%                           data_fn and should have the same length. If
%                           data_fn is a cell and chan is a single number,
%                           the number will be taken for all files.
%       timing:             Either a cell containing the timing settings or
%                           a string pointing to the timing file.
%       segment_length:      Tells how long the segments need to be, on 
%                           on wich we want to applz staticstics on
%       options:
%           timeunit:       'seconds' (default), 'samples' or 'markers. In 'auto' 
%                           mode the value will be ignored and taken from 
%                           the glm model file.
%           length:         Length of the segments in the 'timeunits'. 
%                           If given always the same length is taken for 
%                           segments. Set by segment_length.
%           plot:           disabled
%           outputfile:     disabled
%           overwrite:      disabled
%           cutoff:         The maximum value a trial can reach to 
%                           to be evaluated statistically
%           marker_chan:    Mandatory if timeunit is 'markers'. For the
%                           function to find the appropriate timing of the
%                           specified marker ids. Must have the same format
%                           as data_fn.
%__________________________________________________________________________
% PsPM 3.1
% (C) 2008-2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end
sts = -1;
out = struct();

if nargin >= 2
    mode  = varargin{1};
    data_fn = varargin{2};
    switch varargin{1}
        case 'manual'
            if nargin  < 5 
                warning('ID:invalid_input', 'Mode ''auto'' expects at least 5 arguments.'); return;
            end
             
            segment_length = varargin{5};
            if(segment_length <= 0)
                warning('ID:invalid_input', 'data_fn has to be a string or a cell array of strings.'); return;
            end
            
            if nargin == 6
                options = varargin{6};
            else
                options = struct();
            end
            
            %set default length
            options.length = segment_length;

            %disable plot
            options.plot = 0;
    
            %disable overwrite 
            options.overwrite = 0;
           
            chan = varargin{3};
            timing = varargin{4};
            
            
            [sts1, segment] = pspm_extract_segments(mode, data_fn,chan, timing, options);
            
       case 'auto'
  
            if nargin < 3
                warning('ID:invalid_input', 'Mode ''auto'' expects at least 3 arguments.'); return;
            end
            
            segment_length = varargin{3};
            if(segment_length <= 0)
                warning('ID:invalid_input', 'data_fn has to be a string or a cell array of strings.'); return;
            end
            
            if nargin == 4
                options = varargin{4};
            else
                options = struct();
            end
           
            %set default length
            options.length = segment_length;

            %disable plot
            options.plot = 0;
    
            %disable overwrite 
            options.overwrite =0;
            
            [sts1, segment] = pspm_extract_segments(mode, data_fn, options);
            
    end
    
    if ~isfield(options, 'cutoff')
         options.cutoff = 100;
    else
        if ~isnumeric(options.cutoff)
            warning('ID:invalid_input', 'option cutoff not numeric'); return;
        end
    end
    
    if ~isfield(options, 'stats')
        options.stats = 'nan_percent';
    end
    
    %create function variable with appropriate options.stats
    switch options.stats
        case 'mean'
            stat_fun=@mean;
        case 'max'
            stat_fun=@max;
        case 'min'
            stat_fun=@min;
        case 'nan_percent'
            stat_fun=@pspm_nan_percent; %function calculates the perscent of nan in matrix
        otherwise 
            if ~is(options.stats,'function_handle')
                warning('ID:invalid_input', 'option stat is not a function'); return;
            end
            
            stat_fun = options.stats;
    end
    %function gets 
    d = cellfun(@(x) x.data, segment.segments, 'un', 0);
    function_on_trails = cellfun(stat_fun, d, 'un', 0);
    evaluated_conditions = cellfun(stat_fun, function_on_trails, 'un', 0);
    cutoff_vec = evaluated_conditions < options.cutoff;
    out_cond = evaluated_conditions; 
    out_vec = cutoff_vec;
else
        warning('ID:invalid_input', 'The function expects at least 2 parameters.'); return;
end


