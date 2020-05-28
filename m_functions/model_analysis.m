clc; clear all; close all;

transmission_rate = 100*1e3;  %(bytes/s)
dec_min_buffer = 2000*1e3 ;  % (Bytes)
encoded_data = importdata('../data/jarrasic_park_encoded_mp4_low.txt')';

step_size = 1000;
trans_min = 30000; 
trans_max = 75000;
min_buffer_min = 1000;
min_buffer_max = 150000;
trans_rate_vec = trans_min: step_size: trans_max;
min_buffer_vec = min_buffer_min: step_size: min_buffer_max;

buffer_times = zeros(length(trans_rate_vec), (length(min_buffer_vec)));
max_buffers = zeros(length(trans_rate_vec), (length(min_buffer_vec)));

for trans_rate = trans_rate_vec
    trans_i = (trans_rate - trans_min) / step_size + 1;
    for min_buffer = min_buffer_vec
        min_buff_j = (min_buffer - min_buffer_min )/ step_size + 1;
        [success, buffering_time, max_buffer_size] = simulate_buffer(encoded_data, trans_rate, min_buffer, false, false);
        if success
            buffer_times(trans_i, min_buff_j) = buffering_time;
            max_buffers(trans_i, min_buff_j) = max_buffer_size;
        end
    end
end

%% Print single 2D Plot
plot_tans_rate = 800e3;
plot_min_buffer = 8e3;
[success, buffering_time, max_buffer_size] = simulate_buffer(encoded_data, plot_tans_rate, plot_min_buffer, true, true);

%% 3D Plot 
figure
[X,Y] = meshgrid(trans_rate_vec/1000, min_buffer_vec/1000);
Z = buffer_times';
mesh(X, Y, Z);

title('Required Buffering Time')
xlabel('Transmission Rate (KB)')
ylabel('Buffer Size Begin Playback (KB)')
zlabel('Buffering Time (s)')

figure
Z = max_buffers'/1e3;
mesh(X, Y, Z);

title('Required Decoder Buffer Size')
xlabel('Transmission Rate (KB/s)')
ylabel('Buffer Size Begin Playback (KB)')
zlabel('Max Data in Decoder Buffer (KB)')