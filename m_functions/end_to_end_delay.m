clear all; close all; clc;
%% import data
% Assuming endoding rate is same as decoding rate
encoded_data = importdata('jarrasic_park_encoded.txt');
%% define variables

%in bits
peak_frame_size = 65232;
mean_frame_size = 6149; 

%bits/sec
peak_br = 1630800;
mean_br = 153724.768603398;

buffer_size = zeros(1,5);
buffer_duration = zeros(1,5);
%% End to end delay with given buffer

%other delays such as video compression/decompression, network processing
%and transfer, display preprocessing
%other_delay excluding network transfer is <<5ms so can be excluded for
%now

%havent considered preloading yet
avg_transfer_rate = 11.1e6;
max_end_to_end = zeros(1,5);

transfer_time = avg_transfer_rate*peak_frame_size;

%% buffer size of 1-5x video bitrate
for i = 1:5
    buffer_size(1,i) = i*mean_br;
    buffer_duration(1,i) = buffer_size(1,i)/peak_br;
    
    max_end_to_end(1,i) = transfer_time+buffer_duration(1,i);
end

%% plotting
% buffer size vs buffer duration
plot(buffer_size, buffer_duration, 'r*');
% line of best fit
p = polyfit(buffer_size, buffer_duration,1);
f = polyval(p,buffer_size);
hold on
plot(buffer_size, f)
title('Buffer Duration (sec) vs Buffer Size (bits)');
xlabel('Buffer Size (bits)');
ylabel('Buffer Duration (sec)');

% buffer size vs end to end delay
figure
plot(buffer_size, max_end_to_end, 'bo');
p = polyfit(buffer_size, max_end_to_end,1);
f = polyval(p,buffer_size);
hold on
plot(buffer_size, f)
title('End to End Delay (sec) vs Buffer Size (bits)');
xlabel('Buffer Size (bits)');
ylabel('End to End Delay (sec)');


