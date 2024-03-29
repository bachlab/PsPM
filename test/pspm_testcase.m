classdef pspm_testcase < matlab.unittest.TestCase
  % ● Description
  % Parent class for pspm test cases. Implements some basic functions
  % such as ensuring that the ImportTestData direcotry is available.
  % ● Authorship
  % (C) 2017 Tobias Moser (University of Zurich)
  % Updated 2021 Teddy Chao (WCHN, UCL)
  methods(TestClassSetup)
    function setup_path(this)
      % using test data
      global testdatafolderpth
      if ~isempty(testdatafolderpth)
        cd(testdatafolderpth);
        return;
      end
      path = fileparts(mfilename('fullpath')); %Path of this class
      cd(path);
      cd ..
      d = dir;
      d = {d.name};
      %if ~any(strcmpi('ImportTestData', d))
      %    cd ..
      %    d = dir;
      %    d = {d.name};
      % The old code seems to go the upper level of folder to check
      % if there is the ImportTestData folder, but it should not be
      % encouraged, because all activities shall happen under the
      % folder of PsPM.
      if ~any(strcmpi('ImportTestData', d))
        if feature('ShowFigureWindows')
          msg = 'Couldn''t find the ImportTestData folder.';
          r = questdlg(msg, 'Warning', 'Select', 'Generate', 'Cancel', 'Generate');
          % r = menu(sprintf('Couldn''t find the ImportTestData folder.'), 'Select it', 'Generate it', 'Cancel');
          switch r
            case 'Select'
              [pathstr,folder] = fileparts(uigetdir(pwd, 'Couldn''t find the ImportTestData folder. Please select it...'));
              if strcmp(folder,'ImportTestData')
                testdatafolderpth = pathstr;
                cd(pathstr);
              else
                while ~strcmp(folder,'ImportTestData')
                  r = menu(sprintf('The name of the selected folder is not ''ImportTestData''. Please select the correct folder...'), 'Ok', 'Cancel');
                  if r~=1
                    return;
                  end
                  [pathstr,folder] = fileparts(uigetdir(pwd, 'Couldn''t find the ImportTestData folder. Please select it...'));
                  if strcmp(folder,'ImportTestData')
                    testdatafolderpth = pathstr;
                    cd(pathstr);
                    return;
                  end
                end
              end
            case 'Generate'
              mkdir 'ImportTestData'
            case 'Cancel'
              return
          end
        end
      end
    end
  end
end