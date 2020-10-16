clear trimmed
Pre_filter = [VarName1, VarName2, VarName3, VarName4, VarName5, VarName6, VarName7, VarName8, VarName9];
target = Pre_filter;
trimmed = zeros(length(Pre_filter) - 20, 9);

for i = 1:9
    for j = 11:(length(Pre_filter)-10)
        trimmed(j - 10, i) = target(j, i) * CoefG(i);
    end
end

for i = 1:9
    for j = 2:length(trimmed)
        trimmed(j, i) = trimmed(j, i) - trimmed(1, i);
    end
    trimmed(1, i) = 0;
end

% for i = 1:9
%     for j = 2:length(trimmed)
%         if abs(trimmed(j, i) - trimmed(j - 1, i)) > 0.345
%             trimmed(j, i) = trimmed(j - 1, i);
%         end
%     end
% end

for i = 1:9
    for j = 1:length(trimmed)
        trimmed(j, i) = trimmed(j, i) * 8;
    end
end

for i = 1:9
    for j = 1:length(trimmed)
        trimmed(j, i) = trimmed(j, i) + 90 - i * 10;
    end
end


plot(trimmed, 'LineWidth', 2)
legend('1 Root', '1 Mid', '1 Tip', '2 Root', '2 Mid', '2 Tip', '3 Root', '3 Mid', '3 Tip')

clear VarName1
clear VarName2
clear VarName3
clear VarName4
clear VarName5
clear VarName6
clear VarName7
clear VarName8
clear VarName9
clear VarName10
clear VarName11
clear VarName12