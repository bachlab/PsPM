function [sts, import, sourceinfo] = pspm_get_csv(datafile, import)
% pspm_get_csv is the main function for import of csv files,
% it adds the comma delimiter to import channels and the runs pspm_get_txt
%
% FORMAT: [sts, import, sourceinfo] = pspm_get_csv(datafile, import);
%       datafile:   a .csv or .txt file containing numerical data with comma delimiter
%                   and optionally the channel names in the first line.
%       import:     import job structure
%                   A delimiter of ',' is applied to all import channels
%               
%__________________________________________________________________________
% PsPM 5.0
% (C) 2008-2020 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id$
% $Rev$

import = cellfun(@(c) setfield(c, 'delimiter', ','), import, 'UniformOutput', false);
[sts, import, sourceinfo] = pspm_get_text(datafile, import);