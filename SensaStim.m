function SensaStim ()

    %Set the global run variable
    global run;
    run = 0;
    
    %Create the guid
   
    handles = Make_GUI();
    
    %Create an empty list of rat names
    handles.rat_name = [];
    
    %Connect to the Arduino board
    handles.ardy = SensaStim_Ardy_Connect();
    
    %Save the gui    
    guidata(handles.fig, handles);
    
    

end

function handles = Make_GUI()

    set(0,'units','centimeters');
    pos = get(0,'screensize');  
    h = 37;
    w = 70; %9 * h / 3;  

    figure_color = [1 1 1];
    
    %Create the main figure window
    handles.fig = figure(...
        'name', 'SensaStim', ...
        'units', 'centimeters', ...
        'Position', [pos(3)/2-w/2, pos(4)/2-h/2, w*0.7, h*0.7], ...
        'Color', figure_color, ...
        'Menubar', 'none', ...
        'Resize', 'off');
    
    %Create the primary vertical stack panel for this figure
     primary_panel = uix.VBox( ...
         'parent', handles.fig, ...
         'Spacing', 10, ...
         'Padding', 10, ...
         'BackgroundColor', figure_color);
    
    primary_panel_heights = [];

    %Place a text block at the top with the title of the program
    handles.programlabel = uicontrol( ...
        'parent', primary_panel, ...
        'style', 'text', ...
        'string', 'SensaStim', ...
        'fontweight', 'bold', ...
        'fontsize', 36, ...
        'horizontalalignment', 'center', ...
        'backgroundcolor', figure_color, ...
        'foregroundcolor', [0 0 0]);        
    
    
    current_stimulus_horizontal_box = uix.HBox( ...
        'parent', primary_panel, ...
        'Spacing', 10, 'Padding', 10, 'BackgroundColor', figure_color);
    uicontrol( ...
        'parent', current_stimulus_horizontal_box, ...
        'style', 'text', ...
        'string', 'Current stimulus: ', ...
        'fontweight', 'bold', ...
        'fontsize', 36, ...
        'horizontalalignment', 'center', ...
        'backgroundcolor', figure_color, ...
        'foregroundcolor', [0 0 0]);
    handles.current_stimulus_label = uicontrol( ...
        'parent', current_stimulus_horizontal_box, ...
        'style', 'text', ...
        'string', 'None', ...
        'fontweight', 'bold', ...
        'fontsize', 36, ...
        'horizontalalignment', 'center', ...
        'backgroundcolor', figure_color, ...
        'foregroundcolor', [0 0 0]);
    uicontrol( ...
        'parent', current_stimulus_horizontal_box, ...
        'style', 'text', ...
        'string', ' (', ...
        'fontweight', 'bold', ...
        'fontsize', 36, ...
        'horizontalalignment', 'center', ...
        'backgroundcolor', figure_color, ...
        'foregroundcolor', [0 0 0]);
    handles.current_stimulus_count_remaining_label = uicontrol( ...
        'parent', current_stimulus_horizontal_box, ...
        'style', 'text', ...
        'string', '0', ...
        'fontweight', 'bold', ...
        'fontsize', 36, ...
        'horizontalalignment', 'center', ...
        'backgroundcolor', figure_color, ...
        'foregroundcolor', [0 0 0]);
    uicontrol( ...
        'parent', current_stimulus_horizontal_box, ...
        'style', 'text', ...
        'string', ' left) Block: ', ...
        'fontweight', 'bold', ...
        'fontsize', 36, ...
        'horizontalalignment', 'center', ...
        'backgroundcolor', figure_color, ...
        'foregroundcolor', [0 0 0]);
    
    handles.current_block_label = uicontrol( ...
        'parent', current_stimulus_horizontal_box, ...
        'style', 'text', ...
        'string', '-', ...
        'fontweight', 'bold', ...
        'fontsize', 36, ...
        'horizontalalignment', 'center', ...
        'backgroundcolor', figure_color, ...
        'foregroundcolor', [0 0 0]);
    uicontrol( ...
        'parent', current_stimulus_horizontal_box, ...
        'style', 'text', ...
        'string', '/', ...
        'fontweight', 'bold', ...
        'fontsize', 36, ...
        'horizontalalignment', 'center', ...
        'backgroundcolor', figure_color, ...
        'foregroundcolor', [0 0 0]);
    handles.total_blocks_label = uicontrol( ...
        'parent', current_stimulus_horizontal_box, ...
        'style', 'text', ...
        'string', '-', ...
        'fontweight', 'bold', ...
        'fontsize', 36, ...
        'horizontalalignment', 'center', ...
        'backgroundcolor', figure_color, ...
        'foregroundcolor', [0 0 0]);
    
    set(current_stimulus_horizontal_box, 'Widths', [450 450 50 100 300 100 50 100]); 
    
    
    primary_panel_heights = [primary_panel_heights 75 75];

    %Create a horizontal stack panel for each rat
    for i = 1:8
        handles = Make_GUI_For_Booth(handles, primary_panel, i);
        primary_panel_heights = [primary_panel_heights 75];
    end
    
    %Create some empty space
    uix.Empty('parent', primary_panel);
    primary_panel_heights = [primary_panel_heights 30];
    
    %Create a start/stop button at the bottom of the GUI
    temp_hbox = uix.HBox('parent', primary_panel, 'backgroundcolor', get(handles.fig, 'color'));
    uix.Empty('parent', temp_hbox);
    handles.start_button = uicontrol( ...
        'parent', temp_hbox, ...
        'style', 'pushbutton', ...
        'string', 'Start', ...
        'horizontalalignment', 'center', ...
        'fontsize', 32, ...
        'foregroundcolor', [0 0.7 0], ...
        'fontweight', 'bold', ...
        'enable', 'on');
    uix.Empty('parent', temp_hbox);
    set(temp_hbox, 'Widths', [-1 600 -1]);
    set(handles.start_button, 'callback', @StartButtonClick);
    primary_panel_heights = [primary_panel_heights 75];
    
    %Set the heights of each element of the primary vertical stack panel layout
    set(primary_panel, 'Heights', primary_panel_heights);
    
    %Save all of the panels for future use
    handles.panels = primary_panel;

