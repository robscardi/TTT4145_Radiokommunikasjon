classdef (StrictDefaults) soundTransmit < matlab.System
    properties (Access=private)
        samp_rate = 0;          % Sample Rate in Hz
        samp_frame = 0;         % How many 8bit blocks to sample
        buffer = 0;             % buffer for reading
        i_device = 0;           % input device variable
        rec = 0;                % Variable for reader
        internal_reader = 0;    % Timer that constantly reads after activation
        o_reader = 0;           % Stores most recent read from the timer.
        
        s_data = 0;             % help me god
    end

    methods
        %Class Constructor
        function obj = soundTransmit(samp_rate_i, samp_frame_i)
           obj.samp_rate    = samp_rate_i;
           obj.samp_frame   = samp_frame_i;
        end

        function obj = init(obj)
            obj.i_device    = audioDeviceReader("SampleRate", obj.samp_rate, "SamplesPerFrame", obj.samp_frame, "Device","Internal Microphone (AMD Audio Device)");
            obj.buffer      = dsp.AsyncBuffer(obj.samp_frame);
        end

        function obj = start_reader(obj)
            obj.internal_reader =  timer('ExecutionMode', 'fixedRate', 'Period', 0.01, 'TimerFcn', @(~,~) obj.stepImpl());
            start(obj.internal_reader);
        end

        function o = get_data(obj)
            o = obj.o_reader;
        end

        function stop_reader(obj)
            stop(obj.internal_reader);
        end
    end

    methods (Access = protected)
        function y = stepImpl(obj)
            obj.o_reader = repmat('-', obj.samp_frame*8, 1);

            % Get sound data from the input device
            obj.rec = obj.i_device();
            
            % Save measured sound in the buffer
            write(obj.buffer, obj.rec);

            % In case buffer is not ready with data, keep it empty
            y = obj.o_reader;

            if obj.buffer.NumUnreadSamples >= (obj.samp_frame)
                % Get sound data from buffer
                data = read(obj.buffer);

                % Convert it to int and scale to relative [-1 1]
                audio_data  = int8(data * 128);
                
                plot(audio_data)

                % Convert it to a char array including int data: 0b00000000
                audio_binary = dec2bin(typecast(audio_data(:), 'uint8'), 8);
                
                obj.o_reader = audio_binary(:);

                %Output it as a Nx1 vector of the data from audio_binary
                y = audio_binary(:);

                obj.reset();
                
                % Saves data in another format (Nx8 double afaik), 
                % Fredrik request
                %obj.o_reader = decimalToBinaryVector(audio_data, 8);
                
            end
        end

        % Not sure if this script needs those? 
        % aka not sure when they trigger so commented them out, 

        % i_device is already handled in init
        function setupImpl(obj)
            obj.o_reader = repmat('-', obj.samp_frame*8, 1);
            %obj.i_device    = audioDeviceReader("SampleRate", obj.samp_rate, "SamplesPerFrame", obj.samp_frame, "Device", "Primary Sound Capture Driver");
            %obj.buffer      = dsp.AsyncBuffer(obj.samp_rate);
        end
        
        function resetImpl(obj)
            %reset(obj.i_device);
            %obj.buffer.reset();
            %obj.o_reader = 0;
            %obj.rec = 0;
        end

        % Not sure when they are called but this one frees the microphone
        % and stops the sound record timer.
        function releaseImpl(obj)
            %release(obj.i_device);
            %stop(obj.internal_reader);
        end
    end
end