close all

for i = 1:9
    for j = 1:length(trimmed)
        trimmed(j, i) = trimmed(j, i) + 90 - i * 10;
    end
end

figure_init = figure(1);
figure_init.Position = [1000, 30, 200, 1300];

plot(trimmed(:, (1:9)), 'LineWidth', 2)
ylim([-10 90])

clear all