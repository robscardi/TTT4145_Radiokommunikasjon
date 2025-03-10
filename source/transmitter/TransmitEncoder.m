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
        
        Destination 
        Source 
        
        BitNumber (1,1) {mustBeInteger, mustBePositive} = 96

    end
    
    properties 
    

        ThresholdMetric (1,1) {mustBeFloat, mustBeReal, mustBeFinite, mustBeNonnegative} = 20
    
    end
   

    % Discrete state properties
    properties (DiscreteState)
        commStarted
        currentState
    end


    % Pre-computed constants or internal states
    properties (Access = private, Nontunable)
        
    end
    
    properties (Access = private)
        METADATA
        CRC
    end
    
    properties (Constant, Access = private)
        StartValues=[1,41,81,121,161,201];
        GolayParts=[1,13,25,37];
        InputParts=[1,25,49,73];
        additionalBits = 12;
        P = hex2poly('0xC75');
        
    end

    methods
        % Constructor
        function obj = FramePreambleDetector(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
        end
    end
    methods (Access = private)
        function GDI = golayInput(d,ChunkArray,G,GolayParts,StartValues,Arrays...
                ,LSF,OutputParts)
            i=mod(d-1,6)+1;
            start=StartValues(i);
            Chunk=LSF(start:start+40-1);
            ChunkArray(d,:) = [Chunk,decToArray(i,1,8)];
            for j=1:4
                section=GolayParts(j);
                m=ChunkArray(d,section:section+12-1);
                v=mod(m*G,2);
                section=OutputParts(j);
                Arrays(section:section+24-1) = v;
            end
            GDI=[0,Arrays];
        end

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
            obj.LUT = containers.Map();
            obj.NOF = obj.BitNumber/obj.additionalBits;
            
            
            [~,G_] = cyclgen(23, obj.P);
 
            G_P = G_(1:12, 1:11);
            I_K = eye(12);
            obj.G = [I_K G_P obj.P.'];
            obj.H = [transpose([G_P obj.P.']) I_K];
            
        end

        function resetImpl(obj)
            % Initialize internal buffer and related properties
        end
        
        function [y, correct] = stepImpl(obj,x)
            % Implement algorithm. Calculate y as a function of input u and
            % internal or discrete states.
            ytemp = zeros(length(x)/2, 1);
            for j=1:4
                section=obj.InputParts(j);
                InputVectorSection = x(n,section:section+24-1);
                s=mod(obj.H*InputVectorSection',2);
                if s(1:12)==0
                    correct = true;
                    %disp("No errors")
                else
                    if isKey(obj.LUT,num2str(s'))
                        error_pattern = obj.LUT(num2str(s'));
                        c_corrected = xor(InputVectorSection,error_pattern);
                        correct = true;
                        %disp("Error Corrected")
                    else
                        c_corrected = InputVectorSection;
                        correct = false;
                        %disp("Error Detected")
                    end
                    ytemp(n,section:section+24-1)=c_corrected;
                end
            end
            if comm.internal.utilities.isSim()
                y = ytemp;
            else
                y = coder.nullcopy(zeros(obj.FrameLength, 1, 'like', x));
                y(:,1) = ytemp;
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

        function varargout = getOutputSizeImpl(obj)
            % Return size for each output port
            varargout = {propagatedInputSize(obj,1), [1,1]};
        end

        function [out, out2] = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            out = propagatedInputDataType(obj,1);
            out2 = "boolean";
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
