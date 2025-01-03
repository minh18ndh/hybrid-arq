% Initializes and runs HARQ sender

% Load encoded data matrix
load('encoded_64pkts_file.mat');

% suppress warning
warning('off','all');

% Configuration and connection
send = tcpip('127.0.0.1', 4013);
receive = tcpip('127.0.0.1', 4014, 'NetworkRole', 'server');

%send = tcpip('10.9.7.x', 4013);  
%receive = tcpip('0.0.0.0', 4014, 'NetworkRole', 'server');  % Listen on all interfaces

D = 1.5;
l = 72;
n = size(encoded_file,2);

%% initialization
cs = 0;
i = 1;

% Wait for connection
disp('Waiting for connection');
fopen(receive);
disp('Connection OK');

previous_f = 0;

total_transmitted_symbols = 0;

while 1
    %% receive DataSend_fromReceiver = [f]
    
    % Read data from the socket
    try
        DataReceived = fread(receive,1,'int32');
        f = DataReceived(1,1);
        %cr = DataReceived(2,1);
    catch
        continue;
    end
    
    if f ~= previous_f % receiver requests a new packet => i is reset to beginning of the packet
        i = 1;
    end
    
    display(f);

    cs = D*l;

    %% send DataSend = [f, i, value_i]
    % Open socket and wait before sending data
    fopen(send);
    pause(0.01);

    % transmission time
    while cs > 0
        DataToSend = [f, i, encoded_file(f,i)];
        fwrite(send,DataToSend,'int32');
        cs = cs-1;
        total_transmitted_symbols = total_transmitted_symbols + 1;
        i = mod(i+1, n+1); % cycle through symbols in the packet
        
        if i == 0
            i = 1; % reset to first symbol if end of packet is reached
        end
        
    end
    fclose(send);
    
    previous_f = f; % update the previously requested packet index
    
end
