% Initializes and runs HARQ sender

% Load encoded data matrix
load('encoded_64pkts_file.mat');

% suppress warning
warning('off','all');

% Configuration and connection
send=tcpip('127.0.0.1', 4013);
receive=tcpip('127.0.0.1', 4014, 'NetworkRole', 'server');

%send = tcpip('10.9.7.x', 4013);  
%receive = tcpip('0.0.0.0', 4014, 'NetworkRole', 'server');  % Listen on all interfaces

l = 96;
n = size(encoded_file,2);

D = 1.5;

%% initialization
cs = 0;
i = 1;

% Wait for connection
disp('Waiting for connection');
fopen(receive);
disp('Connection OK');

previous_f = 0;

while 1
    %% receive R[f, cr]
    
    % Read data from the socket
    try
        DataReceived = fread(receive,2,'int32');
        f = DataReceived(1,1);
        cr = DataReceived(2,1);
    catch
        continue;
    end
    
    if f ~= previous_f
        i = 1;
    end
    
    display(f);

    cs = max(cs, D*(l-cr));

    %% send S[f, l, cs, i, pi]
    % Open socket and wait before sending data
    fopen(send);
    pause(0.01);

    % transmission time
    while cs > 0
        DataToSend = [f, l, cs, i, encoded_file(f,i)];
        fwrite(send,DataToSend,'int32');
        cs = cs-1;
        total_transmitted_symbols = total_transmitted_symbols + 1;
        i = mod(i+1, n+1);
        
        if i == 0
            i = 1;
        end
        
    end
    fclose(send);
    
    previous_f = f;
    
end