end

function handles = Make_GUI_For_Booth ( handles, primary_panel, booth_num )

    %Create a horizontal panel for all GUI elements for this booth
    handles.booth_panels(booth_num) = ...
        uix.HBox('Parent', primary_panel, ...
        'BackgroundColor', get(handles.fig, 'color'), ...
        'Spacing', 20, ...
        'Units', 'normalized', ...
        'Spacing', 0.1);
    
    %Create a label for this booth
    uix.Text( ...
        'parent', handles.booth_panels(booth_num), ...
        'string', ['Booth ' num2str(booth_num) ': '], ...
        'fontweight', 'bold', ...
        'fontsize', 18, ...
        'horizontalalignment', 'left', ...
        'verticalalignment', 'middle', ...
        'backgroundcolor', get(handles.fig, 'color'));
    
    %Create a text box where the rat name can be entered
    temp_vbox = uix.VBox('parent', handles.booth_panels(booth_num), ...
        'backgroundcolor', get(handles.fig, 'color'));
    uix.Empty('parent', temp_vbox);
    handles.rat_name_edit_box(booth_num) = uicontrol( ...
        'Style', 'edit', ...
        'parent', temp_vbox, ...
        'string', '', ...
        'units', 'normalized', ...
        'fontsize', 18);
    uix.Empty('parent', temp_vbox);
    set(handles.rat_name_edit_box(booth_num), 'callback', {@EditRat, booth_num});
    set(temp_vbox, 'Heights', [-1 45 -1]);
    
    %Create another label which indicates whether the booth is currently in use or not
    handles.rat_booth_in_use_box(booth_num) = uix.Text( ...
        'parent', handles.booth_panels(booth_num), ...
        'string', 'X', ...
        'fontweight', 'bold', ...
        'fontsize', 36, ...
        'verticalalignment', 'middle', ...
        'foregroundcolor', 'r', ...
        'backgroundcolor', get(handles.fig, 'color'));
    
    %Create another label which indicates how long it has been since the
    %last button press for this booth
    handles.rat_booth_time_since_last_button_press(booth_num) = uix.Text( ...
        'parent', handles.booth_panels(booth_num), ...
        'string', '-', ...
        'fontweight', 'bold', ...
        'fontsize', 36, ...
        'verticalalignment', 'middle', ...
        'foregroundcolor', 'r', ...
        'backgroundcolor', get(handles.fig, 'color'));
    
    %Create an axis which will show information about the booth during this session
    uix.Empty('parent', handles.booth_panels(booth_num));
    handles.booth_axes(booth_num) = axes('parent', handles.booth_panels(booth_num), ...
        'hittest', 'off');
    uix.Empty('parent', handles.booth_panels(booth_num));
    
    %Set the widths of each column in this GUI
    set(handles.booth_panels(booth_num), 'Widths', [150 200 100 100 100 -1 100]);

