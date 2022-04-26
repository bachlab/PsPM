function [sts, data]=pspm_get_hb(import)
% pspm_get_hb is a common function for importing heart beat data
%
% FORMAT:
% function [sts, data]= pspm_get_hb(import)
%               import: import job structure with mandatory fields 
%                  .data
%                  .marker ('timestamps', 'continuous')
%                  .sr (timestamps: timeunits in seconds, continuous: sample rate in 1/seconds)
%                  and optional fields
%                  .flank ('ascending', 'descending', 'both': optional field for
%                   continuous channels; default: both)
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id$
% $Rev$

% v004 02.09.2013 changed to 3.0 architecture
% v003 22.5.2010 changed to heart beat timestamps, no correction or
%                conversion during import (more general)
% v002 6.11.2009 added correction for pulserate
% v001 17.9.2009 Dominik R Bach

%% Initialise
global settings
if isempty(settings)
	pspm_init;
end
sts = -1;

% get data
% -------------------------------------------------------------------------
[bsts, import] = pspm_get_events(import);
if bsts~=1
    warning('ID:invalid_input', 'Call of pspm_get_events failed.'); return;
end
data.data = import.data;

% add header
% -------------------------------------------------------------------------
data.header.chantype = 'hb';
data.header.units = 'events';
data.header.sr = 1;
sts =1;
return;