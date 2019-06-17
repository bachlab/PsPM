classdef PupilDataModel < handle
    %PupilDataModel Data model for holding pupil diameter data.
    %
    %   The PupilDataModel is the main class that the users should interact
    %   with, the standard usage pipeline consists of the following steps:
    %
    %    # Convert eye-tracker output to compatible mat files.
    %       > This class reads in a standard mat file that contains the
    %         pupil size data and metadata, as well as information about
    %         how to segments the recording into the desired sections.
    %         See RawFileModel.m for information.
    %
    %
    %    # Generating the PupilDataModel instances:
    %       > Constuct a single object via:
    %
    %          hPupilData = PupilDataModel(filepath,filename,settings)
    %
    %         where filepath and filename point to the mat file containing
    %         the raw data (see RawDataModel.m), and settings is a struct
    %         containing the settings to use when processing the data (see
    %         PupilDataModel/getDefaultSettings).
    %
    %       > Or, use the batch constructor method:
    %
    %          hPupilData = batchConstructor(filepath,dirStruct,settings)
    %
    %         See PupilDataModel/batchConstructor.
    %
    %
    %    # Processing the raw data:
    %       > Call the filterRawData() method on an object (or array) to
    %         process the raw data; i.e. the apply the filter steps
    %         described in the article and mark a subset of the raw data as
    %         'valid':
    %
    %          hPupilData.filterRawData();
    %
    %
    %    # Processing the valid data:
    %       > Call the processValidSamples() method on an object (or array)
    %         to process the raw samples marked as valid. These samples are
    %         used to create a smooth high-resolution pupil size signal
    %         through interpolation and low-pass filtering.
    %
    %          hPupilData.processValidSamples();
    %
    %
    %     # Analyze the processed data:
    %        > Call the analyzeSegments() method to extract descriptive
    %          statistics data from the processed samples, per segment:
    %
    %           results = hPupilData.analyzeSegments();
    %
    %          The analyzeSegments method analyzes either the sole
    %          available pupil, or both pupils and their mean, and
    %          horizontally concatenates the results, together with the
    %          segmentsData table, per PupilDataModel instance. The results
    %          are returned in the cell-array 'results'.
    %
    %
    %     # Visualize the data:
    %        > The data, including the intermediate filtering steps, can be
    %          visualized by calling the plotData method:
    %
    %           hPupilData.plotData()
    %
    %
    %     See the various examples for implementation details.
    %
    %----------------------------------------------------------------------
    %
    %   This code is part of the supplement material to the article:
    %
    %    Preprocessing Pupil Size Data. Guideline and Code.
    %     Mariska Kret & Elio Sjak-Shie. 2018.
    %
    %----------------------------------------------------------------------
    %
    %     Pupil Size Preprocessing Code (v1.1)
    %      Copyright (C) 2018  Elio Sjak-Shie
    %       E.E.Sjak-Shie@fsw.leidenuniv.nl.
    %
    %     This program is free software: you can redistribute it and/or
    %     modify it under the terms of the GNU General Public License as
    %     published by the Free Software Foundation, either version 3 of
    %     the License, or (at your option) any later version.
    %
    %     This program is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    %     General Public License for more details.
    %
    %     You should have received a copy of the GNU General Public License
    %     along with this program.  If not, see
    %     <http://www.gnu.org/licenses/>.
    %
    %----------------------------------------------------------------------
    
    
    %% Properties:
    
    properties
        
        % filename - filename of raw data mat file.
        filename                    = '';
        
        % filepath - path to raw data mat file.
        filepath                    = '';
        
        % settings - the settings used for processing the data.
        settings                    = struct();
        
        % eyesToUse - indicates which eyes contain diameter data, must be
        % {'left' 'right'}, {'left'} or {'right'} (or {}).
        eyesWithData                = {};
        
        % timestamps_RawData_ms - timestamps corresponding to the raw data
        % samples, see RawSamplesModel.m & RawFileModel.m.
        timestamps_RawData_ms       = [];
        
        % leftPupil_RawData - a handle to the left eye's RawSamplesModel
        % instance, RawSamplesModel.m.
        leftPupil_RawData           = [];
        
        % rightPupil_RawData - a handle to the right eye's RawSamplesModel
        % instance, RawSamplesModel.m.
        rightPupil_RawData          = [];
        
        % leftPupil_ValidSamples - The ValidSamplesModel instance for the
        % left eye, see ValidSamplesModel.m.
        leftPupil_ValidSamples      = [];
        
        % rightPupil_ValidSamples - The ValidSamplesModel instance for the
        % right eye, see ValidSamplesModel.m.
        rightPupil_ValidSamples     = [];
        
        % meanPupil_ValidSamples - The ValidSamplesModel instance for the
        % 'mean' pupil diameter instance, see ValidSamplesModel.m.
        meanPupil_ValidSamples      = [];
        
        % segmentsTable - a table containing the segmentation info, see
        % RawFileModel.m.
        segmentsTable               = [];
        
        % zeroTime_ms - a number indicating the eyetracker timestamp
        % corresponding to t=0, see RawFileModel.m.
        zeroTime_ms;
        
        % diameterUnit - a char array indicating the unit of the pupil size
        % data, see RawFileModel.m.
        diameterUnit;
        
    end
    
    
    %% Constructor Method:
    
    methods
        
        %==================================================================
        function obj = PupilDataModel(diameterUnit, diameter, segmentsTable, zeroTime_ms, settings)
            % Constructs a PupilDataModel instance given the filename,
            % filepath and settings.
            %
            %   obj = PupilDataModel(filepath,filename,settings)
            %
            %    To construct multiple objects, use the static batch
            %    constructor method.
            %
            %--------------------------------------------------------------

            check_inputs(diameter);

            obj.segmentsTable = table();
            obj.zeroTime_ms = 0;
            
            obj.diameterUnit   = diameterUnit;
            obj.timestamps_RawData_ms = diameter.t_ms;
            if ~isempty(diameter.L)
                obj.eyesWithData = {'left'};
                obj.leftPupil_RawData ...
                    = RawSamplesModel('left',obj,diameter.L);
            end
            if ~isempty(diameter.R)
                obj.eyesWithData = [obj.eyesWithData {'right'}];
                obj.rightPupil_RawData ...
                    = RawSamplesModel('right',obj,diameter.R);
            end
            
            if nargin > 2
                obj.segmentsTable  = segmentsTable;
            end
            if nargin > 3
                obj.zeroTime_ms    = zeroTime_ms;
            end
            if nargin > 4
                obj.settings = settings;
            end
        end
        
    end
    
    
    %% Get/Set and Check Methods:
    
    methods
        
        %==================================================================
        function set.eyesWithData(obj,valueIn)
            % Set method for eyesWithData.
            %
            %    The eyesWithData property must be one of the following:
            %      {'left' 'right'}, {'left'} or {'right'} (or {}).
            %
            %--------------------------------------------------------------
            
            assert(...
                isequal(valueIn,{'left' 'right'})...
                ||isequal(valueIn,{'left'})...
                ||isequal(valueIn,{'right'})...
                ||isequal(valueIn,{})...
                ,'Value not correct.')
            obj.eyesWithData = valueIn;
            
        end
        
        
        %==================================================================
        function checkScalarCall(obj)
            %checkScalarCall Checks if call was scalar.
            %
            %--------------------------------------------------------------
            
            keyboard;
            
            if ~isscalar(obj)
                error('This method is only suitable for scalar calls.')
            end
        end
        
    end
    
    
    %% Processing Methods:
    
    methods
        
        %==================================================================
        function filterRawData(objArray)
            %filterRawData Filters the raw data.
            %
            %   filterRawData(objArray)
            %
            %    objArray is PupilDataModel object or array.
            %
            %--------------------------------------------------------------
            
            % Print feedback:
            printToConsole('L1');
            printToConsole(2,...
                'Filtering the raw data in %i files...\n'...
                ,numel(objArray));
            
            % Loop through input objects:
            for curDataIndx = 1:numel(objArray)
                
                % Get current object:
                obj = objArray(curDataIndx);
                
                % Remove out of bounds samples, for all available eyes:
                for curEye = obj.eyesWithData
                    
                    % Print feedback:
                    printToConsole(3,'File %i (%s) %s eye:\n'...
                        ,curDataIndx,obj.filename,curEye{1});
                    
                    % Filter the current eye's data:
                    obj.([curEye{1} ...
                        'Pupil_RawData']).filterData();
                    
                end
            end
            
            % Print feedback:
            printToConsole(2,'Done\n');
            
        end
        
        
        %==================================================================
        function processValidSamples(objArray)
            %processValidSamples Processes the valid raw samples.
            %
            %   processValidSamples(objArray)
            %
            %    objArray is PupilDataModel object or array.
            %
            %--------------------------------------------------------------
            
            % Print feedback:
            printToConsole('L1');
            printToConsole(2,['Interpolating and smooting the'...
                ' valid raw data subsets of %i files...\n']...
                ,numel(objArray));
            
            % Loop through input objects:
            for curDataIndx = 1:numel(objArray)
                
                % Get handle to current file:
                obj = objArray(curDataIndx);
                
                % Print feedback:
                printToConsole(3,'File %i (%s):\n'...
                    ,curDataIndx,obj.filename);
                
                % Process eyes:
                for curEye = obj.eyesWithData
                    
                    % Initialize the data model, and set its properties:
                    validSampleRows = obj.([curEye{1} ...
                        'Pupil_RawData']).isValid;
                    samples.t_ms    = obj.timestamps_RawData_ms(...
                        validSampleRows);
                    samples.pupilDiameter ...
                        = obj.([curEye{1} 'Pupil_RawData']).rawSample(...
                        validSampleRows);
                    validFraction = sum(validSampleRows)...
                        /sum(~isnan(obj.([curEye{1} 'Pupil_RawData'])...
                        .rawSample));
                    obj.([curEye{1} 'Pupil_ValidSamples']) ...
                        = ValidSamplesModel(curEye{1},obj,samples...
                        ,validFraction);
                    
                    % Print feedback:
                    printToConsole(4,'%s eye done.\n'...
                        ,curEye{1});
                    
                    clear validSampleRows validFraction samples
                    
                end
                
                % If both eyes are present, generate the mean pupil
                % diameter sample timeseries:
                if length(obj.eyesWithData)==2
                    meanDia = ...
                        genMeanDiaSamples(obj.timestamps_RawData_ms...
                        ,obj.('leftPupil_RawData').rawSample...
                        ,obj.('rightPupil_RawData').rawSample...
                        ,obj.('leftPupil_RawData').isValid...
                        ,obj.('rightPupil_RawData').isValid...
                        );
                    validFraction ...
                        = min(...
                        obj.leftPupil_ValidSamples.validFraction...
                        ,obj.rightPupil_ValidSamples.validFraction);
                    samples.t_ms ...
                        = obj.timestamps_RawData_ms(~isnan(meanDia));
                    samples.pupilDiameter ...
                        = meanDia(~isnan(meanDia));
                    obj.meanPupil_ValidSamples ...
                        = ValidSamplesModel('mean',obj,samples...
                        ,validFraction);
                    printToConsole(4,'Mean pupil diameter done.\n');
                end
                
            end
            
            % Print feedback:
            printToConsole(2,'Done\n');
            printToConsole('L2');
            
        end
        
        
        %==================================================================
        function resultsCell = analyzeSegments(objArray)
            %analyzeSegments Analyzes the segmented data.
            %
            %   resultsCell = analyzeSegments(objArray)
            %
            %    objArray is PupilDataModel object or array.
            %
            %    resultsCell is a cell array with each cell containing the
            %    results table for the corresponding objects in the
            %    objArray.
            %
            %--------------------------------------------------------------
            
            % Print feedback:
            printToConsole('L1');
            printToConsole(2,'Analyzing %i files...\n'...
                ,numel(objArray));
            
            % Preallocate a struct for holding the results:
            resultsCell = cell(numel(objArray),1);
            
            % Loop through input objects:
            for curDataIndx = 1:numel(objArray)
                
                % Get handle to current file:
                obj = objArray(curDataIndx);
                
                % Print feedback:
                printToConsole(3 ...
                    ,'File %i (%s): analyzing %i segments.\n'...
                    ,curDataIndx,obj.filename,size(obj.segmentsTable,1));
                
                % Merge results, and save to master cell:
                resultsCell{curDataIndx} = obj.analyzeSegmentsScalar(...
                    obj.segmentsTable);
                
            end
            
            % Print feedback:
            printToConsole(2,'Done\n');
            printToConsole('L2');
            
        end
        
        
        %==================================================================
        function plotData(objArray)
            % plotData Plots data of one or more PupilDataModel objects.
            %
            %   plotData(objArray)
            %
            %    objArray is PupilDataModel object or array.
            %
            %--------------------------------------------------------------
            
            % Set the flag below to true to allow users to select multiple
            % files to plot. Note that plotting multiple files can be very
            % resource intensive, and is therefore dsiabled by default:
            plotMultipleFiles = false;
            
            % In any case, do not allow older MATLAB version to plot
            % multiple files. This requires nested tabs, which is
            % DISASTROUS in older MATLAB versions.
            if ~plotMultipleFiles || verLessThan('matlab','8.5')
                if numel(objArray)>1
                    selectIndx = listdlg('PromptString'...
                        ,{'Select file to plot:'},...
                        'SelectionMode','single',...
                        'ListString',{objArray.filename});
                    if isempty(selectIndx)
                        return
                    end
                    objArray = objArray(selectIndx);
                end
            else
                if numel(objArray)>1
                    selectIndx = listdlg('PromptString'...
                        ,{'Select files to plot:'},...
                        'SelectionMode','multiple',...
                        'ListString',{objArray.filename});
                    if isempty(selectIndx)
                        return
                    end
                    objArray = objArray(selectIndx);
                end
            end
            
            % Print feedback:
            printToConsole('L1');
            printToConsole(2,'Plotting data for %i files...\n'...
                ,numel(objArray));
            
            % Make figure:
            hFig = figure('Color',[1 1 1]);
            if numel(objArray)==1
                objArray.plotDataScalar(hFig);
                
                % Print feedback:
                printToConsole(3,'File 1 (%s): Done.\n'...
                    ,objArray.filename);
                
            else
                
                % Make tab group to handle the tabs:
                hTG  = uitabgroup(hFig);
                set(hTG,'TabLocation','Left');
                
                % Loop through input objects:
                for curDataIndx = 1:numel(objArray)
                    
                    % Get handle to current file:
                    obj = objArray(curDataIndx);
                    
                    % Create tab in figure:
                    curTab = uitab('Parent',hTG...
                        ,'Title',obj.filename,'BackgroundColor',[1 1 1]);
                    
                    % Run plot method:
                    obj.plotDataScalar(curTab);
                    
                    % Print feedback:
                    printToConsole(3,'File %i (%s): Done.\n'...
                        ,curDataIndx,obj.filename);
                    
                end
            end
            
            % Print feedback:
            printToConsole(2,'Done\n');
            printToConsole('L2');
            
        end
        
        
        %% Helper Functions:
        
        %==================================================================
        function plotDataScalar(obj,hParent)
            % plotDataScalar Plots a single object's data.
            %
            %--------------------------------------------------------------
            
            % Force scalar call:
            assert(isscalar(obj)...
                ,'This method can only be called with a scalar object.')
            
            % Raw time vector:
            Raw_t = obj.timestamps_RawData_ms/1000;
            
            % Generate figure format:
            dataTabGroup = uitabgroup(...
                uipanel('parent',hParent...
                ,'Position',[0.02 0.02 0.96 0.96]));
            
            % Generate Pupil Diameter Tab:
            hDiaTab = uitab(dataTabGroup,'Title','   Pupil Diameter   ');
            if ~verLessThan('matlab','8.5')
                set(hDiaTab,'BackgroundColor',[1 1 1]);
            end
            segmentsAxes = axes();
            set(segmentsAxes,'Parent',hDiaTab...
                ,obj.getPlotStyleParams.axesParams{:}...
                ,'ActivePositionProperty', 'outerposition'...
                ,'position',[obj.getPlotStyleParams.axesLeftMargin...
                0.83 obj.getPlotStyleParams.axesWidth 0.05]...
                ,'XTickLabel','','YTickLabel',''...
                ,'YGrid','off','YMinorGrid','off');
            diameterAxes = axes();
            set(diameterAxes,'Parent',hDiaTab...
                ,obj.getPlotStyleParams.axesParams{:}...
                ,'ActivePositionProperty', 'outerposition'...
                ,'position',[obj.getPlotStyleParams.axesLeftMargin...
                0.15 obj.getPlotStyleParams.axesWidth 0.66]);
            hold(segmentsAxes,'on');
            hold(diameterAxes,'on');
            xlabel(diameterAxes,'Time [s]')
            plotTitle = sprintf(...
                'Pupil Diameter Data (file: %s)'...
                ,obj.filename);
            title(segmentsAxes,strrep(plotTitle,'_','\_'));
            ylabel(diameterAxes,['Pupil Diameter [' ...
                obj.diameterUnit ']']);
            ylabel(segmentsAxes,'Segments');
            set(get(segmentsAxes,'YLabel')...
                ,'VerticalAlignment','middle'...
                ,'HorizontalAlignment','right','Rotation',0)
            for curEye = [obj.eyesWithData 'mean']
                
                plotStyle = obj.getPlotStyleParams.(curEye{1});
                
                % Plot raw samples:
                if ~strcmp(curEye,'mean')
                    % Plot raw samples:
                    hRaw = plot(diameterAxes,Raw_t...
                        ,obj.([curEye{1} 'Pupil_RawData']).rawSample...
                        ,plotStyle.rawMarkerParams{:}...
                        ,'Color',plotStyle.colorLight...
                        ,'DisplayName',[upper(curEye{1}(1)) ...
                        curEye{1}(2:end) ' pupil raw samples']);
                    uistack(hRaw,'bottom');
                    clear hRaw
                end
                
                % Plot signal:
                if ~isempty(obj.([curEye{1} 'Pupil_ValidSamples']))
                    plot(diameterAxes...
                        ,obj.([curEye{1} 'Pupil_ValidSamples']).signal.t...
                        ,obj.([curEye{1} 'Pupil_ValidSamples'])...
                        .signal.pupilDiameter...
                        ,plotStyle.signalParams{:}...
                        ,'Color',plotStyle.colorDark...
                        ,'DisplayName',[upper(curEye{1}(1)) ...
                        curEye{1}(2:end) ' pupil smooth signal']);
                end
            end
            
            hAxs = [];
            
            for curEye = obj.eyesWithData
                hAxs = obj.([curEye{1} 'Pupil_RawData'])...
                    .plotFilterSteps(dataTabGroup,hAxs);
            end
            
            legend(diameterAxes,'show');
            
            % Link axes and plot segments:
            linkaxes(findobj(hParent,'Type','Axes'),'x');
            if ~isempty(obj.segmentsTable.segmentStart)
                plotSegments(segmentsAxes,obj.segmentsTable);
            end
            
        end
        
        
        %==================================================================
        function analTableOut = analyzeSegmentsScalar(obj,segmentDataIn)
            % analyzeSegmentsScalar Analyzes a single object's segments.
            %
            %--------------------------------------------------------------
            
            assert(isscalar(obj)...
                ,'This method can only be called with a scalar object.')
            
            % Run analysis scripts:
            for curEye = {'left' 'right' 'mean'}
                if ~isempty(obj.([curEye{1} ...
                        'Pupil_ValidSamples']))
                    analtable.(curEye{1}) = obj.([curEye{1} ...
                        'Pupil_ValidSamples'])...
                        .analyze(segmentDataIn);
                    printToConsole(4,...
                        'Done analyzing %s pupil diameters.\n'...
                        ,curEye{1});
                else
                    analtable.(curEye{1}) = [];
                end
            end
            analTableOut = horzcat(segmentDataIn...
                ,analtable.left,analtable.right,analtable.mean);
            
        end
        
        
    end
    
    
    %% Static Methods:
    
    
    methods (Static)
        
        
        %==================================================================
        function hPupilData = batchConstructor(filepath,dirStruct,settings)
            % batchConstructor Constructs a PupilDataModel array.
            %
            %   hPupilData = batchConstructor(filepath,dirStruct,settings)
            %
            %    filepath is the path to the folder where the files are
            %    located.
            %
            %    dirStruct is a struct array containing the file names.
            %    Generate the dirStruct using the dir command, e.g.:
            %
            %       rawFiles = dir([folderName '*.mat']);
            %
            %       Note that the .mat files found by the dir function must
            %       comply with the specific requirements, see the
            %       RawFileModel class.
            %
            %    settings is a struct containing the settings to use when
            %    processing the files. Use the following command to
            %    generate a standard settings struct, which you can then
            %    modify is required:
            %
            %      settingsOut = PupilDataModel.getDefaultSettings();
            %
            %--------------------------------------------------------------
            
            % Disp information:
            nFiles = length(dirStruct);
            printToConsole('L1');
            printToConsole(1, 'Constructing %i Data Objects...\n'...
                ,nFiles);
            
            % Loop through files:
            hPupilDataC = cell(nFiles,1);
            for fileIndx = 1:nFiles
                hPupilDataC{fileIndx} = PupilDataModel(filepath...
                    ,dirStruct(fileIndx).name,settings);
                printToConsole(3,'File %i (%s): Object constructed.\n'...
                    ,fileIndx,dirStruct(fileIndx).name);
                
            end
            printToConsole(2, 'Done with folder.\n');
            printToConsole('L2');
            hPupilData = vertcat(hPupilDataC{:});
            
        end
        
        
        %==================================================================
        function settingsOut = getDefaultSettings()
            % getDefaultSettings Returns a struct containing stanadard
            % settings.
            %
            %   settingsOut = getDefaultSettings()
            %
            %    See the RawSamplesModel and ValidSamplesModel classes for
            %    info about their settings.
            %
            %--------------------------------------------------------------
            
            settingsOut.raw   = RawSamplesModel.getDefaultSettings();
            settingsOut.valid = ValidSamplesModel.getDefaultSettings();
            
        end
        
        
        %==================================================================
        function plotStyleParams = getPlotStyleParams()
            % getPlotStyleParams Returns plotting style parameters.
            %
            %--------------------------------------------------------------
            
            % Define plot style:
            plotStyleParams.axesWidth          = 0.8;
            plotStyleParams.axesLeftMargin     = 0.1;
            plotStyleParams.axesParams         = ...
                {'box','on'...
                ,'XGrid','on','XMinorGrid','on'...
                ,'Color',[0.97 0.97 0.97]...
                ,'YGrid','on','YMinorGrid','on'...
                ,'ActivePositionProperty','outerposition'};
            plotStyleParams.left.colorDark     = [200 50 35]/255;
            plotStyleParams.left.colorLight    = [200 158 153]/255;
            plotStyleParams.right.colorDark    = [30 120 50]/255;
            plotStyleParams.right.colorLight   = [117 132 120]/255;
            plotStyleParams.mean.colorDark     = [255 144 0]/255;
            plotStyleParams.left.rawMarkerParams = {...
                'LineStyle','none'...
                ,'Marker','d'...
                ,'MarkerSize',5 ...
                ,'LineWidth',1.5};
            plotStyleParams.left.accptdMarkerParams  = {...
                'LineStyle','none'...
                ,'Marker','o'...
                ,'MarkerSize',8 ...
                ,'LineWidth',1};
            plotStyleParams.right.rawMarkerParams = {...
                'LineStyle','none'...
                ,'Marker','square'...
                ,'MarkerSize',7 ...
                ,'LineWidth',1.5};
            plotStyleParams.right.accptdMarkerParams = {...
                'LineStyle','none'...
                ,'Marker','o'...
                ,'MarkerSize',8 ...
                ,'LineWidth',1};
            plotStyleParams.mean.rawMarkerParams = {...
                'LineStyle','none'...
                ,'Marker','o'...
                ,'MarkerSize',5 ...
                ,'LineWidth',1.5};
            plotStyleParams.left.signalParams = {...
                'LineStyle','-'...
                ,'LineWidth',1.5};
            plotStyleParams.right.signalParams = {...
                'LineStyle','-'...
                ,'LineWidth',1.5};
            plotStyleParams.mean.signalParams = {...
                'LineStyle','-'...
                ,'LineWidth',1.5};
            plotStyleParams.rangeColor     = [70 100 232]/255;
            plotStyleParams.madThreshColor = [1 1 1]/255;
            plotStyleParams.madColor       = [230 200 95]/255;
            plotStyleParams.threshStyle    = {'LineStyle','--'...
                ,'LineWidth',2};
            
        end
        
    end
    
end


function check_inputs(diameter)
    assert(all(ismember(fieldnames(diameter),{'t_ms' 'L' 'R'}))...
        ,['The diameter struct must contain the'...
        ' ''t_ms'', ''L'' and ''R'' fields.']);
    assert(isempty(diameter.t_ms)||isvector(diameter.t_ms)...
        ,'''t_ms'' must be a vector.');
    assert(isempty(diameter.L)||isvector(diameter.L)...
        ,'''L'' must be a vector, or be empty.');
    assert(isempty(diameter.R)||isvector(diameter.R)...
        ,'''R'' must be a vector, or be empty.');
    assert(isempty(diameter.L)||length(diameter.t_ms)==length(diameter.L)...
        ,['''L'' must be empty, or have the same'...
        ' length as ''t_ms''.']);
    assert(isempty(diameter.R)||length(diameter.t_ms)==length(diameter.R)...
        ,['''R'' must be empty, or have the same'...
        ' length as ''t_ms''.']);
    assert(isempty(diameter.t_ms)||issorted(diameter.t_ms)...
        ,'t_ms must be sorted!')
end
