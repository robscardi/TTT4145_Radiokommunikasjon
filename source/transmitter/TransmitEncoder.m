classdef (StrictDefaults) TransmitEncoder < matlab.System
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
        
        Source 
        Destination
        
        FrameLength = 240;
    end
    

    % Discrete state properties
    properties (DiscreteState)
        state
    end


    % Pre-computed constants or internal states
    properties (Access = private, Nontunable)
        buffer
    end
    
    properties (Access = private)
        counter
        packetCounter
        secondInputSize
    end
    
    properties (Constant, Access = private)
        
    end

    methods
        % Constructor
        function obj = TransmitEncoder(varargin)
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

        function flag = isInputSizeMutableImpl(obj,index)
            % Return false if input size cannot change
            % between calls to the System object
            flag = false;
        end


        function setupImpl(obj, x)
            % Perform one-time calculations, such as computing constants
            obj.buffer = dsp.AsyncBuffer(10*obj.FrameLength);
            obj.counter = 0;
            a = size(x);
            obj.secondInputSize = a(2);
            
        end

        function resetImpl(obj)
            % Initialize internal buffer and related properties
            obj.state = transmitEncoderStates.WAIT;
            obj.counter = 0;
            obj.packetCounter = 0;
        end
        
        function [y, s] = stepImpl(obj,x, begin)
            % Implement algorithm. Calculate y as a function of input u and
            % internal or discrete states.
            
            ytemp = zeros(obj.FrameLength, 1);

            switch obj.state
                case transmitEncoderStates.WAIT
                    if(begin)
                        obj.state = transmitEncoderStates.START;
                    end
                case transmitEncoderStates.INITIALGARBAGE
                    if (obj.counter == 0)
                        obj.state = transmitEncoderStates.START;
                    end
                case transmitEncoderStates.START
                    
                     obj.state = transmitEncoderStates.LSF;
                    
                case transmitEncoderStates.LSF
                    ytemp = [obj.Destination; obj.Source];
                    obj.counter = 0;
                    % Golay encoding
                    obj.state = transmitEncoderStates.PACKET;
                    obj.packetCounter = 0;
                case transmitEncoderStates.PACKET
                    
                    curr_counter = int2bit(obj.packetCounter, 6);
                    data = x(1:200, min(obj.secondInputSize, obj.packetCounter+1) );
                    ytemp = [data; curr_counter; zeros(34,1)];
                    obj.packetCounter = obj.packetCounter +1;
                    if(obj.packetCounter == 64)
                        obj.state = transmitEncoderStates.LSF;
                    end

                    if ~begin
                        obj.state = transmitEncoderStates.EOT;
                    end
                case transmitEncoderStates.EOT
                    
                    obj.state = transmitEncoderStates.WAIT;
            end


            if comm.internal.utilities.isSim()
                y = ytemp;
            else
                y = coder.nullcopy(zeros(obj.FrameLength, 1, 'like', x));
                y(:,1) = ytemp(:);
            end
            s = obj.state;
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

        function varargout = getOutputSizeImpl(obj)
            % Return size for each output port
            varargout = {[obj.FrameLength,1], [1,1]};
        end

        function [out, out2] = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            out = propagatedInputDataType(obj,1);
            out2 = "transmitEncoderStates";
        end

        

        function [out, out2] = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
           
            % Example: inherit complexity from first input port
            out = propagatedInputComplexity(obj,1);
            out2 = false;
        end

        function [out,out2] = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            
            % Example: inherit fixed-size status from first input port
            out = propagatedInputFixedSize(obj,1);
            out2 = true;
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
