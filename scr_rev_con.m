function fighandle = scr_rev_con(model)
% scr_rev_con is a tool for reviewing contrasts of first level models
%
% FORMAT:
% scr_rev_con(modelfile)
%
% modelfile: filename and path of modelfile
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (UZH, WTCN)

% $Id: scr_rev_con.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% initialise
% ------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
fighandle = [];

% check input
% ------------------------------------------------------------------------
if nargin < 1, return; 
elseif ~isfield(model, 'con')
    fprintf('No contrasts contained in model.\n');
    return;
end;

% print contrast names to screen
% ------------------------------------------------------------------------
fprintf('Contrast names for %s:\n---------------------------------------\n', model.modelfile);
for n=1:numel(model.con)
    fprintf('Contrast %d: %s\n',n,model.con(n).name);
end;
fprintf('---------------------------------------\n');
