classdef (StrictDefaults) s_transmit < matlab.System
    properties (Access=private)
        samp_rate = 0;          % Sample Rate in Hz
        samp_frame = 0;         % How many 8bit blocks to sample
        buffer = 0;             % buffer for reading
        i_device = 0;           % input device variable
        rec = 0;                % Variable for reading sound data
    end

    methods
        %Class Constructor
        function obj = s_transmit(samp_rate_i, samp_frame_i)
           obj.samp_rate    = samp_rate_i;
           obj.samp_frame   = samp_frame_i;
        end
    end

    methods (Access = protected)
        function s_out = stepImpl(obj)
            s_out = zeros(obj.samp_frame*8, 1);

            % Get sound data from the input device
            obj.rec = obj.i_device();
            
            % Save measured sound in the buffer
            write(obj.buffer, obj.rec);

            if obj.buffer.NumUnreadSamples >= (obj.samp_frame)
                % Get sound data from buffer
                data = read(obj.buffer);

                % Convert it to int and scale to relative [-1 1]
                audio_data  = int8(data * 128);
                
                % Convert it to a char array including int data: 0b00000000
                audio_binary = dec2bin(typecast(audio_data(:), 'uint8'), 8);

                %Output it as a Nx1 vector of the data from audio_binary
                s_out = audio_binary(:);
            end
        end

        function setupImpl(obj)
            obj.i_device    = audioDeviceReader("SampleRate", obj.samp_rate, "SamplesPerFrame", obj.samp_frame, "Device","Primary Sound Capture Driver");
            obj.buffer      = dsp.AsyncBuffer(obj.samp_rate);
        end

        function releaseImpl(obj)
            release(obj.i_device);
        end

        function ds = getDiscreteStateImpl(obj)
            % Return structure of properties with DiscreteState attribute
            ds = struct([]);
        end

        function icon = getIconImpl(obj)
            % Define icon for System block
            icon = mfilename("class"); % Use class name
            % icon = "My System"; % Example: text icon
            % icon = ["My","System"]; % Example: multi-line text icon
            % icon = matlab.system.display.Icon("myicon.jpg"); % Example: image file icon
        end

        function varargout = getOutputSizeImpl(obj)
            % Return size for each output port
            varargout = [obj.samp_frame*8 1];
        end

        function varargout = getOutputNamesImpl(obj)
            varargout = {'Sound Data'};
        end
    end
end