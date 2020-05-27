clc; clear all; close all;

transmission_rate = 100*1e3;  %(bytes/s)
dec_min_buffer = 2000*1e3 ;  % (Bytes)
encoded_data = importdata('../data/jarrasic_park_encoded_mp4_low.txt')';
[success, buffering_time, max_buffer_size] = simulate_buffer(encoded_data, transmission_rate, dec_min_buffer, false);

buffer_time = zeros(100);
max_buffer = zeros(100);



for trans_rate = 1000: 1000: 100000
    for min_buffer =  1000: 1000: 100000
        [success, buffering_time, max_buffer_size] = simulate_buffer(encoded_data, trans_rate, min_buffer, false);
        if success
            buffer_time(trans_rate/1000, min_buffer/1000) = buffering_time;
            max_buffer(trans_rate/1000, min_buffer/1000) = max_buffer_size;
        end
    end
end

% Plotting buffer time
% figure 
% trans_rate = 80;
% plot(1:100, buffer_time(trans_rate, :));
% ylabel('Data in Enc Buffer (KB)');
% xlabel('Min Buffer Time (s)');
% title('Transmission rate (KB): 80') 

%% 3D Plot 
figure
[X,Y] = meshgrid(1:100);
Z = buffer_time;
mesh(X, Y, Z);

xlabel('Transmission Rate (KB)')
ylabel('Buffer Size Begin Playback (KB)')
zlabel('Buffering Time (s)')

figure
[X,Y] = meshgrid(1:100);
Z = max_buffer/1e3;
mesh(X, Y, Z);

xlabel('Transmission Rate (KB)')
ylabel('Buffer Size Begin Playback (KB)')
zlabel('Max Data in Decoder Buffer (KB)')


if success
    disp("Successfully complete")
end

disp("Buffering time: " + buffering_time)
disp("Max Decoder Buffer: " + floor(max_buffer_size/1e3) + " KB")


% TODO: Deal with overflow of buffer
% TODO: Plot 3D transmission rate vs max_buffer vs buffering_time for cases
% that succeed