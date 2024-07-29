function [sts, import, sourceinfo] = pspm_get_csv(datafile, import)
% ● Description
%   pspm_get_csv is the main function for import of csv files,
%   it adds the comma delimiter to import channels and the runs pspm_get_txt
% ● Format
%   [sts, import, sourceinfo] = pspm_get_csv(datafile, import);
% ● Arguments
%   * datafile: a .csv or .txt file containing numerical data with comma
%               delimiter and optionally the channel names in the first line.
%   *   import: import job structure
%               A delimiter of ',' is applied to all import channels
% ● History
%   Introduced in PsPM 5.0
%   Written in 2008-2020 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

sts = -1;
import = cellfun(@(c) setfield(c, 'delimiter', ','), import, 'UniformOutput', false);
[sts_get_txt, import, sourceinfo] = pspm_get_txt(datafile, import);
if ~sts_get_txt
  warning('Failed to get text.');
  return
end
sts = 1;
return
