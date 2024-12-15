%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimized HARQ Sender            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load encoded data matrix
load('encoded_64pkts_file.mat');

% Suppress warning
warning('off', 'all');

% Configuration and connection
send = tcpip('127.0.0.1', 4013);
receive = tcpip('127.0.0.1', 4014, 'NetworkRole', 'server');

l = 120;
n = size(encoded_file, 2);

D = 1.5;

%% Initialization
cs = 0;
i = 1;

% Wait for connection
disp('Waiting for connection');
fopen(receive);  % Open the receiver socket once
disp('Connection OK');

fopen(send);  % Open the sender socket once

previous_f = 0;
total_tx_pkts = 0;

while 1
    %% Receive R[f, cr]
    try
        DataReceived = fread(receive, 2, 'int32');
        f = DataReceived(1, 1);
        cr = DataReceived(2, 1);
    catch
        continue;
    end

    if f ~= previous_f
        i = 1;
    end

    display(f);

    cs = max(cs, D * (l - cr));

    %% Send S[f, l, cs, i, pi]
    while cs > 0
        % Prepare data to send
        DataToSend = [f, l, cs, i, encoded_file(f, i)];
        fwrite(send, DataToSend, 'int32');

        % Update counters
        cs = cs - 1;
        total_tx_pkts = total_tx_pkts + 1;
        i = mod(i + 1, n + 1);
        if i == 0
            i = 1;
        end
    end

    previous_f = f;
end

% Close sockets (if execution ends)
fclose(receive);
fclose(send);
