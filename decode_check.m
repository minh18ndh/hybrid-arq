
save('received_64pkts_file.mat', 'received_file');

% Load the received file (from the receiver)
load('received_64pkts_file.mat');

% Load the original file (from the encoder)
load('original_64pkts_file.mat');

% Call the decoder function
[decoding_failures, successfully_decoded, decoded_file] = decoder(received_file, original_file);

% Display results
disp('Decoding Failures:');
disp(decoding_failures);

disp('Successfully Decoded:');
disp(successfully_decoded);

% Save the decoded file
save('decoded_64pkts_file.mat', 'decoded_file');