end

function StartButtonClick (hObject, eventdata)

    global run;
    handles = guidata(hObject);
    
    if (run == 0)
        run = 1;
        set(handles.start_button, 'string', 'Stop');
        set(handles.start_button, 'foregroundcolor', 'r');
        
        Run(handles);
        
    else
        run = 0;
        set(handles.start_button, 'string', 'Start');
        set(handles.start_button, 'foregroundcolor', [0 0.7 0]);
        
    end
    
    %Save the handles structure
    guidata(handles.fig, handles);

end

function EditRat (hObject, eventdata, booth_num)

    handles = guidata(hObject);
    
    rat_name = get(handles.rat_name_edit_box(booth_num), 'string');
    temp_rat_name = rat_name;
    
    %Step through all reserved characters.
    for c = '/\?%*:|"<>. '                                                      
        %Kick out any reserved characters from the rat name.
        temp_rat_name(temp_rat_name == c) = [];                                                   
    end
    
    %Uppercase the whole string
    temp_rat_name = upper(temp_rat_name);

    %Set the string in GUI
    if (~strcmp(rat_name, temp_rat_name))
        set(handles.rat_name_edit_box(booth_num), 'string', temp_rat_name);
    end
    
    %Place a check mark or an X next to the edit box
    if (~isempty(temp_rat_name))
        set(handles.rat_booth_in_use_box(booth_num), 'string', char(hex2dec('2713')));
        set(handles.rat_booth_in_use_box(booth_num), 'foregroundcolor', [0 0.7 0]);
    else
        set(handles.rat_booth_in_use_box(booth_num), 'string', 'X');
        set(handles.rat_booth_in_use_box(booth_num), 'foregroundcolor', 'r');
    end
    
    %Save the rat name
    handles.rat_name{booth_num} = temp_rat_name;
    
    %Save the gui data
    guidata(handles.fig, handles);

end

