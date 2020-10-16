% This file contains code for extending the Agilent E4980A LCR Meter
% to up to 16 channels
% Hardware requirement: E4980A, Arduino Uno, and Sparkfun 16 Channel Mux

% This is the main function for this project.
function SmartGripper_ExperimentSuite
disp(' ');
disp('AgilentE4980A_Monitor_Arduino_Mux by Runze')
disp('-------------------------');
disp('-------------------------');

%===================== Initialization Section =====================

clear global
global driver % E4980A driver instance
global ardu   % Arduino instance
global ardu_mega
global prog_run
global pump_timer_stat
pump_timer_stat = false;
prog_run = 1;

warning('off','all')

% Driver Initialization of the Agilent E4980A
AgilentE4980A_Init();
% Create Arduino instance
arduino_init();
arduino_mega_init();

% Define measurement parameters for the Agilent E4980A
driver.DeviceSpecific.Function.ImpedanceType = 0;   % MODE      = Cp - D
driver.DeviceSpecific.Measurement.VoltageLevel = 1; % Voltage   = 1V
driver.DeviceSpecific.Measurement.Frequency = 1e5;  % Freq      = 100khz
driver.DeviceSpecific.Measurement.Aperture = 1;     % Meas Time = SHORT

data_multiplier = 1e12;

%===================== Main Functional Section =====================

num_data_point = 100; % Number of data in one cycle
data_ptr = 1;          % Recorded data array index (row index of the matrix)
loop_param = 0;        % Inner loop iterator from 0 --> num_data_point
LCR_val_max = 0.1;
LCR_val_min = 0.1;
LCR_val = 0;

writeDigitalPin(ardu, 'D8', 0);
writeDigitalPin(ardu, 'D9', 0);
writeDigitalPin(ardu, 'D10', 0);
writeDigitalPin(ardu, 'D11', 0);

channel_iteration_order = [8, 0, 1, 3, 2, 6, 7, 5, 4]; % See function sw_channel_inorder_fast

pump_timer_StageEND = timer('TimerFcn', 'pump_ctrl(2);', 'StartDelay', 5);
pump_timer_StageOUT = timer('TimerFcn', 'pump_ctrl(3); start(pump_timer_StageEND)', 'StartDelay', 15);
pump_timer_StageIN = timer('TimerFcn', 'pump_ctrl(1); start(pump_timer_StageOUT)', 'StartDelay', 15);


% UUUUUUtilities!!!!!
%=====================
enable_plot = true; % Plot all the data? Yes(500ms) : No(350ms)
%simple_filter = false; % Correct the coupling due to the multiplexer

%             % Apply a simple filter (if enabled)
%             if simple_filter
%                 if abs(LCR_val-LCR_val_prev) < 0.05 || ((data_ptr > 1) && abs(LCR_val-recorded_data(curr_channel+1, data_ptr-1) > 1))
%                     [parameter1,~,~,~] = driver.DeviceSpecific.Result.FormattedImpedance(0,0,0,0);
%                     LCR_val = parameter1 * data_multiplier;
%                     disp('ooo')
%                 end
%             end
%=====================

if enable_plot
    get_screen_size = get(0, 'ScreenSize');
    screen_x = get_screen_size(3);
    screen_y = get_screen_size(4);
    
    screen_center = [screen_x / 2, screen_y / 2];
    figure_side_length = 0.15 * get_screen_size(3);
    pos_fig1 = [screen_center(1) - 1.5 * 1.4 * figure_side_length, screen_center(2) + 0.7 * figure_side_length, figure_side_length, figure_side_length];
    
    pos_figs = [pos_fig1; pos_fig1; pos_fig1; pos_fig1; pos_fig1; pos_fig1; pos_fig1; pos_fig1; pos_fig1];
    
    for fig_index = 1:9
        if fig_index > 6
            pos_figs(fig_index,1) = pos_figs(fig_index,1) + mod(fig_index - 1, 3) *  1.1 * figure_side_length;
            pos_figs(fig_index,2) = pos_figs(fig_index,2) - 2 * 1.2 * figure_side_length;
        elseif fig_index > 3
            pos_figs(fig_index,1) = pos_figs(fig_index,1) + mod(fig_index - 1, 3) *  1.1 * figure_side_length;
            pos_figs(fig_index,2) = pos_figs(fig_index,2) - 1.2 * figure_side_length;
        elseif fig_index > 0
            pos_figs(fig_index,1) = pos_figs(fig_index,1) + mod(fig_index - 1, 3) *  1.1 * figure_side_length;
        end
    end
    
    for fig_index = 1:9
        figure_init = figure(fig_index);
        figure_init.Position = pos_figs(fig_index, :);
        figure_init.SelectionHighlight = 'off';
        figure_init.MenuBar = 'none';
        figure_init.ToolBar = 'none';
        figure_init.Name = strcat('LCR Channel ' , num2str(fig_index));
    end
    
