function [sts, v] = pspm_version(varargin)
% SCR_VERSION returns the current pspm version and checks if there is an
% update available.
%   
%   Note: The term 'version' is a reserved keyword and should not be used
%       in matlab without an according prefix, such as pspm_version etc.
%
%   Format:
%       [sts, v] = pspm_version()
%       [sts, v] = pspm_version(action)
%
%
%   Attributes:
%       action:         define an additional action. possible actions are:
%                           - 'check': checks if there is a new pspm 
%                               version available.
%__________________________________________________________________________
% PsPM 3.1
% (C) 2009-2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

%% start
% do not include pspm_init, because pspm_version is called by pspm_init!!!
% -------------------------------------------------------------------------
sts = -1;

%% load startup info file
% -------------------------------------------------------------------------
fid = fopen('pspm_msg.txt');
msg = textscan(fid, '%s', 'Delimiter', '$');
tk =regexp(msg{1},'^Version ([0-9A-Za-z\.]*) .*', 'tokens');
v_idx = find(~cellfun('isempty', tk), 1, 'first');
v = tk{v_idx}{1}{1};

%% check if there is an input action given
% -------------------------------------------------------------------------
if nargin > 0
    switch varargin{1}
        case 'check' % check for updates
            [str, status] = urlread('http://pspm.sourceforge.net/');
            if status == 1
                tk = regexpi(str, '<a.*href="http://sourceforge\.net/projects/pspm/files/PsPM_([0-9.]*)\.zip/download">', 'tokens');
                % use first found version
                if any(~cellfun('isempty', tk))
                    new_v = tk{1}{1};
                    
                    % compare versions
                    v_l = regexp(v, '\.', 'split');
                    new_v_l = regexp(new_v, '\.', 'split');
                    
                    comp_vers = zeros(max(numel(v_l), numel(new_v_l)),2);
                    comp_vers(1:numel(v_l), 1) = hex2dec(v_l);
                    comp_vers(1:numel(new_v_l), 2) = hex2dec(new_v_l);

                    d_v = diff(comp_vers, 1, 2);
                    
                    smaller = d_v < 0;
                    bigger = d_v > 0;

                    if any(smaller) && any(bigger)
                        new_version = find(smaller,1) > find(bigger,1);
                    else
                        new_version = any(bigger);
                    end

                    if new_version
                        % try to find url
                        tk = regexpi(str, '<a.*href="(http://sourceforge\.net/projects/pspm/files/PsPM_[0-9.]*\.zip/download)">', 'tokens');
                        download_url = tk{1}{1};
                        fprintf('New PsPM version available:\n');
                        fprintf('Current version: %s\n', v);
                        fprintf('Latest version: %s\n', new_v);
                        fprintf('Available here: %s\n', download_url);
                    end
                else
                    warning('ID:invalid_input', 'Cannot figure out if there is a new version.'); return;
                end
            else
                warning('ID:invalid_input', 'Cannot check for updates.'); return
            end
    end
end

sts = 1;
