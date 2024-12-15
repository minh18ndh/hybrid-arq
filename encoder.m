function [ encoded_file, original_file ] = encoder( )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate and encode data        %
%   file_to_encode must be double %
%   encoded_file is double        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

m = 8;              % Number of bits per symbol

% n-k must be a positive even integer
n = 254;            % 2^m - 2: codeword length
k = 8;              % Word length

pkt_no = 64;        % Number of packets of original file

tic;

original_file_gf = gf(zeros(pkt_no, k), m);
encoded_file_gf = gf(zeros(pkt_no, n), m);

for i = 1 : pkt_no
    original_pkt = gf(randi([0,1], k, 1), m);    % Two rows of m-bit symbols
    original_file_gf(i,:) = original_pkt;
    
    encoded_pkt = transpose(rsenc(transpose(original_pkt), n, k));
    encoded_file_gf(i,:) = encoded_pkt;
    
    disp(i);
end

original_file = gf2double(original_file_gf);
encoded_file = gf2double(encoded_file_gf);

time = toc;

display(time);

save('original_64pkts_file.mat', 'original_file');
save('encoded_64pkts_file.mat', 'encoded_file');

end