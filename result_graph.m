% Data for plotting
packets = 64;
avg_channel_losses = 1900/64;             % Average losses per packet
avg_channel_errors = 3/64;                % Average errors per packet
total_retransmissions = 1749;             % Total retransmitted symbols
retransmissions_per_packet = 1749 / 64;   % Average retransmissions per packet
bit_error_rate = 3 / 18432;               % BER (Bit Error Rate)
execution_time = 143.246;                 % Total execution time in seconds

% Plot setup
figure;
tiledlayout(2,2); % Create a 2x2 tiled layout for all metrics

% 1. Average Channel Losses and Errors
nexttile;
bars1 = bar([avg_channel_losses, avg_channel_errors]);
ylim([0, max([avg_channel_losses, avg_channel_errors]) * 1.2]); % Add 20% margin above the highest bar
title('Channel Losses and Errors per Packet');
xticklabels({'Avg Losses/Packet', 'Avg Errors/Packet'});
ylabel('Symbols');
grid on;
add_values_on_top(bars1);

% 2. Bit Error Rate (BER)
nexttile;
bars2 = bar(bit_error_rate * 100);
ylim([0, bit_error_rate * 100 * 1.2]);
title('Bit Error Rate (BER)');
ylabel('BER (%)');
xticks(1);
xticklabels({'BER'});
grid on;
add_values_on_top(bars2);

% 3. Retransmissions
nexttile;
bars3 = bar([total_retransmissions, retransmissions_per_packet]);
ylim([0, max([total_retransmissions, retransmissions_per_packet]) * 1.2]);
xticklabels({'Total Retransmissions', 'Retransmissions/Packet'});
ylabel('Symbols');
grid on;
add_values_on_top(bars3);

% 4. Execution Time
nexttile;
bars4 = bar(execution_time);
ylim([0, execution_time * 1.2]);
title('Execution Time');
ylabel('Time (seconds)');
xticks(1);
xticklabels({'Total Time'});
grid on;
add_values_on_top(bars4);

% Adjust overall layout
sgtitle('HARQ Protocol Performance Metrics with loss_p = 10%, error_p = 0.01% for 64 packets using RS(254, 128)');

% Function to add numbers on top of bars
function add_values_on_top(bars)
    for k = 1:length(bars.YData)
        text(k, bars.YData(k), sprintf('%.4f', bars.YData(k)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
    end
end
