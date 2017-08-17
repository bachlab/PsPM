function [sts, data] = pspm_pupil_transfer(data, transfer)
% pspm_pupil_transfer is a helper function for pspm_get_pupil_* functions
% which should take the input argument from the import transfer struct and
% transfers the input data according to the input transfer parameters.
%
% This function was made to avoid redundancies.
%
% The used formula is offset + multiplicator*data, where in the input
% offset corresponds to transfer.o and transfer.m.
%
% FORMAT: 
%   [sts, data] = pspm_pupil_transfer(data, transfer)
%
% ARGUMENTS: 
%           data:               a one dimensional vector containing the
%                               data to be transfered.
%           transfer:           The transfer params. Either 'none',
%                               'default', a path to a file or a struct. 
%                               If 'none', the data will not be transfered. 
%                               If 'default' the default values for 70 cm 
%                               screen-eye distance will be used. If a path 
%                               to a file is given, the file will be loaded 
%                               into transfer and will be treated equally. 
%                               If is a struct, 
%                               transfer.o will be taken as offset and
%                               transfer.m will be taken as multiplicator.

%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id: pspm_convert_au2mm.m 453 2017-07-04 08:50:18Z tmoser $
% $Rev: 453 $

sts = -1;

% assemble transfer params
if isstruct(transfer)
    tf.o = transfer.o;
    tf.m = transfer.m;
elseif ischar(transfer)
    if any(strcmpi(transfer, {'default', 'none'}))
        tf = {};
    else
        if exist(transfer, 'file')
            tf = load(transfer);
        else
            warning('ID:invalid_input', ['File (%s) containing ', ...
                'the transferparams was not found.'], import.transfer);
            return;
        end
    end
end

% transfer according to input
if isempty(tf) && strcmpi(transfer, 'default')
    [~, data] = pspm_convert_au2mm(data);
    [~, data] = pspm_convert_area2diameter(data);
elseif isstruct(tf)
    if isfield(tf, 'o') && isfield(tf, 'm')
        options = struct('offset', tf.o, 'multiplicator', tf.m);
        [~, data] = pspm_convert_au2mm(data, options);
        [~, data] = pspm_convert_area2diameter(data);
    else
        warning('ID:invalid_input', 'The given transferparams are incomplete!');
        return;
    end
end


sts = 1;

end