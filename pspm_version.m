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

% $Id: $
% $Rev: $

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
            [data] = webread('https://sourceforge.net/projects/pspm/best_release.json');
            if isfield(data, 'release') && isfield(data.release, 'filename')
                tk = regexpi(data.release.filename, '/?PsPM_([0-9.]*)\.zip', 'tokens');
                % use first found version
                if any(~cellfun('isempty', tk))
                    new_v = tk{1}{1};
                    
                    % compare versions
                    v_l = regexp(v, '\.', 'split');
                    new_v_l = regexp(new_v, '\.', 'split');
                    
                    steps = min(numel(v_l), numel(new_v_l));
                    i = 1;
                    new_version = false;
                    v_equal = true;
                    while i <= steps && ~new_version
                        new_version = hex2dec(new_v_l(i)) > hex2dec(v_l(i));
                        v_equal = v_equal && (hex2dec(new_v_l(i)) == hex2dec(v_l(i)));
                        i = i + 1;
                    end;
                    
                    new_version = new_version || (v_equal && (numel(new_v_l) > numel(v_l)));
                    
                    if new_version
                        % try to find url
                        tk = regexpi(str, '"url": "([\w.:/_-]*)"', 'tokens');
                        download_url = tk{1}{1};
                        fprintf('New PsPM version available:\n');
                        fprintf('Current version: %s\n', v);
                        fprintf('Latest version: %s\n', new_v);
                        fprintf('Available here: %s\n', download_url);
                    end;
                else
                    warning('ID:invalid_input', 'Cannot figure out if there is a new version.'); return;
                end;
            else
                warning('ID:invalid_input', 'Cannot check for updates.'); return;
            end;
    end;       
end;

sts = 1;