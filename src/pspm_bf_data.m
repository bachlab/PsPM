function [bf, x] = pspm_bf_data(td)

% pspm_bf_data provides a generic interface for creating a user-defined
% response function from a data vector saved in a *.mat file. To use this
% function, the variables 'datafile' and 'sr' need to be hard-coded. GLM
% can then be called with the optional argument model.bf = 'pspm_bf_data'.
%
% FORMAT:
    % [bf, x]=pspm_bf_data(td)
%
%_________________________________________________________________________
% PsPM 5.1.1,
% 2021 Dominik R Bach (University College London)

% constants --- CHANGE THIS TO CREATE YOUR FUNCTION
datafile = ''; % this should be a *.mat file that contains a variable named 'data' with the data vector
sr = 0;        % this should be the sampling rate of your data vector

% check input arguments
if nargin==0
    errmsg='No sampling interval stated'; warning('ID:invalid_input', errmsg); return;
end

% load data
indata = load(datafile);
data = indata.data(:);

% determine original sampling points
x_old = - 1/(2*sr) + (1:numel(data))/sr;

% determine new sampling points
x = (td:td:(numel(data)/sr));

% resample
bf = interp1(x_old, data, x, 'nearest', 'extrap');

bf = [0; bf(:)];
x  = [0; x(:)];

return;
