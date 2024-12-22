% Initializes and runs HARQ receiver

% suppress warning
warning('off','all');

% Configuration and connection
disp ('Receiver started');
send = tcpip('127.0.0.1',4014);
receive = tcpip('127.0.0.1', 4013,'NetworkRole','server', 'Timeout', 0.5);

%send = tcpip('10.9.7.162', 4014);
%receive = tcpip('0.0.0.0', 4013, 'NetworkRole', 'server', 'Timeout', 0.5);

% Open socket and wait before sending data
fopen(send);
pause(0.01);

n = 254;
k = 128;

error_correction_capability = floor((n-k)/2);

% set channel loss probability
loss_p = 0.1;

% set channel error probability
error_p = 0.0001;

pkts_to_require = 64;

%% initialization
cr = 0;

tic;

received_file = -1 * ones(pkts_to_require, n);

%% request time
f = 1; 

retransmitted_symbols = 0; 

received_symbols_per_packet = zeros(pkts_to_require,1);
channel_losses = 0;
channel_errors = 0;
dec = 1;

while f <= pkts_to_require
    DataToSend = [f, cr];
    fwrite(send, DataToSend, 'int32');
    
    sprintf('%4.1f', str2double([num2str(f), '.', num2str(dec)]))
    
    % receive S[f, l, cs, i, value_i]
    fopen(receive);

    while 1
        try
            DataReceived = fread(receive, 5, 'int32');
            f1 = DataReceived(1,1);
            l = DataReceived(2,1);
            cs = DataReceived(3,1);
            i = DataReceived(4,1);
            value_i = DataReceived(5,1);
        catch
            break;
        end
                    
        % introduce losses in the channel
        if rand(1) > loss_p
            % introduce errors in the channel
            if rand(1) > error_p
                % received symbol is not lost or erroneous but useless
                if received_file(f1,i) ~= -1 % symbol position already received
                    retransmitted_symbols = retransmitted_symbols + 1;
                end
                received_file(f1,i) = value_i;
            else
                received_file(f1,i) = randi(n+1) - 1; % assign random symbol value for error simulation
                channel_errors = channel_errors + 1;
            end
            cr = cr+1; % increase total number of received symbols (both correct and incorrect)
            %disp(['cr = ', num2str(cr)]);
        else
            channel_losses = channel_losses + 1;
        end        
    end
    %disp(['cr = ', num2str(cr)]);
    fclose(receive);
    
    % calculate missing symbols for ACK/NACK decision
    not_received_symbols = 0;
    for i = 1:size(received_file, 2)
        if received_file(f,i) == -1
            not_received_symbols = not_received_symbols + 1;
        end
    end
    disp(['nrs = ', num2str(not_received_symbols)]);
    
    % if can decode then ask for next packet (send ACK)
    if not_received_symbols <= error_correction_capability
        for i = 1:size(received_file,2)
            if received_file(f,i) > -1
                received_symbols_per_packet(f) = received_symbols_per_packet(f) + 1;
            end
        end
        
        % ask for next packet
        f = f+1;
        dec = 1;
    else
        dec = dec+1; % increase the number of transmission attempt for 1 packet
    end
    
    cr = 0;
    
end

fclose(send);

% measure time elapsed
time = toc;

% Display results
disp('Simulation complete.');
disp(['Total retransmitted symbols: ', num2str(retransmitted_symbols)]);
disp(['Total time elapsed: ', num2str(time), ' seconds.']);

% Save results
save('received_64pkts_file.mat', 'received_file');

% emit sound
beep;