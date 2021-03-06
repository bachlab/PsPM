function varargout = pspm_display(varargin)
    % -------------------------------------------------------------------------

    % pspm_display (...)
    %
    %   Code for the GUI that is used to display different data from scr
    %   datafiles.
    %   Accepts input: 'filepath/filename'
    %
    %__________________________________________________________________________
    % PsPM 3.0
    % (C) 2013 Philipp C Paulus
    % (Technische Universitaet Dresden)
    %
    % v0.1 - Jan-2014
    % v0.2 - Apr-2014
    % v0.3 - Jun-2014: shortcuts added, small bugfixes
    % Last Modified by GUIDE v2.5 08-Jul-2021 03:27:10

    % Updated 5 July 2021 by Teddy

    % initialise
    % -------------------------------------------------------------------------
    global settings;
    if isempty(settings)
        pspm_init;
    end
    global channel_type_reference_list;
    channel_type_reference_list = settings.chantypes;
    % -------------------------------------------------------------------------

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @pspm_display_OpeningFcn, ...
    'gui_OutputFcn',  @pspm_display_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end


% --- Executes just before pspm_display is made visible.
function pspm_display_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   unrecognized PropertyName/PropertyValue pairs from the
    %            command line (see VARARGIN)

    % ---initialise------------------------------------------------------------

    global settings;
    if isempty(settings)
        pspm_init;
    end

    % load chantypes from settings variable

    j=1 ; l=1;
    for k=1:length(settings.chantypes)
        if strcmp(settings.chantypes(k).data,'wave')
            handles.prop.setwave{j}=settings.chantypes(k).type;
            j=j+1;
        elseif strcmp(settings.chantypes(k).data,'events')
            handles.prop.setevent{l}=settings.chantypes(k).type;
            l=l+1;
        end
    end


    % -------------------------------------------------------------------------


    pspm_ui(hObject, handles, 'display');

    if(numel(varargin)) == 1
        if iscell(varargin{1,1})
            filename=varargin{1,1}{1};
        else
            filename=varargin{1,1};
        end
        [~, info, handles.data, ~]=pspm_load_data(filename,0);

        update_summary_list(handles, filename);

        %     % handles.text_file_summary = filename;
        %     text_file_summary = ['Data source: ', filename, newline, newline, ...
        %         'Duration: ', num2str(info.duration), newline,...
        %         'Import date: ', info.importdate, newline, ...
        %         'Position of marker: ', num2str(filestruct.posofmarker)];
        %     set(handles.text_file_summary, 'String', text_file_summary);

        guidata(hObject, handles);

        % ---add text to wave listbox--------------------------------------

        listitems{1,1}='none';
        handles.prop.wavechans(1)=0;
        j=2;
        for k=1:length(handles.data)
            if any(strcmp(handles.data{k,1}.header.chantype,handles.prop.setwave))
                listitems{j,1}=handles.data{k,1}.header.chantype;
                handles.prop.wavechans(j)=k;
                j=j+1;
            end
        end

        set(handles.list_wave_channel,'String',listitems);
        clear listitems

        % ---add text to event listbox & activate additional options-------
        listitems{1,1}='none';
        handles.prop.eventchans(1)=0;
        j=2;
        for k=1:length(handles.data)
            if any(strcmp(handles.data{k,1}.header.chantype,handles.prop.setevent))
                listitems{j,1}=handles.data{k,1}.header.chantype;
                handles.prop.eventchans(j)=k;
                j=j+1;
                set(handles.option_integrated,'Enable','on');
                set(handles.option_extra,'Enable','on');
            end
        end

        set(handles.list_event_channel,'String',listitems);
        set(handles.button_autoscale,'Value',0);
        set(handles.button_all,'Value',1);

    elseif numel(varargin)>1 ; warning('too many input arguments. Inputs 2:end ignored. ') ;
    end

    % Choose default command line output for pspm_display
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes pspm_display wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = pspm_display_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end


