clear all
start_name = 'recorded_data0702.csv';
for k = 1:20
    disp(start_name)
    clear trimmed
    load('CalibrationG20201010.mat', 'CoefG');
    data_import = readtable(start_name);
    
    target = table2array(data_import);
    trimmed = zeros(height(data_import) - 20, 9);
    

    for i = 1:9
        for j = 11:(length(target)-10)
            trimmed(j - 10, i) = target(j, i) * CoefG(i);
        end
    end
    
    
%     for i = 10:12
%         for j = 11:(length(target)-10)
%             trimmed(j - 10, i) = target(j, i);
%         end
%         trimmed(:, i) = (trimmed(:, i) - min(trimmed(:, i))) / ( max(trimmed(:, i)) - min(trimmed(:, i)) );
%     end
    
    for i = 1:9
        for j = 2:length(trimmed)
            trimmed(j, i) = trimmed(j, i) - trimmed(1, i);
        end
        trimmed(1, i) = 0;
    end
    
    for i = 1:9
        for j = 2:length(trimmed)
            if abs(trimmed(j, i) - trimmed(j - 1, i)) > 0.5
                trimmed(j, i) = trimmed(j - 1, i);
            end
        end
    end

    
    for i = 1:9
        for j = 1:length(trimmed)
            trimmed(j, i) = trimmed(j, i) * 8;
        end
    end
    
%     for i = 1:9
%         for j = 1:length(trimmed)
%             trimmed(j, i) = trimmed(j, i) + 90 - i * 10;
%         end
%     end
%     
    figure(k)
    plot(trimmed, 'LineWidth', 2)
    %legend('1 Root', '1 Mid', '1 Tip', '2 Root', '2 Mid', '2 Tip', '3 Root', '3 Mid', '3 Tip')
%     figure(2*k-1)
%     plot(trimmed(:,(10:12)),'LineWidth', 2)
    
    
    drawnow
    
    rf = 'recorded_data';
    output_filename = 'Empty';
    
    record_fileindex = str2double(start_name(14:17));
    record_fileindex = record_fileindex + 1;
    output_fileindex = k;
    if record_fileindex < 10
        rf = strcat(rf, '000');
    elseif record_fileindex < 100
        rf = strcat(rf, '00');
    elseif record_fileindex < 1000
        rf = strcat(rf, '0');
    end
    rf = strcat(rf, num2str(record_fileindex));
    rf = strcat(rf, '.csv');
    start_name = rf;
    
    if output_fileindex < 10
        output_filename = strcat(output_filename, '0');
    end
    
    output_filename = strcat(output_filename, num2str(output_fileindex));
    output_filename = strcat(output_filename, '.mat');
    
    save(output_filename,'trimmed');
    disp('Data Process Successful!')
end