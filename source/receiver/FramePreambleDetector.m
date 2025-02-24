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
        LSFPreamble
        BERTPreamble
        ENDPreamble
        WaitGuard = 0
        ThresholdMetric = 20
    end

    % Discrete state properties
    properties (DiscreteState)
        StartedComm
    end

    % Pre-computed constants or internal states
    properties (Access = private, Nontunable)
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
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.PreambleLength = length(obj.ENDPreamble);
            obj.detectLSF = comm.PreableDetector(LSFPreable, Threshold= obj.ThresholdMetric, Detections = 'first');
            obj.detectBERT = comm.PreableDetector(BERTPreable, Threshold= obj.ThresholdMetric, Detections = 'first');
            obj.detectEND = comm.PreableDetector(ENDPreable, Threshold= obj.ThresholdMetric, Detections = 'first');
            
            obj.pDataBufferLength  = 2*obj.PreambleLength;
            obj.pDataBuffer        = dsp.AsyncBuffer(obj.pDataBufferLength);
            
            obj.pPrbENDIdxBuffer = dsp.AsyncBuffer(obj.pPrbIdxBufferLength);
            obj.pPrbBERTIdxBuffer = dsp.AsyncBuffer(obj.pPrbIdxBufferLength);
            obj.pPrbLSFIdxBuffer = dsp.AsyncBuffer(obj.pPrbIdxBufferLength);

            obj.pFirstCall         = false;
            setup(obj.pDataBuffer, cast(1,'like',x));
            setup(obj.pPrbStartIdxBuffer, 1);
            obj.pLastDtMt = 0;
        end

        function resetImpl(obj)
            % Initialize internal buffer and related properties
            obj.pDataBuffer.reset();
            obj.pPrbStartIdxBuffer.reset();
            obj.pLastDtMt = 0;
            obj.StartedComm = false;
        end

        function [y,type,commstarted] = stepImpl(obj,x)
            % Implement algorithm. Calculate y as a function of input u and
            % internal or discrete states.
            obj.pDataBuffer.write(x(:));

            if obj.StartedComm
                [c, ~] = obj.detectEND(obj.pDataBuffer);
                if c > 0
                    obj.StartedComm = false;
                end
            else

                [a, amet] = obj.detectLSF(obj.pDataBuffer);
                [b, bmet] = obj.detectBERT(obj.pDataBuffer);
                if (a~= 0 && amet > bmet)
                    type=1;
                    obj.StartedComm = true;
                    obj.pDataBuffer.read(obj.PreambleLength + a-1);

                elseif (b~= 0 && bmet>amet)
                    type=2;
                    obj.StartedComm = true;
                    obj.pDataBuffer.read(obj.PreambleLength + a-1);
                else
                    type=0;
                end
            end
            commstarted = obj.StartedComm;
            y = 
           
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

        function out = getOutputSizeImpl(obj)
            % Return size for each output port
            out = [1 1];

            % Example: inherit size from first input port
            % out = propagatedInputSize(obj,1);
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
