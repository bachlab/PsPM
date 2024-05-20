function [sts, import, sourceinfo] = pspm_get_acq_python(datafile, import)
% ● Description
%   pspm_get_acq is the main function for import of biopac/acknowledge files
% ● Format
%   [sts, import, sourceinfo] = pspm_get_acq(datafile, import);
%   this function uses the conversion routine acqread.m version 2.0 (2007-08-21)
%   by Sebastien Authier and Vincent Finnerty at the University of Montreal
%   which supports all files created with Windows/PC versions of
%   AcqKnowledge (3.9.0 or below), BSL (3.7.0 or below), and BSL PRO
%   (3.7.0 or below).
% ● Arguments
%   datafile: the acq data file
%     import: the struct for importing settings
%   .channel: data channels to be imported
%      .type: data channel types to be imported
%        .sr: sampling frequency
%      .data: imported data
%    .marker: imported markers
% ● History
%   Introduced in PsPM 6.1.2
%   Written in 2024 by Teddy

%% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','acq'));

%% load data but suppress output
[sts, data] = evalc('acqread_python(datafile)');
end
