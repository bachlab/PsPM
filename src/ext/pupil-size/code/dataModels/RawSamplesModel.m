classdef RawSamplesModel < handle
    %PupilDataModel Data model for holding raw pupil diameter data.
    %
    % obj = RawSamplesModel(eye,hPupilDataModel)
    %
    %   This class hold raw and processed data, as well as analysis
    %   results, for one pupil diameter datafile.
    %
    %   Raw data, in its original form, consist of timestamped rows
    %   containing the left and/or right pupil diamters (and possibly other
    %   information that is out of the scope of this script).
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
        
        hPupilDataModel;
        eye;
        rawSample;
        isValid;
        speedFiltData;
        devFiltData;
        
    end
    
    properties (Dependent)
        t_ms;
        settings;
        diameterUnit
        filename;
    end
    
    
    %% Methods:
    
    methods
        
        %==================================================================
        function obj = RawSamplesModel(eye,hPupilDataModel,rawSamples)
            % Construct object, and save the eye label and a handle to its
            % parent model.
            %
            %--------------------------------------------------------------
            
            if nargin == 3
                obj.eye             = eye;
                obj.hPupilDataModel = hPupilDataModel;
                assert(length(rawSamples)==length(obj.t_ms)...
                    ,['Raw samples and time vectors must have equal'...
                    ' lengths.']);
                obj.rawSample       = rawSamples;
            end
            
        end
        
        
        %==================================================================
        function valOut = get.t_ms(obj)
            % Gets the t_ms vector from the parent.
            %
            %--------------------------------------------------------------
            
            valOut = obj.hPupilDataModel.timestamps_RawData_ms;
            
        end
        
        
        %==================================================================
        function valOut = get.diameterUnit(obj)
            % Gets diameterUnit from the parent.
            %
            %--------------------------------------------------------------
            
            valOut = obj.hPupilDataModel.diameterUnit;
            
        end
        
        
        %==================================================================
        function valOut = get.filename(obj)
            % Gets the filename from the parent.
            %
            %--------------------------------------------------------------
            
            valOut = obj.hPupilDataModel.filename;
            
        end
        
        
        %==================================================================
        function valOut = get.settings(obj)
            % Gets the settings from the parent.
            %
            %--------------------------------------------------------------
            
            if ~isempty(obj.hPupilDataModel)...
                    &&isfield(obj.hPupilDataModel.settings,'raw')
                valOut = obj.hPupilDataModel.settings.raw;
            else
                valOut = struct();
            end
        end
        
        
        %==================================================================
        function filterData(obj)
            % Runs the filter pipeline on the current raw dataset, see
            % rawDataFilter.m for details.
            %
            %--------------------------------------------------------------
            
            assert(~isempty(obj.settings),'No settings present.')
            if obj.settings.keepFilterData
                [obj.isValid,obj.speedFiltData,obj.devFiltData] ...
                    = rawDataFilter(...
                    obj.t_ms...
                    ,obj.rawSample...
                    ,obj.settings);
            else
                [obj.isValid,~,~] ...
                    = rawDataFilter(...
                    obj.t_ms...
                    ,obj.rawSample...
                    ,obj.settings);
            end
            
        end
        
        
        %==================================================================
        function hAxs = plotFilterSteps(obj,hTG,hAxs)
            % Plots the intermediate filter steps, if they are available.
            %
            %--------------------------------------------------------------
            
            if isempty(obj.speedFiltData)||isempty(obj.devFiltData)
                return
            end
            if nargin==2||isempty(hAxs)
                hAxs = obj.genAxes(hTG);
            end
            
            % Get the plotting style parameters:
            guiParams    = PupilDataModel.getPlotStyleParams();
            guiEyeParams = guiParams.(obj.eye);
            
            % Plot speed filter data:
            t = obj.t_ms/1000;
            legend(hAxs.speed.diamAxs,'show');
            plot(hAxs.speed.diamAxs,t,obj.rawSample...
                ,guiEyeParams.rawMarkerParams{:}...
                ,'Color',guiEyeParams.colorLight...
                ,'DisplayName'...
                ,[obj.eye ' Pupil: Filter input samples']);
            plot(hAxs.speed.diamAxs,t(obj.speedFiltData.isValid)...
                ,obj.rawSample(obj.speedFiltData.isValid)...
                ,guiEyeParams.accptdMarkerParams{:}...
                ,'Color',guiEyeParams.colorDark...
                ,'DisplayName'...
                ,[obj.eye ' Pupil: Samples accepted by current filter']);
            plot(hAxs.speed.filtAxs,t...
                ,obj.speedFiltData.maxDilationSpeeds...
                ,guiEyeParams.rawMarkerParams{:}...
                ,'Color',guiEyeParams.colorLight...
                ,'DisplayName'...
                ,[obj.eye ' Pupil: Sample dilation speed']);
            legend(hAxs.speed.filtAxs,'show');
            plot(hAxs.speed.filtAxs,t([1 end])...
                ,obj.speedFiltData.thresh ...
                * [1;1] ...
                ,guiParams.threshStyle{:}...
                ,'Color',guiEyeParams.colorDark...
                ,'DisplayName'...
                ,[obj.eye ' Pupil: Threshold']);
            
            % Plot the deviation filters:
            passCount = size(obj.devFiltData.isValidPerPass,2);
            for passIndx = 1:passCount
                curDiamAxs = hAxs.dev(passIndx).diamAxs;
                curFiltAxs = hAxs.dev(passIndx).filtAxs;
                plot(curDiamAxs,t(obj.speedFiltData.isValid)...
                    ,obj.rawSample(obj.speedFiltData.isValid)...
                    ,guiEyeParams.rawMarkerParams{:}...
                    ,'Color',guiEyeParams.colorLight...
                    ,'DisplayName'...
                    ,[obj.eye ...
                    ' Pupil: Raw samples after range and dev. filter.']);
                plot(curDiamAxs...
                    ,t(obj.devFiltData.isValidPerPass(:,passIndx))...
                    ,obj.rawSample(...
                    obj.devFiltData.isValidPerPass(:,passIndx))...
                    ,guiEyeParams.accptdMarkerParams{:}...
                    ,'Color',guiEyeParams.colorLight...
                    ,'DisplayName'...
                    ,[obj.eye ...
                    ' Pupil: Samples accepted by current filter']);
                plot(curDiamAxs...
                    ,t...
                    ,obj.devFiltData.smoothBaselinePerPass(:,passIndx)...
                    ,guiEyeParams.signalParams{:}...
                    ,'Color',guiEyeParams.colorDark...
                    ,'LineStyle','-'...
                    ,'DisplayName'...
                    ,[obj.eye ' Pupil: Smooth trendline']);
                plot(curFiltAxs,t...
                    ,obj.devFiltData.residualsPerPass(:,passIndx)...
                    ,guiEyeParams.rawMarkerParams{:}...
                    ,'Color',guiEyeParams.colorLight...
                    ,'DisplayName'...
                    ,[obj.eye ' Pupil: Deviation from smooth trendline']);
                legend(curDiamAxs,'show');
                legend(curFiltAxs,'show');
                plot(curFiltAxs,t([1 end])...
                    ,obj.devFiltData.threshPerPass(passIndx) ...
                    * [1;1] ...
                    ,guiParams.threshStyle{:}...
                    ,'Color',guiEyeParams.colorDark...
                    ,'DisplayName'...
                    ,[obj.eye ' Pupil: Threshold']);
                clear curDiamAxs curFiltAxs
            end
            
            
        end
        
        
        %==================================================================
        function hAxs = genAxes(obj,dataTabGroup)
            % Generates the axes for plotting the filter steps in.
            %
            %--------------------------------------------------------------
            
            % Get the plotting style parameters:
            guiParams = PupilDataModel.getPlotStyleParams();
            
            % Generate speed filter tab:
            hAxs.speed.tab = uitab(dataTabGroup...
                ,'Title','   Range and Speed Filter   ');
            if ~verLessThan('matlab','8.5')
                  set(hAxs.speed.tab ...
                    ,'BackgroundColor',[1 1 1]);
            end
            hAxs.speed.diamAxs = axes();
            set(hAxs.speed.diamAxs, 'Parent', hAxs.speed.tab...
                ,guiParams.axesParams{:}...
                ,'ActivePositionProperty', 'outerposition'...
                ,'position', [guiParams.axesLeftMargin 0.4 ...
                guiParams.axesWidth 0.5]...
                ,'XTickLabel','');
            hAxs.speed.filtAxs = axes();
            set(hAxs.speed.filtAxs, 'Parent', hAxs.speed.tab...
                ,guiParams.axesParams{:}...
                ,'ActivePositionProperty', 'outerposition'...
                ,'position',[guiParams.axesLeftMargin 0.15 ...
                guiParams.axesWidth 0.23]);
            hold(hAxs.speed.diamAxs,'on');
            hold(hAxs.speed.filtAxs,'on');
            t = obj.t_ms/1000;
            plot(hAxs.speed.diamAxs...
                ,t([1 end 1 1 end])...
                ,[obj.settings.PupilDiameter_Min...
                obj.settings.PupilDiameter_Min ...
                NaN obj.settings.PupilDiameter_Max...
                obj.settings.PupilDiameter_Max]...
                ,guiParams.threshStyle{:}...
                ,'Color',guiParams.rangeColor...
                ,'DisplayName'...
                ,['Acceptable range (' ...
                num2str(obj.settings.PupilDiameter_Min) ...
                ' to ' num2str(obj.settings.PupilDiameter_Max) ' ' ...
                obj.diameterUnit ')']);
            
            xlabel(hAxs.speed.filtAxs,'Time [s]')
            plotTitle = sprintf(['Speed Filter (%s)'...
                '\nTop: input and rejected samples'...
                '. Bottom: max. dilation speed and threshold.' ]...
                ,obj.filename);
            title(hAxs.speed.diamAxs,strrep(plotTitle,'_','\_'))
            ylabel(hAxs.speed.diamAxs,['Pupil Diameter [' ...
                obj.diameterUnit ']']);
            ylabel(hAxs.speed.filtAxs,['Max Speed ['...
                obj.diameterUnit '/ms]']);
            
            % Generate the deviation filter tabs:
            passCount = size(obj.devFiltData.isValidPerPass,2);
            
            for passIndx = 1:passCount
                
                % Generate current deviation tab:
                hAxs.dev(passIndx).tab = uitab(dataTabGroup...
                    ,'Title',['   Deviation Filter (pass ' ...
                    num2str(passIndx) ')   ']);
                if ~verLessThan('matlab','8.5')
                    set(hAxs.dev(passIndx).tab...
                        ,'BackgroundColor',[1 1 1]);
                end
                hAxs.dev(passIndx).diamAxs  = axes();
                set(hAxs.dev(passIndx).diamAxs ...
                    ,'Parent', hAxs.dev(passIndx).tab...
                    ,guiParams.axesParams{:}...
                    ,'ActivePositionProperty', 'outerposition'...
                    ,'position',[guiParams.axesLeftMargin 0.4 ...
                    guiParams.axesWidth 0.5]...
                    ,'XTickLabel','');
                hAxs.dev(passIndx).filtAxs = axes(); 
                set(hAxs.dev(passIndx).filtAxs...
                    ,'Parent',hAxs.dev(passIndx).tab...
                    ,guiParams.axesParams{:}...
                    ,'ActivePositionProperty', 'outerposition'...
                    ,'position',[guiParams.axesLeftMargin 0.15 ...
                    guiParams.axesWidth 0.23]);
                hold(hAxs.dev(passIndx).diamAxs,'on');
                hold(hAxs.dev(passIndx).filtAxs,'on');
                xlabel(hAxs.dev(passIndx).filtAxs,'Time [s]')
                plotTitle = sprintf(['Deviation Filter Pass '...
                    num2str(passIndx) ' (%s)'...
                    '\nTop: raw and rejected samples'...
                    '. Bottom: deviation from trend and threshold.' ]...
                    ,obj.filename);
                title(hAxs.dev(passIndx).diamAxs...
                    ,strrep(plotTitle,'_','\_'))
                ylabel(hAxs.dev(passIndx).diamAxs,['Pupil Diameter [' ...
                    obj.diameterUnit ']']);
                ylabel(hAxs.dev(passIndx).filtAxs,['Deviation ['...
                    obj.diameterUnit ']']);
            end
            
        end
        
    end
    
    
    %% Static Methods:
    
    methods (Static)
        
        %==================================================================
        function settingsOut = getDefaultSettings()
            % getDefaultSettings Returns the standard settings.
            %
            %    see rawDataFilter.m for details.
            %
            %--------------------------------------------------------------
            
            settingsOut = rawDataFilter();
            
        end
        
    end
    
    
end

