classdef (StrictDefaults) BERT_receiver < matlab.System
    % untitled2 Add summary here
    %
    % NOTE: When renaming the class name untitled2, the file name
    % and constructor name must be updated to use the class name.
    %
    % This template includes most, but not all, possible properties, attributes,
    % and methods that you can implement for a System object in Simulink.

    % Public, tunable properties
    properties

    end

    % Public, non-tunable properties
    properties (Nontunable)
        
        Message

    end
    
    properties 
   
    end
   

    % Discrete state properties
    properties (DiscreteState)
        currentPacket
        currentGlobalPacket
    end


    % Pre-computed constants or internal states
    properties (Access = private, Nontunable)
        BERT_calculator
    end
    
    properties (Access = private)
        skippedPackets
    end
    
    properties (Constant, Access = private)
        
    end

    methods
        % Constructor
        function obj = BERT_receiver(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
        end
    end

    methods (Access = private)
    end

    methods (Access = protected)
        %% Common functions
        function validateInputsImpl(obj, varargin)
        end

        function flag = isInputSizeMutableImpl(~,~)
            % Return false if input size cannot change
            % between calls to the System object
            flag = false;
        end


        function setupImpl(obj, frame, ~)
            % Perform one-time calculations, such as computing constants
            obj.BERT_calculator = comm.ErrorRate();
            obj.frameLength = lenght(frame);
            obj.skippedPackets = 0;
        end

        function resetImpl(obj)
            % Initialize internal buffer and related properties
            obj.currentPacket = -1;
            obj.skippedPackets = 0;
        end
        
        function [tx, rx, skipped_packet, number] = stepImpl(obj,frame)
            % Implement algorithm. Calculate y as a function of input u and
            % internal or discrete states.
            number = int64(bit2int(frame(201:200), 6));
            if number > 63 || number < 0
                fprintf("%s", "Error in packet number")
                tx_temp = ones(obj.frameLength, 1);
                rx_temp = zeros(obj.frameLength, 1);
                obj.skippedPackets = obj.skippedPackets +1;
            else
                if obj.currentPacket == -1
                    obj.currentPacket = number;
                    obj.currentGlobalPacket = number;
                    rx_temp = frame;
                    tx_temp = obj.Message(number);
                else
                    if number == obj.currentPacket
                        
                    elseif number ~= obj.currentPacket +1
                        fprintf("%s%d", "Skipped packet number: ", number)
                        tx_temp = ones(obj.frameLength, 1);
                        rx_temp = zeros(obj.frameLength, 1);
                        obj.skippedPackets = obj.skippedPackets +1;
                    else
                        obj.currentPacket = number;
                        rx_temp = frame;
                        tx_temp = obj.Message(number);
                        fprintf("%s%d", "Received packet number: ", number)
                    end
                end
            end
            skipped_packet = obj.skippedPackets;
            if comm.internal.utilities.isSim()
                rx = rx_temp;
                tx = tx_temp;
            else
                tx = coder.nullcopy(zeros(obj.frameLength, 1, 'like', x));
                tx(:,1) = tx_temp;
                rx = coder.nullcopy(zeros(obj.frameLength, 1, 'like', x));
                rx(:,1) = rx_temp;
            end
                        
        end

        function releaseImpl(obj)

        end

        function validatePropertiesImpl(obj)
            % Validate related or interdependent property values            
        end
  
        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj

            % Set public properties and states
            s = saveObjectImpl@matlab.System(obj);

            % Set private and protected properties
            %s.myproperty = obj.myproperty;
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s

            % Set private and protected properties
            % obj.myproperty = s.myproperty; 

            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        %% Simulink functions
        function ds = getDiscreteStateImpl(obj)
            % Return structure of properties with DiscreteState attribute
            ds = struct([]);
        end

        function [out,out2, out3, out4] = getOutputSizeImpl(obj)
            % Return size for each output port
            out = propagatedInputSize(obj,1);
            out2 = propagatedInputSize(obj,1);
            out3 = [1 1];
            out4 = [1 1];
        end

        function varargout = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            varargout =  {propagatedInputSize(obj,1), propagatedInputSize(obj,1), "double", "int32"};
            
        end

        

        function [out,out2, out3, out4] = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
           
            % Example: inherit complexity from first input port
            out = propagatedInputComplexity(obj,1);
            out2 = false;
            out3 = false;
            out4 = false;
            
        end

        function [out,out2, out3, out4] = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            
            % Example: inherit fixed-size status from first input port
            out = propagatedInputFixedSize(obj,1);
            out2 = true;
            out3 = true;
            out4 = true;
        end

        function [sz,dt,cp] = getDiscreteStateSpecificationImpl(obj,name)
            % Return size, data type, and complexity of discrete-state
            % specified in name
            sz = [1 1];
            dt = "double";
            cp = false;
        end

        function icon = getIconImpl(obj)
            % Define icon for System block
            icon = mfilename("class"); % Use class name
            % icon = "My System"; % Example: text icon
            % icon = ["My","System"]; % Example: multi-line text icon
            % icon = matlab.system.display.Icon("myicon.jpg"); % Example: image file icon
        end
    end

    methods (Static, Access = protected)
        %% Simulink customization functions
        function header = getHeaderImpl
            % Define header panel for System block dialog
            header = matlab.system.display.Header(mfilename("class"));
        end

        function group = getPropertyGroupsImpl
            % Define property section(s) for System block dialog
            group = matlab.system.display.Section(mfilename("class"));
        end
    end
end