end
hWaitbar = waitbar(10, 'Data Points Count: 1', 'Name', 'Performing 9 Channels Test with Fake Waitbar','CreateCancelBtn','delete(gcbf)');
if enable_plot
    hWaitbar.Position = [40, 80, 300, 100];
end

start(pump_timer_StageIN)
while prog_run
    tic
    writeDigitalPin(ardu, 'D10', 0);
    % Read Analog Strain Sensor
%     strain1 = readVoltage(ardu, 'A0');
%     strain2 = readVoltage(ardu, 'A1');
%     strain3 = readVoltage(ardu, 'A2');
%     
%     recorded_data(10, data_ptr) = strain1;
%     recorded_data(11, data_ptr) = strain2;
%     recorded_data(12, data_ptr) = strain3;
%     
%     figure(10)
%     drawnow
%     plot(loop_param, strain1, 'ro', 'MarkerSize', 1)
%     hold on
%     plot(loop_param, strain2, 'bo', 'MarkerSize', 1)
%     hold on
%     plot(loop_param, strain3, 'go', 'MarkerSize', 1)
%     hold on
    
    % Iterate through all the 9 channels
    for channel = 0:8
        if prog_run
            % this is a fast way to iterate all channels. See codes.
            sw_channel_inorder_fast(channel);
            curr_channel = channel_iteration_order(channel + 1);
            pause(0.01)
            
            % Acquire data from the E4980A LCR Meter
            [parameter1,~,~,~] = driver.DeviceSpecific.Result.FormattedImpedance(0,0,0,0);
            LCR_val_prev = LCR_val;
            LCR_val = parameter1 * data_multiplier;
            
            
            
            % Record the data to the output matrix
            recorded_data(curr_channel+1, data_ptr) = LCR_val;
            %recorded_data(1, data_ptr) = LCR_val;
            % Generate Plot (if enabled)
            if enable_plot
                % This is for dynamic upper/lower bound changing.
                if LCR_val > LCR_val_max
                    LCR_val_max = LCR_val;
                elseif LCR_val < LCR_val_min
                    LCR_val_min = LCR_val;
                end
                
                % draw the 9 figures
                %figure(1);
                figure(curr_channel + 1);
                xlim([0 num_data_point]);
                ylim([0.9*LCR_val_min 1.5*LCR_val_max]);
                plot(loop_param, LCR_val, 'ro', 'MarkerSize', 1);
                drawnow;
                hold on;
                
                
            end
        end
    end
    % check if the data filled the plot, if so, clear it
    if loop_param >= num_data_point
        loop_param = 0;
        for clear_figure = 1:9
            figure(clear_figure)
            clf
        end
    end
    loop_param = loop_param + 1;
    
    data_ptr = data_ptr + 1;
    toc
    
    drawnow;
    if ~ishandle(hWaitbar)
        disp('Loop stopped by user');
        break;
    else
        waitbar(data_ptr/1000,hWaitbar, ['Data Points Count: ' num2str(data_ptr)]);
    end
    
    if data_ptr >= 65
        delete(gcbf);
        break;
    end
end
close all

%========================= Data Rec Section =========================
recorded_data = recorded_data.';
record_filename = 'recorded_data';
record_fileindex = 0;

Files=dir('*.*');
for k=1:length(Files)
    FileNames = Files(k).name;
    find_filename = strfind(FileNames, record_filename);
    if isempty(find_filename)
    else
        record_fileindex = record_fileindex + 1;
    end
    
end

record_successful = true;

if record_fileindex < 10
    record_filename = strcat(record_filename, '000');
elseif record_fileindex < 100
    record_filename = strcat(record_filename, '00');
elseif record_fileindex < 1000
    record_filename = strcat(record_filename, '0');
