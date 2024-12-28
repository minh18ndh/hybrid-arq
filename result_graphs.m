% Data for plotting
packets = 64;
avg_channel_losses = channel_losses/packets;                        % Average symbol losses per packet
avg_channel_errors = channel_errors/packets;                        % Average symbol errors per packet
bit_error_rate = channel_errors / 14091;                            % BER (Bit Error Rate)
total_retransmitted_packets = total_retransmitted_time;             % Cumulative retransmissions
total_retransmitted_time_per_packet = total_retransmitted_time/packets;
execution_time = time;

% Plot setup
figure;
tiledlayout(2,2); % Create a 2x2 tiled layout for all metrics

% 1. Average Channel Losses and Errors
nexttile;
bars1 = bar([avg_channel_losses, avg_channel_errors]);
ylim([0, max([avg_channel_losses, avg_channel_errors]) * 1.2]); % Add 20% margin above the highest bar
title('Channel Losses and Errors per Packet');
xticklabels({'Average Losses/Packet', 'Average Errors/Packet'});
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
bars4 = bar([total_retransmitted_packets, total_retransmitted_time_per_packet]);
ylim([0, max([total_retransmitted_packets, total_retransmitted_time_per_packet]) * 1.2]);
title('Retransmission (cumulative number of times sender resends the same packet before moving to the next one)');
ylabel('Times');
xticklabels({'Total Retransmissions', 'Retransmissions/Packet'});
grid on;
add_values_on_top(bars4);

% 4. Execution time
nexttile;
bars2 = bar(execution_time);
ylim([0, execution_time * 1.2]);
title('Execution time (seconds)');
ylabel('Seconds');
xticks(1);
xticklabels({'Execution time'});
grid on;
add_values_on_top(bars2);

% Adjust overall layout
sgtitle('HARQ Protocol Performance Metrics with loss_p = 10%, error_p = 0.01% for 64 packets using RS(254, 128)');

% Function to add numbers on top of bars
function add_values_on_top(bars)
    for k = 1:length(bars.YData)
        text(k, bars.YData(k), sprintf('%.4f', bars.YData(k)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
    end
end