function Run (handles)

    global run;
    
    session_start_time = now;
    
    num_booths = 8;
    
    %Figure out which booths are our active booths for this session
    active_booths = [];
    
    for i = 1:num_booths
        rat_name = get(handles.rat_name_edit_box(i), 'string');
        if (~isempty(rat_name))
            active_booths = [active_booths i];
        end
    end
    
    stimulus_change_threshold = 10;
    current_block = 1;
    total_blocks = 20;
    
    stimuli_types = {'Von Frey Filament', 'Copper Rod', 'Air Puffer', 'Paint Brush'};
    stimuli_types_colors = [1 0.5 0; 0 0.7 0; 0 0 1; 1 0 1];
    
    current_stimulus = 1;
    stimulus_counter = zeros(1, length(active_booths));
    time_of_last_button_press = nan(1, num_booths);
    
    booth_data = struct('stimulus_times', {}, 'stimulus_types', {});
    for i = 1:num_booths
        booth_data(i).stimulus_times = [];
        booth_data(i).stimulus_types = [];
    end
    
    %Set up the GUI to run
    set(handles.current_stimulus_label, 'string', stimuli_types{1});
    set(handles.current_stimulus_label, 'foregroundcolor', stimuli_types_colors(1, :));
    set(handles.current_stimulus_count_remaining_label, 'string', num2str(stimulus_change_threshold));
    set(handles.current_block_label, 'string', num2str(current_block));
    set(handles.total_blocks_label, 'string', num2str(total_blocks));
    
    %Open a file for each rat
    active_rat_files = [];
    for r = 1:length(active_booths)
        this_booth = active_booths(r);
        rat_name = get(handles.rat_name_edit_box(this_booth), 'string');
        fid = OpenFileForRat('.\data', rat_name);
        active_rat_files = [active_rat_files fid];
    end
    
    %As long as the program should be running
    while(run == 1)
        
        did_button_press_occur = handles.ardy.read_report();
        if (did_button_press_occur >= 0)
            booth_of_button_press = did_button_press_occur + 1;
            
            if (~isempty(find(active_booths == booth_of_button_press, 1, 'first')))
                
                %Append the current time to the list of button press times
                %for this booth
                booth_data(booth_of_button_press).stimulus_times = [booth_data(booth_of_button_press).stimulus_times now];
                booth_data(booth_of_button_press).stimulus_types = [booth_data(booth_of_button_press).stimulus_types current_stimulus];
                
                %Record the time of the last button press for this booth
                time_of_last_button_press(booth_of_button_press) = now;
                
                %Increment the stimulus counter for this booth
                stim_counter_idx = find(active_booths == booth_of_button_press, 1, 'first');
                stimulus_counter(stim_counter_idx) = stimulus_counter(stim_counter_idx) + 1;
                
                %Record the data in this rat's file
                this_rat_fid = active_rat_files(stim_counter_idx);
                SaveStimulusToFile(this_rat_fid, now, stimuli_types{current_stimulus});
                
                %Plot the new button press on the appropriate graph
                x_datapoint_for_graph = etime(datevec(now), datevec(session_start_time));
                axes(handles.booth_axes(booth_of_button_press));
                hold(handles.booth_axes(booth_of_button_press), 'on');
                line([x_datapoint_for_graph x_datapoint_for_graph], [0 1], 'LineStyle', '--', 'Color', [0 0.7 0]);
                
                %Set the gui element indicating how many stimuli remain for
                %the current stimulus type
                stimuli_remaining = max(stimulus_change_threshold - stimulus_counter);
                set(handles.current_stimulus_count_remaining_label, 'string', num2str(stimuli_remaining));
                
                %Check to see if we have reached threshold to go to the
                %next stimulus
                if (all(stimulus_counter >= stimulus_change_threshold))
                    %Increment the current stimulus
                    current_stimulus = current_stimulus + 1;
                    if (current_stimulus > length(stimuli_types))
                        current_stimulus = 1;
                    end
                    
                    current_block = current_block + 1;
                    if (current_block > total_blocks)
                        run = 0;
                        set(handles.current_stimulus_label, 'string', 'FINISHED');
                        set(handles.current_stimulus_label, 'foregroundcolor', [1 0 0]);
                    else
                        %Reset the stimulus counter
                        stimulus_counter = zeros(1, length(active_booths));

                        %Set the GUI to indicate that we are moving on to the
                        %next stimulus
                        set(handles.current_stimulus_label, 'string', stimuli_types{current_stimulus});
                        set(handles.current_stimulus_label, 'foregroundcolor', stimuli_types_colors(current_stimulus, :));
                        set(handles.current_stimulus_count_remaining_label, 'string', num2str(stimulus_change_threshold));
                        set(handles.current_block_label, 'string', num2str(current_block));
                    end
                    
                end
                
            end
            
        end
        
        %Update the GUI periodically
        for i = 1:length(active_booths)
            this_booth = active_booths(i);
            this_booth_time = time_of_last_button_press(this_booth);
            if (~isnan(this_booth_time))
                total_seconds = round(etime(datevec(now), datevec(this_booth_time)));
                set(handles.rat_booth_time_since_last_button_press(this_booth), 'string', total_seconds);
            end
        end
        
        %Pause the thread so we don't consume the CPU
        pause(0.033);
        
    end
    
    %Close all active rat files
    for r = 1:length(active_rat_files)
        CloseFile(active_rat_files(r));
    end
    
    %Close the arduino connection
    fclose(handles.ardy.serialcon);

end


function fid = OpenFileForRat ( data_path, rat_name )

    current_date_time = datestr(now, 'yyyymmdd_HHMMSS');
    file_name = [rat_name '_' current_date_time '.txt'];
    
    full_path = [data_path '\' rat_name];
    if (~isfolder(full_path))
        mkdir(full_path);
    end
    
    full_path_with_file_name = [full_path '\' file_name];
    fid = fopen(full_path_with_file_name, 'wt');
    
    fprintf(fid, '%s\n', rat_name);
    fprintf(fid, '%s\n', current_date_time);
    
end

function SaveStimulusToFile ( fid, d, st )

    current_date_time = datestr(now, 'yyyymmdd_HHMMSS');
    fprintf(fid, '%s,%s\n', current_date_time, st);

end

function CloseFile ( fid )

    fclose(fid);

end























