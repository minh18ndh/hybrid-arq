% Data for plotting
packets = 64;
avg_channel_losses = 3.3;                 % Average losses per packet
avg_channel_errors = 0.016;               % Average errors per packet
total_retransmissions = 6651;             % Total retransmitted symbols
retransmissions_per_packet = 6651 / 64;   % Average retransmissions per packet
bit_error_rate = 4.37e-5;                 % BER (Bit Error Rate)
execution_time = 136.1;                   % Total execution time in seconds

% Plot setup
figure;
tiledlayout(2,2); % Create a 2x2 tiled layout for all metrics

% 1. Average Channel Losses and Errors
nexttile;
bars1 = bar([avg_channel_losses, avg_channel_errors]);
title('Channel Losses and Errors per Packet');
xticklabels({'Avg Losses/Packet', 'Avg Errors/Packet'});
ylabel('Symbols');
grid on;
add_values_on_top_and_resize(bars1);

% 2. Bit Error Rate (BER)
nexttile;
bars2 = bar(bit_error_rate * 100);
title('Bit Error Rate (BER)');
ylabel('BER (%)');
xticks(1);
xticklabels({'BER'});
grid on;
add_values_on_top_and_resize(bars2);

% 3. Retransmissions
nexttile;
bars3 = bar([total_retransmissions, retransmissions_per_packet]);
title('Retransmissions');
xticklabels({'Total Retransmissions', 'Retransmissions/Packet'});
ylabel('Symbols');
grid on;
add_values_on_top_and_resize(bars3);

% 4. Execution Time
nexttile;
bars4 = bar(execution_time);
title('Execution Time');
ylabel('Time (seconds)');
xticks(1);
xticklabels({'Total Time'});
grid on;
add_values_on_top_and_resize(bars4);

% Adjust overall layout
sgtitle('HARQ Protocol Performance Metrics');

% Function definition at the end of the script
function add_values_on_top_and_resize(bars)
    ydata = bars.YData;                % Get the bar heights
    max_y = max(ydata);                % Find the maximum bar height
    ylim([0, max_y * 1.2]);            % Set y-axis limits with extra 20% space
    
    for k = 1:length(ydata)
        text(k, ydata(k), sprintf('%.4f', ydata(k)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
    end
end
