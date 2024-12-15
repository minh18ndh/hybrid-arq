%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimized HARQ Receiver            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Suppress warning
warning('off', 'all');

% Configuration and connection
disp('Receiver started');
send = tcpip('127.0.0.1', 4014);
receive = tcpip('127.0.0.1', 4013, 'NetworkRole', 'server', 'Timeout', 0.5');

% Open the sockets once
fopen(send);
fopen(receive);

n = 254;
k = 128;
pkts_to_require = 64;

error_correction_capability = floor((n - k) / 2);

% Set channel loss and error probabilities
loss_p = 0.01;
error_p = 0.0001;

%% Initialization
cr = 0;

tic;

received_file = -1 * ones(pkts_to_require, n);

%% Request time
f = 1;

% Received packets counter
rx_no = 0;

received_symbols_per_packet = zeros(pkts_to_require, 1);
channel_losses = 0;
channel_errors = 0;
dec = 1;

while f <= pkts_to_require
    % Send R[f, cr]
    DataToSend = [f, cr];
    fwrite(send, DataToSend, 'int32');

    sprintf('%4.1f', str2double([num2str(f), '.', num2str(dec)]))

    flag = 1;
    first_round = 1;

    while flag
        try
            DataReceived = fread(receive, 5, 'int32');
            f1 = DataReceived(1, 1);
            l = DataReceived(2, 1);
            cs = DataReceived(3, 1);
            i = DataReceived(4, 1);
            pi = DataReceived(5, 1);
        catch
            break;
        end

        % Compute D
        if first_round
            D = cs / l;
            first_round = 0;
        end

        if cr >= l * D
            flag = 0;
        end

        % Introduce losses in the channel
        if rand(1) > loss_p
            % Introduce errors in the channel
            if rand(1) > error_p
                received_file(f1, i) = pi;
            else
                received_file(f1, i) = randi(n + 1) - 1;
                channel_errors = channel_errors + 1;
            end
            cr = cr + 1;
        else
            channel_losses = channel_losses + 1;
        end
    end

    not_rx_no = sum(received_file(f, :) == -1);

    % Ask for pi
    if not_rx_no <= error_correction_capability
        received_symbols_per_packet(f) = sum(received_file(f, :) > -1);

        % Ask for another file
        f = f + 1;
        dec = 1;
    else
        dec = dec + 1;
    end

    cr = 0;
end

% Close sockets (if execution ends)
fclose(send);
fclose(receive);

% Measure elapsed time
time = toc;

% Emit sound
beep;
