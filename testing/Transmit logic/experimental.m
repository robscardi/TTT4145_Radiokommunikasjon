close all
clear variables

global transmit_vector
transmit_vector = [];

% Create audio device reader
sound_samp = 8000;
i_device = audioDeviceReader("SampleRate", sound_samp, "SamplesPerFrame", 800, "Device", ...
    "Microphone Array (Intel® Smart Sound-teknologi for digitale mikrofoner)");
buffer = dsp.AsyncBuffer(sound_samp * 2);

t1 = timer('ExecutionMode', 'fixedRate', 'Period', 0.01, 'TimerFcn', @(~,~) tx_data(i_device, buffer));
t2 = timer('ExecutionMode', 'fixedRate', 'Period', 0.01, 'TimerFcn', @rx_data);

start(t1);
start(t2);
disp("Started Timers")
disp(buffer.NumUnreadSamples)

function tx_data(i_device, buffer)
    global transmit_vector

    sound = i_device();
    write(buffer, sound);
    disp("Gathering Audio")
    if buffer.NumUnreadSamples >= (8000 * 2)
        data = read(buffer);
        audio_data = int8(data * 128);
        audio_binary = dec2bin(typecast(audio_data(:), 'uint8'), 8);
        transmit_vector = audio_binary(:);
    end
end

function rx_data(~, ~)
    global transmit_vector
    
    if ~isempty(transmit_vector)
        binary_matrix = reshape(transmit_vector, [], 8); % Reshape back to matrix
        audio_data = bin2dec(binary_matrix); % Convert binary to decimal
        audio_reconstructed = typecast(uint8(audio_data), 'int8'); % Typecast to int16
        audio_reconstructed_normalized = double(audio_reconstructed) / 128; % Normalize to [-1, 1]
        sound(audio_reconstructed_normalized, 8000);
        transmit_vector = [];
    end
end

