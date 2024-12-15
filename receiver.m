%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimized HARQ Receiver            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Suppress warning
warning('off', 'all');

% Configuration and connection
disp('Receiver started');
send = tcpip('127.0.0.1', 4014); % Socket for sending feedback
receive = tcpip('127.0.0.1', 4013, 'NetworkRole', 'server', 'Timeout', 0.5'); % Socket for receiving data

% Open sockets
fopen(send);
fopen(receive);

% Parameters
n = 254;                % Codeword length
k = 128;                % Data length
pkts_to_require = 64;   % Total packets to decode
error_correction_capability = floor((n - k) / 2); % RS error correction capability

loss_p = 0.01;          % Packet loss probability
error_p = 0.0001;       % Bit error probability

% Initialization
cr = 0;                      % Cumulative redundancy counter
f = 1;                       % Current packet index
retransmitted_symbols = 0;   % Counter for retransmitted symbols
received_symbols_per_packet = zeros(pkts_to_require, 1);   % Symbols received per packet
channel_losses = 0;          % Channel loss counter
channel_errors = 0;          % Channel error counter
received_file = -1 * ones(pkts_to_require, n);             % Storage for received packets

tic; % Start timer

%% Receive Data
while f <= pkts_to_require
    % Send R[f, cr]
    DataToSend = [f, cr];
    fwrite(send, DataToSend, 'int32');

    disp(['Requesting packet ', num2str(f)]);

    flag = 1;
    first_round = 1;

    while flag
        try
            % Receive data
            DataReceived = fread(receive, 5, 'int32');
            f1 = DataReceived(1, 1); % Packet index
            l = DataReceived(2, 1);  % Length (l)
            cs = DataReceived(3, 1); % Remaining redundancy
            i = DataReceived(4, 1);  % Symbol index
            pi = DataReceived(5, 1); % Symbol value
        catch
            break; % Timeout, stop receiving
        end

        % Update redundancy ratio D on the first round
        if first_round
            D = cs / l;
            first_round = 0;
        end

        % Check if redundancy is sufficient
        if cr >= l * D
            flag = 0;
        end

        % Introduce losses and errors
        if rand(1) > loss_p
            % Check for channel errors
            if rand(1) > error_p
                % Check for retransmission
                if received_file(f1, i) ~= -1
                    retransmitted_symbols = retransmitted_symbols + 1;
                end
                % Store the received symbol
                received_file(f1, i) = pi;

                % Increment cumulative redundancy
                cr = cr + 1;

                % Log received symbol and CR update
                disp(['Received symbol for packet ', num2str(f), ', CR = ', num2str(cr)]);
            else
                % Introduce random error
                received_file(f1, i) = randi(n + 1) - 1;
                channel_errors = channel_errors + 1;
            end
        else
            channel_losses = channel_losses + 1; % Increment loss counter
        end
    end

    % Check if enough symbols have been received for packet f
    not_received_symbols = sum(received_file(f, :) == -1);

    if not_received_symbols <= error_correction_capability
        received_symbols_per_packet(f) = n - not_received_symbols;

        % Move to the next packet
        f = f + 1;
        cr = 0; % Reset CR for the new packet
    else
        % Continue requesting symbols for the same packet
        cr = 0; % Reset CR for next request
    end
end

% Close sockets
fclose(send);
fclose(receive);

% Measure elapsed time
time_elapsed = toc;

% Display results
disp('Simulation complete.');
disp(['Total retransmitted symbols: ', num2str(retransmitted_symbols)]);
disp(['Total time elapsed: ', num2str(time_elapsed), ' seconds.']);

% Save results
save('received_64pkts_file.mat', 'received_file');

% Emit sound (optional)
beep;
