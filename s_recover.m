classdef (StrictDefaults) s_recover < matlab.System
    properties (Access=private)
        audio_stream = [];
        samp_rate_hz = 0;
        samp_rate_frame = 0;
    end

    methods
        function obj = s_recover(samp_rate_i, samp_frame_i)
            obj.samp_rate_hz    = samp_rate_i;
            obj.samp_rate_frame = samp_frame_i;
        end
    end

    methods (Access = protected)
        function s_normalized = stepImpl(obj,b_stream)
            % Add a check and splicing of the b_stream to divide it into
            % sizable chunks

            if (size(b_stream) > [])
                % Cut into chunks
                
                output = []
                for i = 1:(b_stream)
                    
                end
                s_normalized = 1;
            else
                
            end

        end


        function s_block = block_voice(obj,b_stream)
            b_matrix            = reshape(b_stream, [], 8);
            audio_data          = bin2dec(b_matrix);
            audio_reconstruct   = typecast(uint8(audio_data), 'int8');
            s_block             = double(audio_reconstruct) / 128;
        end
    end


    
end