elseif record_fileindex < 10000
else
    disp('Data NOT recorded! Number of files exceeded limit (9999), please empty the output folder')
    record_successful = false;
end

if record_successful
    record_filename = strcat(record_filename, num2str(record_fileindex));
    record_filename = strcat(record_filename, '.csv');
    
    csvwrite(record_filename,recorded_data);
    disp('Data recorded successful! Outputed as: ')
    disp(record_filename)
end


%========================= Clean Up Section =========================

% Close the driver upon work done
if driver.Initialized
    driver.Close();
    disp('Driver Closed');
end
clear global
disp('All obj closed');
end

function AgilentE4980A_Init
global driver

% Create driver instance
driver = instrument.driver.AgilentE4980A();

% Set instrument address
resourceDesc = 'USB0::0x0957::0x0909::MY46310406::0::INSTR';

initOptions = 'QueryInstrStatus=true, Simulate=false, DriverSetup= Model=, Trace=false';
idquery = true;
reset   = true;

driver.Initialize(resourceDesc, idquery, reset, initOptions);
disp('Driver initialized with following information: ');
disp(['Identifier:      ', driver.Identity.Identifier]);
disp(['Revision:        ', driver.Identity.Revision]);
disp(['Vendor:          ', driver.Identity.Vendor]);
disp(['Description:     ', driver.Identity.Description]);
disp(['InstrumentModel: ', driver.Identity.InstrumentModel]);
disp(['FirmwareRev:     ', driver.Identity.InstrumentFirmwareRevision]);
disp(['Serial #:        ', driver.DeviceSpecific.System.SerialNumber]);
disp('-------------------------');
disp('-------------------------');

end

function arduino_init

global ardu
ardu = arduino('COM3', 'Uno');
% Following config lines define the ports for the multiplexer
configurePin(ardu, 'D8', 'DigitalOutput');
configurePin(ardu, 'D9', 'DigitalOutput');
configurePin(ardu, 'D10', 'DigitalOutput');
configurePin(ardu, 'D11', 'DigitalOutput');

disp('Arduino instance created with following information:');
disp(ardu);
disp('-------------------------');
disp('-------------------------');
end

function arduino_mega_init
global ardu_mega
global port_mega
port_mega = ['D22'; 'D24'; 'D26'; 'D28'; 'D30'; 'D32'; 'D34'; 'D36'; 'D23'; 'D25'; 'D27'; 'D29'];
ardu_mega = arduino('COM4', 'Mega2560');
for i = 1:12
    configurePin(ardu_mega, port_mega(i, :), 'DigitalOutput');
end
configurePin(ardu_mega, 'D12', 'DigitalOutput');

fprintf('TESTING Valves: G');

for i = 1:12
    writeDigitalPin(ardu_mega, port_mega(i, :), 1);
    fprintf('o');
    pause(0.011);
end

for i = 1:12
    writeDigitalPin(ardu_mega, port_mega(i, :), 0);
    fprintf('o');
    pause(0.011);
end
disp('d!');

fprintf('STARTING Pump: ');
for i = 1:3
    writeDigitalPin(ardu_mega, 'D12', 1);
    fprintf('wooo~ ');
    pause(0.1);
    writeDigitalPin(ardu_mega, 'D12', 0);
    pause(0.1);
end
disp('I am working!');

writePWMVoltage(ardu_mega, 'D12', 4);


disp('END!');

disp('Arduino instance created with following information:');
disp(ardu_mega);
disp('-------------------------');
disp('-------------------------');
end

function sw_channel_inorder_fast(i)
% Note: the order of channel sweep is:
% [8, 0, 1, 3, 2, 6, 7, 5, 4]
% The idea is : We only need to perform one write for each channel change.
global ardu
switch i
    case 0
        writeDigitalPin(ardu, 'D11', 1);
    case 1
        writeDigitalPin(ardu, 'D11', 0);
    case 2
        writeDigitalPin(ardu, 'D8', 1);
    case 3
        writeDigitalPin(ardu, 'D9', 1);
    case 4
        writeDigitalPin(ardu, 'D8', 0);
    case 5
        writeDigitalPin(ardu, 'D10', 1);
    case 6
        writeDigitalPin(ardu, 'D8', 1);
    case 7
        writeDigitalPin(ardu, 'D9', 0);
    case 8
        writeDigitalPin(ardu, 'D8', 0);
end
end
