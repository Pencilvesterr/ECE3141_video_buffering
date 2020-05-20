% Assuming endoding rate is same as decoding rate
encoded_data = importdata('jarrasic_park_encoded.txt');

%% Model Variables
% This assumes there has been some initial buffering. 
% Assumption just for now

encoder_bytes = 10000;
decoder_bytes = 10000;
transmission_byterate = 1600;

%% Running the model
minimum_encoder_size = Inf;
maximim_decoder_size = -Inf;

previously_transmitted = 0;

for i = 1:length(encoded_data)
    % TODO: Set upper limit on decoder buffer size
    decoder_bytes = decoder_bytes + previously_transmitted - encoded_data(i); 
    if encoder_bytes > maximim_decoder_size
        maximim_decoder_size = decoder_bytes;
    end
    
    % Data into encoder buffer
    encoder_bytes = encoder_bytes + encoded_data(i);
    if encoder_bytes < transmission_byterate
        previously_transmitted = encoder_bytes;
    else 
        previously_transmitted = transmission_byterate;
    end
    % Data transmitted out of encoder buffer
    encoder_bytes = encoder_bytes - previously_transmitted;

    if encoder_bytes < minimum_encoder_size
        minimum_encoder_size = encoder_bytes;
    end
    
end


minimum_encoder_size
maximim_decoder_size
