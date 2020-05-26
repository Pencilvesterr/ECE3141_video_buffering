clc; clear all; close all;
% Model timestep is an indicidual frame (1/frame_per_second)
%% Encoded data values
encoded_data = importdata('data/jarrasic_park_encoded_mp4_low.txt')';
video_time = 3600; % (s)
frames = length(encoded_data);  % Each row is a compressed frame
fps = frames/video_time;  % 25 fps mp4
delta_t = 1 / fps;
mean_bit_rate = (sum(encoded_data)/video_time)/1e3;  % (KB/s)

%% Model Settings
transmission_rate = 100*1e3;  %(bytes/s)
max_buffer_size = 2000*1e3 ;  % (Bytes)

% Data in encoder at each time step
encoder_buffer = zeros(1, frames);  
decoder_buffer = zeros(1, frames);
dec_min_buffering = max_buffer_size * 3/4;

%% Simulation
time_step = 1;
max_transmit = floor(transmission_rate * delta_t);  % (bytes / frame timestep)

time_start_decoding = 1;
init_dec_buffer_complete = false;

transmission_compteled = false;

% TODO: What do when encoder buffer overflow?
while ~transmission_compteled
    %% Update data in encoder buffer
    % First frame, add to buffer but can't simultaneously transmit
    if time_step == 1
        encoder_buffer(time_step) = encoded_data(time_step);
    else
        % Add encoded data to enc buffer if frames available
        if time_step <= frames
            encoder_buffer(time_step) = encoder_buffer(time_step-1) + encoded_data(time_step);
        else
            % No new frames available
            encoder_buffer(time_step) = encoder_buffer(time_step - 1);
        end
    end
    
    current_transmit = max_transmit;
    if time_step == 1
        current_transmit = 0;
    
    % Transmit maximum available frames in enc buffer
    elseif encoder_buffer(time_step) < max_transmit
        current_transmit = encoder_buffer(time_step);
    end

    encoder_buffer(time_step) = encoder_buffer(time_step) - current_transmit;
    
    
    %% Update data in decoder buffer
    % Recieve transmitted data
    if time_step == 1
        decoder_buffer(time_step) = 0;
    else
        decoder_buffer(time_step) = decoder_buffer(time_step-1) + current_transmit;
    end
    
    % Decode next frame of playback
    if init_dec_buffer_complete
        % Check if remaining frames to decode
        if time_step-time_start_decoding > length(encoded_data)
            transmission_compteled = true;
            disp("All frames successfully transmitted")
            break
        end
            
        framedata_to_decode = encoded_data(time_step-time_start_decoding);
        if decoder_buffer(time_step) < framedata_to_decode 
            % Buffer underflow. Finish.
            transmission_compteled = true;
            disp("Buffer Underflow: " + time_step / fps);
            break
        else
            decoder_buffer(time_step) = decoder_buffer(time_step) - framedata_to_decode;
        end
    end
    
    % Check if min buffer size is reached to start playback
    if ~init_dec_buffer_complete && decoder_buffer(time_step) > dec_min_buffering
        init_dec_buffer_complete = true;
        time_start_decoding = time_step;
    end
    
    time_step = time_step + 1;
end


elapsed_time = (time_step-1) * delta_t;  %(s)



% Standardize all vectors to have 0 values for any other times
initial_buffering_time = zeros(1,time_start_decoding);
decoder_buffer = [initial_buffering_time decoder_buffer];
additional_decoding_time = zeros(1, length(decoder_buffer)-length(encoder_buffer));
encoder_buffer = [encoder_buffer additional_decoding_time];

disp("Buffering time: " + length(additional_decoding_time)/ fps)

time_x = 0:delta_t:((length(encoder_buffer)-1)*delta_t);
%% Plot Results
subplot(2,1,1)
plot(time_x,encoder_buffer./1e3), ylabel('Data in Enc Buffer (KB)');
subplot(2,1,2)
plot(time_x,decoder_buffer./1e3),xlabel('Time (s)'),ylabel('Data in Dec Buffer (KB)')


for i = 1:2
% %% Model Variables
% % This assumes there has been some initial buffering. 
% % Assumption just for now
% 
% encoder_bytes = 10000;
% decoder_bytes = 10000;
% transmission_byterate = 160;
% 
% %% Running the model
% minimum_encoder_size = Inf;
% maximim_decoder_size = -Inf;
% 
% previously_transmitted = 0;
% 
% for i = 1:length(encoded_data)
%     % TODO: Set upper limit on decoder buffer size
%     % TODO: Find how many elements are transferred per second 
%     % Decoder recieveing transmitted value
%     decoder_bytes = decoder_bytes + previously_transmitted;
%     
%     - encoded_data(i); 
%     if encoder_bytes > maximim_decoder_size
%         maximim_decoder_size = decoder_bytes;
%     end
%     
%     % Data into encoder buffer
%     encoder_bytes = encoder_bytes + encoded_data(i);
%     if encoder_bytes < transmission_byterate
%         previously_transmitted = encoder_bytes;
%     else 
%         previously_transmitted = transmission_byterate;
%     end
%     % Data transmitted out of encoder buffer
%     encoder_bytes = encoder_bytes - previously_transmitted;
% 
%     if encoder_bytes < minimum_encoder_size
%         minimum_encoder_size = encoder_bytes;
%     end
%     
% end
% 
% 
% minimum_encoder_size
% maximim_decoder_size
end
