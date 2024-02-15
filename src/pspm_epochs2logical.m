function index = pspm_epochs2logical(epochs, datalength, sr)
% ● Description
%   pspm_epochs2logical converts a nx2 (onset/offset) missing epoch matrix 
%   into a logical index of length datalength
%   The function does not check the integrity of the epoch definition (use
%   pspm_get_timing for some basic checks). This is an internal function
%   with no input checks.
% ● Format
%   index = pspm_epochs2logical(epochs, datalength, sr)
% ● Arguments
%           epochs:     nx2 (onset/offset) missing epoch matrix
%           datalength: length of the resulting logical index
%           sr: if epochs are specified in seconds: sample rate
%               if epochs are specified in terms of data samples: 1
% ● Output
%          index: [logical] index
% ● History
%   Introduced in PsPM 6.2
%   Written in 2024 by Dominik Bach (Uni Bonn)

if nargin > 2 
    epochs = pspm_time2index(epochs, sr);
end

index = zeros(datalength, 1);
if ~isempty(epochs)
    for k = 1:size(epochs, 1)
        flanks = round(epochs(k,:));
        index(flanks(1):flanks(2)) = 1;
        index = index(1:datalength)
    end
end