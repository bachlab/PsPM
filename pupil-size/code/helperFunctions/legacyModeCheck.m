function legacyModeCheck()
% Add the table spoofer folder to the MATLAB path if this a version older
% than 8.3, which is when the table datatype was introduced. See files in
% .\LEGACY\ folder.

legacy_dir = fullfile('..', '..', 'helperFunctions', 'LEGACY');
if verLessThan('matlab','8.3')
    addpath(legacy_dir);
    uiwait(warndlg({['The script is running in legacy mode '...
        'because you are using an old MATLAB version.'] ...
        '' ['This means that the results will be of type "dataset"'...
        ' instead of "table".'] ''}...
        ,'LEGACY'));
    drawnow;
    
    % Disable warnings:
    warning('off','MATLAB:warn_r14_stucture_assignment');
    warning('off','MATLAB:linkaxes:RequireDataAxes');
    warning('off','MATLAB:schema:CannotSetBackgroundColor');
    warning('off','MATLAB:uitab:DeprecatedFunction');
    warning('off','MATLAB:uitabgroup:OldVersion');
    
else
    warning('off','MATLAB:rmpath:DirNotFound')
    rmpath(legacy_dir);
    warning('on','MATLAB:rmpath:DirNotFound');
end
end
