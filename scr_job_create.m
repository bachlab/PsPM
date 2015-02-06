function job = scr_job_create(varargin)
% Create a standard SCRalyze job script from various UI functions
% FORMAT: job = scr_job_create(fname, varnames, functionargs)
% where varnames is a cell array of variable names, and function args are
% the corresponding variable values
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2009-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
% $Id: scr_job_create.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% v005 drb 30.07.2012 added cell/cell of char option (for 2-sample t-test
%                     in scr_con2), added time
% v004 drb 02.07.2012 changed output file dialogue
% v003 drb 23.08.2011 fixed bug in output header
% v002 drb 30.7.2010 added empty argument option
% v001 drb 3.11.2009

% initialise
% -------------------------------------------------------------------------
global settings
if isempty(settings), scr_init; end;


% check args
% -------------------------------------------------------------------------
if nargin < 3
    warning('Not enough arguments (must be 3 at least).'); return;
elseif numel(varargin{2}) ~= (nargin - 2)
    warning('Number of variables (%01.0f) and of variable names (%01.0f) does not match. ', nargin - 2, numel(varargin{2}));
end;

% general part
% -------------------------------------------------------------------------
c = clock;
job{1}='%-----------------------------------------------------------------------';
job{2}=['% Job script created by scr_job_create, ', date, sprintf('  %02.0f:%02.0f', c(4:5))];
job{3}='%-----------------------------------------------------------------------';
job{4}=' ';
job{5} = 'global settings';
job{6} = 'if isempty(settings), scr_init; end;';
lines = 7;

% job specific part
% -------------------------------------------------------------------------
for a = 3:nargin
    arg = varargin{a};
    argname = varargin{2}{a-2};
    if isempty(arg)
        job{lines} = sprintf('%s = [];', argname);
        lines = lines + 1;
    elseif isnumeric(arg)
        foo = sprintf('%s = [', argname);
        for k = 1:numel(arg)
            foo = [foo, sprintf('%g ', arg(k))];
        end;
        job{lines} = [foo(1:(end-1)), '];'];
        lines = lines + 1;
    elseif ischar(arg)
        job{lines} = sprintf('%s = ''%s'';', argname, arg);
        lines = lines + 1;
    elseif iscell(arg)
        for n = 1:numel(arg)
            if isnumeric(arg{n})
                foo = sprintf('%s{%1.0f} = [', argname, n);
                for k = 1:numel(arg{n})
                    foo = [foo, sprintf('%g ', arg{n}(k))];
                end;
                job{lines} = [foo(1:(end-1)), '];'];
                lines = lines + 1;
            elseif ischar(arg{n})
                job{lines} = sprintf('%s{%1.0f} = ''%s'';', argname, n, arg{n});
                lines = lines + 1;
            elseif iscell(arg{n})
                for m = 1:numel(arg{n})
                    if ischar(arg{n}{m})
                        job{lines} = sprintf('%s{%1.0f}{%1.0f} = ''%s'';', argname, n, m, arg{n}{m});
                        lines = lines + 1;
                    else
                        warning('Invalid job structure');
                    end;
                end;
            elseif isstruct(arg{n})
                fields = fieldnames(arg{n});
                for m = 1:numel(fields)
                    field = getfield(arg{n}, fields{m});
                    if isnumeric(field)
                        job{lines} = sprintf('%s{%1.0f}.%s = %g;', argname, n, fields{m}, field);
                        lines = lines + 1;
                    elseif ischar(field)
                        job{lines} = sprintf('%s{%1.0f}.%s = ''%s'';', argname, n, fields{m}, field);
                        lines = lines + 1;
                    elseif isstruct(field)
                        subfields = fieldnames(field);
                        for k = 1:numel(subfields)
                            subfield = getfield(field, subfields{k});
                            if isnumeric(subfield)
                                job{lines} = sprintf('%s{%1.0f}.%s.%s = %g;', argname, n, fields{m}, subfields{k}, subfield);
                                lines = lines + 1;
                            elseif ischar(field)
                                job{lines} = sprintf('%s{%1.0f}.%s.% = ''%s'';', argname, n, fields{m}, subfields{k}, subfield);
                                lines = lines + 1;
                            else
                                warning('Invalid job structure');
                            end;
                        end;
                    end;
                end;
            end;
        end;
    elseif isstruct(arg)
        fields = fieldnames(arg);
        for n = 1:numel(fields)
            field = getfield(arg, fields{n});
            if isnumeric(field)
                job{lines} = sprintf('%s.%s = %g;', argname, fields{n}, field);
                lines = lines + 1;
            elseif ischar(field)
                job{lines} = sprintf('%s.%s = ''%s'';', argname, fields{n}, field);
                lines = lines + 1;
            end;
        end;
    else
        warning('Invalid job structure');
    end;
end;
jobexec = sprintf('%s(', varargin{1});
for n = 1:numel(varargin{2})
    jobexec = sprintf('%s%s, ', jobexec, varargin{2}{n});
end;
jobexec = [jobexec(1:(end-2)), ');'];
job{lines} = jobexec;

% write job
% -------------------------------------------------------------------------
job=strvcat(job);
outfile=spm_input('Specify script file name:','+1','s');
[path, outfile, ext]=fileparts(outfile);
outfile=fullfile(path, [outfile, '.m']);
dlmwrite(outfile, job, 'delimiter', '');