% --- Executes on button press in push_next.
function push_next_Callback(hObject, eventdata, handles)
    % hObject    handle to push_next (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    x1=str2num(get(handles.ed_start_x,'String'));
    x2=str2num(get(handles.ed_winsize_x,'String'));

    y=get(handles.display_plot,'YLim');

    x1=x1+x2; x2=x1+x2;

    axis([x1 x2 y(1) y(2)])

    set(handles.ed_start_x,'String',num2str(x1));
    set(handles.ed_y_min,'String',num2str(y(1)));
    set(handles.ed_y_max,'String',num2str(y(2)));

    set(handles.button_all,'Value',0);
end


% --- Executes on button press in push_back.
function push_back_Callback(hObject, eventdata, handles)
    % hObject    handle to push_back (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)


    x1=str2num(get(handles.ed_start_x,'String'));
    x2=str2num(get(handles.ed_winsize_x,'String'));

    x1=x1-x2; x2=x1+x2;

    set(handles.ed_start_x,'String',num2str(x1));

    y=get(handles.display_plot,'YLim');

    axis([x1 x2 y(1) y(2)])

    set(handles.ed_start_x,'String',num2str(x1));
    set(handles.ed_y_min,'String',num2str(y(1)));
    set(handles.ed_y_max,'String',num2str(y(2)));

    set(handles.button_all,'Value',0);
end

% --- Executes on button press in option_extra.
function option_extra_Callback(hObject, eventdata, handles)
    % hObject    handle to option_extra (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of option_extra
    status=get(handles.option_extra,'Value');
    if status==1
        set(handles.option_integrated,'Value',0)
    elseif status==0
        set(handles.option_integrated,'Value',1)
    end

    % -------------------------------------------------------------------------
    % Update handles structure
    guidata(hObject, handles);
    % -------------------------------------------------------------------------
end

% --- Executes on button press in radio_hb.
function radio_hb_Callback(hObject, eventdata, handles)
    % hObject    handle to radio_hb (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of radio_hb
end


% --- Executes on button press in radio_integrated.
function radio_integrated_Callback(hObject, eventdata, handles)
    % hObject    handle to radio_integrated (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of radio_integrated
end


function ed_winsize_x_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_winsize_x (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of ed_winsize_x as text
    %        str2double(get(hObject,'String')) returns contents of ed_winsize_x as a double
    x1=str2num(get(handles.ed_start_x,'String'));

    x2=str2num(get(handles.ed_winsize_x,'String'))+x1;

    y1=str2num(get(handles.ed_y_min,'String'));
    y2=str2num(get(handles.ed_y_max,'String'));

    if y1 >= y2
        warning(sprintf(' Ymin ( current input: %d ) must be smaller than Ymax ( current input: %d ) ! ',y1,y2));
    else
        axis([x1 x2 y1 y2])
    end

    set(handles.button_autoscale,'Value',0);
    set(handles.button_all,'Value',0);
end

% --- Executes during object creation, after setting all properties.
function ed_winsize_x_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_winsize_x (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function ed_y_min_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_y_min (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of ed_y_min as text
    %        str2double(get(hObject,'String')) returns contents of ed_y_min as a double
    x1=str2num(get(handles.ed_start_x,'String'));
    x2=str2num(get(handles.ed_winsize_x,'String'))+x1;

    y1=str2num(get(handles.ed_y_min,'String'));
    y2=str2num(get(handles.ed_y_max,'String'));

    if y1 >= y2
        warning(sprintf(' Ymin ( current input: %d ) must be smaller than Ymax ( current input: %d ) ! ',y1,y2));
    else
        axis([x1 x2 y1 y2])
    end

    set(handles.button_autoscale,'Value',0);
    set(handles.button_all,'Value',0);
end

% --- Executes during object creation, after setting all properties.
function ed_y_min_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_y_min (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function ed_start_x_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_start_x (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of ed_start_x as text
    %        str2double(get(hObject,'String')) returns contents of ed_start_x as a double
    x1=str2num(get(handles.ed_start_x,'String'));
    x2=str2num(get(handles.ed_winsize_x,'String'))+x1;

    y1=str2num(get(handles.ed_y_min,'String'));
    y2=str2num(get(handles.ed_y_max,'String'));

    if y1 >= y2
        warning(sprintf(' Ymin ( current input: %d ) must be smaller than Ymax ( current input: %d ) ! ',y1,y2));
    else
        axis([x1 x2 y1 y2])
    end
    set(handles.button_autoscale,'Value',0);
    set(handles.button_all,'Value',0);
end

% --- Executes during object creation, after setting all properties.
function ed_start_x_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_start_x (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in button_autoscale.
function button_autoscale_Callback(hObject, eventdata, handles)
    % hObject    handle to button_autoscale (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)


    axis('auto')
    y=get(handles.display_plot,'ylim');
    x=str2num(get(handles.ed_start_x,'String'));

    x(2)=x(1)+15;


    axis([x(1) x(2) y(1) y(2)])

    set(handles.ed_start_x,'String',num2str(x(1)));
    set(handles.ed_winsize_x,'String',num2str(x(2)-x(1)));
    set(handles.ed_y_min,'String',num2str(y(1)));
    set(handles.ed_y_max,'String',num2str(y(2)));
    set(handles.button_all,'Value',0);
end


% --- Executes on button press in button_all.
function button_all_Callback(hObject, eventdata, handles)
    % hObject    handle to button_all (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    axis('auto');

    y=get(handles.display_plot,'ylim');
    x=get(handles.display_plot,'xlim');

    set(handles.ed_start_x,'String',num2str(x(1)));
    set(handles.ed_winsize_x,'String',num2str(x(2)-x(1)));
    set(handles.ed_y_min,'String',num2str(y(1)));
    set(handles.ed_y_max,'String',num2str(y(2)));
    set(handles.button_autoscale,'Value',0);
end

% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
    % hObject    handle to file (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function load_Callback(hObject, eventdata, handles)
    % hObject    handle to load (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % -------------------------------------------------------------------------

    wd=cd;
    typ='mat';
    sel=[];
    mesg='select pspm_datafiles to display';

    [filename,sts]=spm_select(1,typ,mesg,sel,wd);

    if not(sts==0)

        [~, info, handles.data, ~]=pspm_load_data(filename,0);
        update_summary_list(handles, filename);

        guidata(hObject, handles);

        % ---set wave and event channel value to none ---------------------
        handles.prop.wave='none';
        set(handles.list_wave_channel,'Value',1)

        handles.prop.event='none';
        set(handles.list_event_channel,'Value',1)

        % ---add text to wave listbox--------------------------------------

        listitems{1,1}='none';
        handles.prop.wavechans(1)=0;
        j=2;
        for k=1:length(handles.data)
            if any(strcmp(handles.data{k,1}.header.chantype,handles.prop.setwave))
                listitems{j,1}=handles.data{k,1}.header.chantype;
                handles.prop.wavechans(j)=k;
                j=j+1;
            end
        end

        set(handles.list_wave_channel,'String',listitems);
        clear listitems

        % ---add text to event listbox & activate additional options-------
        listitems{1,1}='none';
        handles.prop.eventchans(1)=0;
        j=2;
        for k=1:length(handles.data)
            if any(strcmp(handles.data{k,1}.header.chantype,handles.prop.setevent))
                listitems{j,1}=handles.data{k,1}.header.chantype;
                handles.prop.eventchans(j)=k;
                j=j+1;
                set(handles.option_integrated,'Enable','on');
                set(handles.option_extra,'Enable','on');
            end
        end

        set(handles.list_event_channel,'String',listitems);
        set(handles.button_autoscale,'Value',0);
        set(handles.button_all,'Value',1);

    elseif numel(varargin)>1 ; warning('too many input arguments. Inputs 2:end ignored. ') ;
    end

    % Update handles structure
    guidata(hObject, handles);
end
% --------------------------------------------------------------------
function saveas_Callback(hObject, eventdata, handles)
    % hObject    handle to saveas (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    y=get(handles.display_plot,'ylim');
    x=get(handles.display_plot,'xlim');

    [filename,pathname]=uiputfile({'*.jpg';'*.tif';'*.png';'*.gif';'*.bmp'},'Save Image');

    screen_size = get(0, 'ScreenSize');
    savename=sprintf('%s%s',pathname,filename);
    q=figure('Visible','Off');
    set(q, 'Position', [0 0 screen_size(3) screen_size(4) ] );
    pp_plot(handles);
    axis([x(1) x(2) y(1) y(2)]);

    % save the image as PNG
    saveas(q,savename);
    %imwrite(q,savename);
    close(q)
end
% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
    % hObject    handle to exit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    close(gcbf);
end

% --- Executes during object creation, after setting all properties.
function display_plot_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to display_plot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: place code in OpeningFcn to populate display_plot
end

% --- Executes during object creation, after setting all properties.
function panel_wave_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to panel_wave (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
end

% --- Executes when selected object is changed in panel_wave.
function panel_wave_SelectionChangeFcn(hObject, eventdata, handles)
    % hObject    handle to the selected object in panel_wave
    % eventdata  structure with the following fields (see UIBUTTONGROUP)
    %	EventName: string 'SelectionChanged' (read only)
    %	OldValue: handle of the previously selected object or empty if none was selected
    %	NewValue: handle of the currently selected object
    % handles    structure with handles and user data (see GUIDATA)



    status0=get(handles.radio_wnone,'Value');
    status1=get(handles.radio_scr,'Value');
    status2=get(handles.radio_ecg,'Value');
    status3=get(handles.radio_hr,'Value');
    status4=get(handles.radio_hp,'Value');
    status5=get(handles.radio_pupil,'Value');
    status6=get(handles.radio_emg,'Value');
    status7=get(handles.radio_resp,'Value');

    set(handles.button_autoscale,'Enable','on');
    set(handles.button_all,'Enable','on');

    if status0== 1
        handles.prop.wave='none';
        set(handles.radio_hb,'Enable','on');
        set(handles.button_autoscale,'Enable','off');
        set(handles.button_all,'Enable','off')
        set(handles.radio_integrated,'Enable','off')
    elseif status1 == 1
        handles.prop.wave='scr';
    elseif status2 == 1
        handles.prop.wave='ecg';
    elseif status3 == 1
        handles.prop.wave='hr';
    elseif status4==1
        handles.prop.wave='hp';
    elseif status5==1
        handles.prop.wave='pupil';
    elseif status6==1
        handles.prop.wave='emg';
    elseif status7==1
        handles.prop.resp='resp';
    end

    if ~(strcmp(handles.prop.wave,'ecg')) && strcmp(handles.prop.event,'hb')
        handles.prop.event='extra';
        set(handles.option_extra,'Value',1)
    end

    if status0==0
        set(handles.radio_integrated,'Enable','on') ;
    end

    guidata(hObject, handles);
    pp_plot(handles);

    set(handles.button_autoscale,'Value',0);
    set(handles.button_all,'Value',1);
end

% --- Executes when selected object is changed in panel_event.
function panel_event_SelectionChangeFcn(hObject, eventdata, handles)
    % hObject    handle to the selected object in panel_event
    % eventdata  structure with the following fields (see UIBUTTONGROUP)
    %	EventName: string 'SelectionChanged' (read only)
    %	OldValue: handle of the previously selected object or empty if none was selected
    %	NewValue: handle of the currently selected object
    % handles    structure with handles and user data (see GUIDATA)

    status0=get(handles.radio_enone,'Value');
    status1=get(handles.option_extra,'Value');
    status2=get(handles.radio_integrated,'Value');
    status3=get(handles.radio_hb,'Value');


    if status0 == 1
        handles.prop.event='none';
    elseif status1 == 1
        handles.prop.event='extra';
    elseif status2 == 1
        handles.prop.event='integrated';
    elseif status3 == 1
        handles.prop.event='hb';
    end



    guidata(hObject, handles);
    pp_plot(handles);

    set(handles.button_autoscale,'Value',0);
    set(handles.button_all,'Value',1);
end


% --- Executes on button press in radio_wnone.
function radio_wnone_Callback(hObject, eventdata, handles)
    % hObject    handle to radio_wnone (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of radio_wnone
end


function ed_y_max_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_y_max (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of ed_y_max as text
    %        str2double(get(hObject,'String')) returns contents of ed_y_max as a double

    x1=str2num(get(handles.ed_start_x,'String'));
    x2=str2num(get(handles.ed_winsize_x,'String'))+x1;

    y1=str2num(get(handles.ed_y_min,'String'));
    y2=str2num(get(handles.ed_y_max,'String'));

    if y1 >= y2
        warning(sprintf(' Ymin ( current input: %d ) must be smaller than Ymax ( current input: %d ) ! ',y1,y2));
    else
        axis([x1 x2 y1 y2])
    end

    set(handles.button_autoscale,'Value',0);
    set(handles.button_all,'Value',0);
end

% --- Executes during object creation, after setting all properties.
function ed_y_max_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_y_max (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%% pp_plot

function [info]=pp_plot(handles)
    % ---header----------------------------------------------------------------

    %       handles.name ... filename
    %       prop... struct with fields
    %               .wave (channel number)
    %               .event(channel number)
    %
    % ---Initialise------------------------------------------------------------
    marker=[];
    hbeat=[];
    events=[]; % any other marker channels
    wave=[];

    % get eventchan info
    if not(isempty(handles.prop.eventchans)) && not(handles.prop.eventchans(handles.prop.idevent)==0) &&  strcmp(handles.data{handles.prop.eventchans(handles.prop.idevent),1}.header.chantype,'marker')
        marker=handles.data{handles.prop.eventchans(handles.prop.idevent),1}.data;
        if get(handles.option_extra,'Value')==1
            handles.prop.event='extra';
        else
            handles.prop.event='integrated';
        end
    elseif not(isempty(handles.prop.eventchans)) && not(handles.prop.eventchans(handles.prop.idevent)==0) && strcmp(handles.data{handles.prop.eventchans(handles.prop.idevent),1}.header.chantype,'hb')
        hbeat=handles.data{handles.prop.eventchans(handles.prop.idevent),1}.data;
        if get(handles.option_extra,'Value')==1
            handles.prop.event='extra';
        else
            handles.prop.event='integrated';
        end
    elseif not(isempty(handles.prop.eventchans)) && not(handles.prop.eventchans(handles.prop.idevent)==0)
        events=handles.data{handles.prop.eventchans(handles.prop.idevent),1}.data;
        if get(handles.option_extra,'Value')==1
            handles.prop.event='extra';
        else
            handles.prop.event='integrated';
        end
    end

    % get wave chan info
    if not(handles.prop.wavechans(handles.prop.idwave)==0)
        wave=handles.data{handles.prop.wavechans(handles.prop.idwave),1}.data;
        sr.wave=handles.data{handles.prop.wavechans(handles.prop.idwave),1}.header.sr;
    end

    %   plotting if no channel is selected
    % -------------------------------------------------------------------------
    if isempty(marker) && isempty(wave) && isempty(hbeat) && isempty(events)
        hold off
        x=1;
        y=1;
        plot(x);
        text(x,y,'   nothing to display - please select channel   ','FontSize',20,'BackgroundColor','k',...
        'Color','w','HorizontalAlignment','Center','VerticalAlignment',...
        'Middle')
    elseif not(isempty(marker)) || not(isempty(wave)) || not(isempty(hbeat)) || not(isempty(events))

        % ---prepare ecg-----------------------------------------------------------
        if not(isempty(handles.prop.wave))  % only if there is wave info

            switch handles.prop.wave
            case 'ecg'
            case 'hr'
            case 'hp'
            case 'scr'
            case 'pupil'
            case 'emg'
            case 'resp'
            end

        end

        %   plotting if both event and wave channel are selected
        % -------------------------------------------------------------------------
        % plotting data against sr corrected time
        if not(isempty(wave)) % && (not(isempty(marker)) || not(isempty(hbeat)))

            y=zeros(size(wave));

            y=(0:1/sr.wave:(length(wave)/sr.wave));
            y=y';
            y=y(1:size(wave,1),1:size(wave,2));

            y=y(1:size(wave,1),1);
            % ---plot wave channel---------------------------------------------

            plot(y, wave, 'Color', 'k');

            % ---plot eventmarker--------------------------------------------

            % set basline value for the event chanel
            base(1)=min(wave)-.1*min(wave);
            base(2)=min(wave)-(max(wave)-min(wave));

            if not(isempty(hbeat))

                hbeat=round(hbeat*sr.wave);

                HBEAT = nan(size(wave));

                if strcmp(handles.prop.event,'extra')
                    HBEAT(hbeat,1)=min(wave)-.5;
                elseif strcmp(handles.prop.event,'integrated')
                    temp=wave(hbeat,1);
                    temp(isnan(temp)) = median(temp,'omitnan');
                    HBEAT(hbeat,1)=temp;
                end

                hold on ; h=stem(y,HBEAT,'ro');
                hbase=get(h,'Baseline');

                if strcmp(handles.prop.event,'extra')
                    set(hbase,'BaseValue',base(2),'Visible','off');
                elseif strcmp(handles.prop.event,'integrated')
                    set(hbase,'BaseValue',base(1),'Visible','off');
                end

            elseif not(isempty(marker))

                marker=round(marker*sr.wave);
                if marker(1,1)==0
                    marker(1,1)=1;
                end
                marker=marker(marker~=0);
                MARKER=nan(size(wave));


                if strcmp(handles.prop.event,'extra')
                    MARKER(marker,1)=min(wave)-.5;
                elseif strcmp(handles.prop.event,'integrated')
                    temp=wave(marker,1);
                    temp(isnan(temp)) = median(temp,'omitnan');
                    MARKER(marker,1)=temp;
                end

                hold on ; h=stem(y,MARKER,'ro');
                hbase=get(h,'Baseline');

                if strcmp(handles.prop.event,'extra')
                    set(hbase,'BaseValue',base(2),'Visible','off');
                elseif strcmp(handles.prop.event,'integrated')
                    set(hbase,'BaseValue',base(1),'Visible','off');
                end
            elseif not(isempty(events))

                events=round(events*sr.wave);

                EVENTS = nan(size(wave));

                if strcmp(handles.prop.event,'extra')
                    EVENTS(events,1)=min(wave)-.5;
                elseif strcmp(handles.prop.event,'integrated')
                    temp=wave(events,1);
                    temp(isnan(temp)) = median(temp,'omitnan');
                    EVENTS(events,1)=temp;
                end

                hold on ; h=stem(y,EVENTS,'r');
                hbase=get(h,'Baseline');

                if strcmp(handles.prop.event,'extra')
                    set(hbase,'BaseValue',base(2),'Visible','off');
                elseif strcmp(handles.prop.event,'integrated')
                    set(hbase,'BaseValue',base(1),'Visible','off');
                end
            end


            wv_chanid = handles.prop.wavechans(handles.prop.idwave);
            unit = deblank(handles.data{wv_chanid}.header.units);
            if strcmp(handles.prop.wave,'ecg')
                ylabel([' Amplitude [',unit,'] '],'Fontsize',14);
            elseif strcmp(handles.prop.wave,'scr')
                ylabel([' Amplitude [',unit,'] '],'Fontsize',14)
            elseif strcmp(handles.prop.wave,'emg')
                ylabel([' Amplitude [',unit,'] '],'Fontsize',14)
            elseif strcmp(handles.prop.wave,'hp')
                ylabel(' Interpolated IBI [ms] ','Fontsize',14)
            elseif strcmp(handles.prop.wave,'pupil')
                ylabel(' size in arbitrary units ','Fontsize',14)
            elseif contains(handles.prop.wave,'pupil')
                ylabel([' Pupil size [',unit,'] '],'Fontsize',14)
            elseif contains(handles.prop.wave,'gaze') && contains(handles.prop.wave,'x')
                ylabel([' Gaze x coordinate [',unit,'] '],'Fontsize',14)
            elseif contains(handles.prop.wave,'gaze') && contains(handles.prop.wave,'y')
                ylabel([' Gaze y coordinate [',unit,'] '],'Fontsize',14)
            else ylabel([' unknown unit [',unit,'] '],'Fontsize',14)
            end

            xlabel(' Time in seconds [s] ','Fontsize',16);

            if not(isempty(marker))
                legend(handles.prop.wave,'marker')
            elseif not(isempty(hbeat))
                legend(handles.prop.wave,'heartbeats')
            elseif not(isempty(events))
                legend(handles.prop.wave,[handles.list_event_channel.String{handles.prop.idevent},' events'])
            elseif not(strcmp(handles.prop.event,'none'))
                legend(handles.prop.wave,'unknown events')
            else
                legend(handles.prop.wave)
            end

            %   plotting if only event channel is selected
            % -------------------------------------------------------------------------

        elseif isempty(wave) && (not(isempty(hbeat)) || not(isempty(marker)) || not(isempty(events)))
            if not(isempty(hbeat))
                MARKER=diff(hbeat);
                plot(MARKER,'ro')
                ylabel('duration of ibi [s]','Fontsize',14)
            elseif not(isempty(marker))
                MARKER=diff(marker);
                stem(MARKER,'r')
                ylabel('inter-marker duration [s]','Fontsize',14)
            elseif not(isempty(events))
                MARKER=diff(events);
                plot(MARKER,'ro')
                ylabel('inter-event duration [s]','Fontsize',14)
            else
                MARKER=[];
            end

            xlabel('Time in seconds [s] ','Fontsize',16);
            if not(isempty(marker))
                legend('marker')
            elseif not(isempty(hbeat))
                legend('heartbeats')
            elseif not(isempty(events))
                legend([handles.list_event_channel.String{handles.prop.idevent},' events'])
            else
                legend('unknown events')
            end
        end
    end
    % -------------------------------------------------------------------------
    % title(sprintf(' %s ',regexprep(handles.name, '([\\_])' ,'\\$1')),'Fontsize',18);
    set(handles.display_plot,'XGrid','on')
    hold off
    % -------------------------------------------------------------------------

    x=get(handles.display_plot,'xlim');
    y=get(handles.display_plot,'ylim');
    x(2)=x(2)-x(1);
    set(handles.ed_y_min,'String',num2str(y(1)))
    set(handles.ed_y_max,'String',num2str(y(2)))
    set(handles.ed_start_x,'String',num2str(x(1)))
    set(handles.ed_winsize_x,'String',num2str(x(2)))

    % -------------------------------------------------------------------------
end

% --- Executes when pspm_display is resized.
function pspm_display_ResizeFcn(hObject, eventdata, handles)
    % hObject    handle to pspm_display (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes during object creation, after setting all properties.
function module_display_options_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to module_display_options (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
end

% --- Executes during object creation, after setting all properties.
function panel_event_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to panel_event (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
end

% --- Executes on selection change in list_wave.
function list_wave_Callback(hObject, eventdata, handles)
    % hObject    handle to list_wave (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns list_wave contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from list_wave
end

% --- Executes during object creation, after setting all properties.
function list_wave_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to list_wave (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on selection change in list_wave_channel.
function list_wave_channel_Callback(hObject, eventdata, handles)
    % hObject    handle to list_wave_channel (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns list_wave_channel contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from list_wave_channel
end

% --- Executes during object creation, after setting all properties.
function list_wave_channel_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to list_wave_channel (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on selection change in list_event_channel.
function list_event_channel_Callback(hObject, eventdata, handles)
    % hObject    handle to list_event_channel (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns list_event_channel contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from list_event_channel
end

% --- Executes during object creation, after setting all properties.
function list_event_channel_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to list_event_channel (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in button_plot.
function button_plot_Callback(hObject, eventdata, handles)
    % hObject    handle to button_plot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % ---get selected wave channel---------------------------------------------
    handles.prop.idwave=get(handles.list_wave_channel,'Value');
    handles.prop.wave=get(handles.list_wave_channel,'String');
    handles.prop.wave=handles.prop.wave{handles.prop.idwave,1};

    % ---get selected event channel--------------------------------------------
    handles.prop.idevent=get(handles.list_event_channel,'Value');
    handles.prop.event=get(handles.list_event_channel,'String');
    handles.prop.event=handles.prop.event{handles.prop.idevent,1};
    % ---deactivate marker buttons if necessary--------------------------------

    if handles.prop.idevent==1 || handles.prop.idwave==1
        set(handles.option_integrated,'Enable','Off');
        set(handles.option_extra,'Enable','Off');
    else
        set(handles.option_integrated,'Enable','On');
        set(handles.option_extra,'Enable','On');
    end


    % -------------------------------------------------------------------------
    % Update handles structure
    guidata(hObject, handles);
    % -------------------------------------------------------------------------
    pp_plot(handles);
end

% --- Executes on button press in option_integrated.
function option_integrated_Callback(hObject, eventdata, handles)
    % hObject    handle to option_integrated (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of option_integrated

    status=get(handles.option_integrated,'Value');
    if status==1
        set(handles.option_extra,'Value',0)
    elseif status==0
        set(handles.option_integrated,'Value',1);
    end
    % -------------------------------------------------------------------------
    % Update handles structure
    guidata(hObject, handles);
    % -------------------------------------------------------------------------
end

% --- Executes when pspm_display is resized.
function pspm_display_SizeChangedFcn(hObject, eventdata, handles)
    % hObject    handle to pspm_display (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

function update_summary_list (handles, filename)
    global channel_type_reference_list
    channel_list_full = {channel_type_reference_list.description};
    handles.name=filename;
    [~, info, handles.data, ~]=pspm_load_data(filename,0);
    handles.tag_summary_recording_duration_content.String = [num2str(info.duration), ' s'];
    [~,filename_display,~] = fileparts(filename);
    handles.tag_summary_source_file_content.String=filename_display;
    [r_channels,c_channels]=size(handles.data);
    array_channel_type = cell(r_channels,c_channels);
    string_channel_list = [];
    if r_channels > 1 && c_channels > 1
        for i_r_channel=1:r_channels
            for i_c_channels=1:c_channels
                % array_channel_type(r_channels,c_channels) = handles.data{i_r_channel,i_c_channels}.header.chantype;
                targeted_channel_reference = handles.data{i_r_channel,i_c_channels}.header.chantype;
                targeted_channel_display = channel_list_full(strcmp(targeted_channel_reference, {channel_type_reference_list.type}));
                targeted_channel_display = targeted_channel_display{1,1};
                string_channel_list = [string_channel_list, ...
                num2str(i_r_channel), ',', num2str(i_c_channels), ' ', ...
                targeted_channel_display, newline];
            end
        end
    else
        number_channel = max(r_channels, c_channels);
        for i_channel = 1:number_channel
            if r_channels == 1
                i_r_channels = 1;
                i_c_channels = i_channel;
            else
                i_c_channels = 1;
                i_r_channels = i_channel;
            end
            targeted_channel_reference = handles.data{i_r_channels,i_c_channels}.header.chantype;
            targeted_channel_display = channel_list_full(strcmp(targeted_channel_reference, {channel_type_reference_list.type}));
            targeted_channel_display = targeted_channel_display{1,1};
            string_channel_list = [string_channel_list, ...
            num2str(i_channel), ' ', ...
            targeted_channel_display, newline];
        end
    end
    handles.tag_summary_channel_list_content.String=string_channel_list;
end
