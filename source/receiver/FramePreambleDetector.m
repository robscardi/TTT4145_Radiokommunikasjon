classdef (StrictDefaults) FramePreambleDetector < matlab.System
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
        LSFPreamble = [3 -3]'
        BERTPreamble = [-3 3]'
        ENDPreamble = [3 -3]'
        WaitGuard = 0
        ThresholdMetric = 20
    end

    % Discrete state properties
    properties (DiscreteState)
        StartedComm
    end

    % Pre-computed constants or internal states
    properties (Access = private, Nontunable)
        PreambleLength
        detectLSF
        detectBERT
        detectEND

        pPrbLenOffset       % offset to get Preamble start index from end index
        pDataBuffer         % Data buffer object
        pDataBufferLength   % Data buffer length
        
        pPrbENDIdxBuffer
        pPrbBERTIdxBuffer
        pPrbLSFIdxBuffer
    end
    
    properties (Access = private)
        pLastDtMt           % Detection metric for the last preamble in the pPrbStartIdxBuffer
        pFirstCall = true
    end
    
    properties (Constant, Access = private)
        % 2 because, at most 1 in buffer, & at most 1 in input
        pPrbIdxBufferLength = 2; % Preamble start index buffer length
    end

    methods
        % Constructor
        function obj = FramePreambleDetector(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
        end
    end

    methods (Access = protected)
        %% Common functions
        function validateInputsImpl(obj, varargin)
            % Only floating-point supported for now.
            validateattributes(varargin{1}, {'double','single'}, ...
                {'finite', 'column'}, [class(obj) '.' 'Input'], 'Input');
            
            coder.internal.errorIf(~obj.pFirstCall && ...
                length(varargin{1}) > ...
                (length(obj.ENDPreamble)), ...
                'comm:FrameSynchronizer:InvalidInputLength');

        end

        function flag = isInputSizeMutableImpl(obj,index)
            % Return false if input size cannot change
            % between calls to the System object
            flag = false;
        end


        function setupImpl(obj, x)
            % Perform one-time calculations, such as computing constants
            obj.PreambleLength = length(obj.ENDPreamble);
            obj.detectLSF = comm.PreambleDetector(obj.LSFPreamble, Threshold= obj.ThresholdMetric, Detections = 'first');
            obj.detectBERT = comm.PreambleDetector(obj.BERTPreamble, Threshold= obj.ThresholdMetric, Detections = 'first');
            obj.detectEND = comm.PreambleDetector(obj.ENDPreamble, Threshold= obj.ThresholdMetric, Detections = 'first');
            
            obj.pDataBufferLength  = 2*obj.PreambleLength;
            obj.pDataBuffer        = dsp.AsyncBuffer(obj.pDataBufferLength);
            
            obj.pPrbENDIdxBuffer = dsp.AsyncBuffer(obj.pPrbIdxBufferLength);
            obj.pPrbBERTIdxBuffer = dsp.AsyncBuffer(obj.pPrbIdxBufferLength);
            obj.pPrbLSFIdxBuffer = dsp.AsyncBuffer(obj.pPrbIdxBufferLength);

            obj.pFirstCall         = false;
            setup(obj.pDataBuffer, cast(1,'like',x));
            obj.StartedComm = false;
        end

        function resetImpl(obj)
            % Initialize internal buffer and related properties
            obj.pDataBuffer.reset();
            obj.StartedComm = false;
        end

        function [y,type,commstarted] = stepImpl(obj,x)
            % Implement algorithm. Calculate y as a function of input u and
            % internal or discrete states.
            obj.pDataBuffer.write(x(:));
            buffer = obj.pDataBuffer.peek(obj.pDataBufferLength);
            type = 0;
            if obj.StartedComm
                [c, cmet] = obj.detectEND(buffer);
                if(~isempty(c))
                    [~, cMaxIdx] = max(cmet(c));
                    c = c(cMaxIdx);
                else                 
                    c = 0;
                end 
                if c > 0
                    obj.StartedComm = false;
                    type = 3;
                end
            else

                [a, amet] = obj.detectLSF(buffer);
                [b, bmet] = obj.detectBERT(buffer);
                if(~isempty(a))
                    [~, aMaxIdx] = max(amet(a));
                    a = a(aMaxIdx);
                    amet = aMaxIdx;
                else 
                    a = 0;
                    amet = 0;
                end
                if(~isempty(b))
                    [~, bMaxIdx] = max(bmet(b));
                    b = b(bMaxIdx);
                    bmet = bMaxIdx;
                else 
                    b = 0;
                    bmet = 0;
                end
                if (a > 0  && amet(a) > bmet(b))
                    type=1;
                    obj.StartedComm = true;
                    obj.pDataBuffer.read(a-1);

                elseif (b > 0 && bmet(b)>amet(a))
                    type=2;
                    obj.StartedComm = true;
                    obj.pDataBuffer.read(a-1);
                end
            end
            commstarted = obj.StartedComm;
            y = obj.pDataBuffer.peek(obj.PreambleLength); 
           
        end

        function releaseImpl(obj)
            obj.pFirstCall = true;
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
            ds = struct([obj.StartedComm]);
        end

        function varargout = getOutputSizeImpl(obj)
            % Return size for each output port
            %xout = propagatedInputSize(obj,1);

            % Example: inherit size from first input port
            % out = propagatedInputSize(obj,1);
            varargout = {size(obj.ENDPreamble), [1 1], [1 1]};
        end

        function [out,out2,out3] = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            out = "double";
            out2 = "double";
            out3 = "boolean";

            % Example: inherit data type from first input port
            % out = propagatedInputDataType(obj,1);
        end

        

        function [out,out2,out3] = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            out = true;
            out2 = false;
            out3 = false;

            % Example: inherit complexity from first input port
            % out = propagatedInputComplexity(obj,1);
        end

        function [out,out2,out3] = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            out = true;
            out2 = true;
            out3 = true;

            % Example: inherit fixed-size status from first input port
            % out = propagatedInputFixedSize(obj,1);
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
