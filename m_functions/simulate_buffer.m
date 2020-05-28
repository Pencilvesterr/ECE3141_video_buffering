function [success, buffering_time, max_buffer_size] = simulate_buffer(encoded_data, avg_transmission_rate, trans_std_dev, dec_min_buffer, plt, print)
% SIMULATE_BUFFER Model a buffer with encoded frame datat. Returns buffering time.
% Written by Morgan Crouch
% Inputs
%   encoded_data      [1xn] vector of byte sizes for n-frames 
%   transmission_rate [scalar] transmisson from enc to dec (bytes/s)
%   max_buffer_size   [scalar] Decoder size (bytes)
%   plt               bool; Plot Encoder/Decoder data over time
% Outputs
%   success           Boolean of if model ran without under/overflowing
%   buffering_time    Time in seconds required to buffer
%   max_buffer_size   Max data the buffer help (bytes)

%% Encoded data values
video_time = 3600; % (s)
frames = length(encoded_data);  % Each row is a compressed frame
fps = frames/video_time;  % 25 fps mp4
delta_t = 1 / fps;
mean_bit_rate = (sum(encoded_data)/video_time)/1e3;  % (KB/s)


%% Model Simulation
% Each discrete time step is a single frame being processed
encoder_buffer = zeros(1, frames);  
decoder_buffer = zeros(1, frames);
time_step = 1;

time_start_decoding = 1;
init_dec_buffer_complete = false;
transmission_compteled = false;
% TODO: What do when encoder buffer overflow?
while ~transmission_compteled
    %% Update data in encoder buffer
    % Transmission rate can be constant or chosen rnd from distribution
    % If std_deviation = 0, will be const transmission rate
    transmission_rate = trans_std_dev*randn(1) + avg_transmission_rate;
    if transmission_rate < 0
        transmission_rate = 0;
    end
    max_transmit = floor(transmission_rate * delta_t);  % (bytes / frame timestep)
    
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
            % Complete success
            transmission_compteled = true;
            
            continue
        end
            
        framedata_to_decode = encoded_data(time_step-time_start_decoding);
        if decoder_buffer(time_step) < framedata_to_decode 
            % Buffer underflow. Finish.
            transmission_compteled = true;
            continue
        else
            decoder_buffer(time_step) = decoder_buffer(time_step) - framedata_to_decode;
        end
    end
    
    % Check if min buffer size is reached to start playback
    if ~init_dec_buffer_complete && decoder_buffer(time_step) > dec_min_buffer
        init_dec_buffer_complete = true;
        time_start_decoding = time_step;
    end
    
    time_step = time_step + 1;
end
% Check model completed
if frames == time_step - time_start_decoding -1
    success = true;
else
    success = false;
end
%% Plot Results
% Standardize all vectors to have 0 values for any other times
initial_buffering_time = zeros(1,time_start_decoding);
decoder_buffer = [initial_buffering_time decoder_buffer];

additional_decoding_time = zeros(1, length(decoder_buffer)-length(encoder_buffer));
encoder_buffer = [encoder_buffer additional_decoding_time];
buffering_time = length(additional_decoding_time)/fps;

time_x = 0:delta_t:((length(encoder_buffer)-1)*delta_t);
max_buffer_size = max(decoder_buffer);
if plt
    subplot(2,1,1)
    plot(time_x,encoder_buffer./1e3), ylabel('Data in Enc Buffer (KB)');
    subplot(2,1,2)
    plot(time_x,decoder_buffer./1e3),xlabel('Time (s)'),ylabel('Data in Dec Buffer (KB)')
end
if print
    if success
        disp('Success')
    else
        disp('Underflow')
    end
    
    
    disp('Max Buffer Size: ')
    disp(max_buffer_size)
    disp('Buffering Time: ')
    disp(buffering_time)
end


