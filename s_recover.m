classdef (StrictDefaults) s_recover < matlab.System
    properties (Access=private)
        samp_rate = 0;
        samp_frame = 0;
        sound_block = [];
    end

    methods
        function obj = s_recover(samp_rate, samp_frame)
            obj.samp_rate = samp_rate;
            obj.samp_frame = samp_frame;
        end
    end

    methods (Access = protected)

        %Was not sure if ill be getting the entire block or just 200x1
        %chunks so configured it to add the chunks together and play sound
        %when complete.

        function stepImpl(obj,b_stream)
            
            % Add bit stream to the sound vec
            obj.sound_block = [obj.sound_block; b_stream];

            % when sound vec is complete, reconstuct audio
            if (size(obj.sound_block,1) >= (obj.samp_frame*8))
                % Convert and play sound
                b_matrix            = reshape(obj.sound_block, [], 8);
                audio_data          = bin2dec(b_matrix);
                audio_reconstruct   = typecast(uint8(audio_data), 'int8');
                s_normalized        = double(audio_reconstruct) / 128;
                sound(s_normalized, obj.samp_rate);

                % Reset sound vec
                obj.sound_block = [];
            end
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
    end    
end