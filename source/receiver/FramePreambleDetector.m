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
        LSFPreamble {mustBeFloat, mustBeFinite} = [3 -3]'
        BERTPreamble {mustBeFloat, mustBeFinite} = [-3 3]'
        ENDPreamble {mustBeFloat, mustBeFinite} = [3 -3]'

        LSFSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'
        BERTSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'
        StreamSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'
        PacketSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'
        FrameLength {mustBeInteger, mustBeFinite} = 192
        WaitGuard {mustBeInteger, mustBeFinite} = 0

    end
    
    properties 
    

        ThresholdMetric (1,1) {mustBeFloat, mustBeReal, mustBeFinite, mustBeNonnegative} = 20
    
    end

    % Discrete state properties
    properties (DiscreteState)
        StartedComm
    end

    % Pre-computed constants or internal states
    properties (Access = private, Nontunable)
        PreambleLength
        SyncLength

        detectLSF
        detectBERT
        detectEND

        detectSyncLSF
        detectSyncBERT
        detectSyncStream
        detectSyncPacket

        pDataBufferLength 
        pDataBuffer 
        pSyncIndexBuffer
        

    end
    
    properties (Access = private)
        pLastDtMt           % Detection metric for the last preamble in the pPrbStartIdxBuffer
        pFirstCall = true
    end
    
    properties (Constant, Access = private)
        % 2 because, at most 1 in buffer, & at most 1 in input
        pSyncIdxBufferLength = 2; % Preamble start index buffer length
    end

    methods
        % Constructor
        function obj = FramePreambleDetector(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
        end
    end
    methods (Access = private)
        function [index, metric] = analyzeDetectReturn (obj, idx, metric)
            if(~isempty(idx))
                [~, MaxIdx] = max(metric(idx));
                index = idx(MaxIdx);
                metric = metric(MaxIdx);
            else
                index = 0;
                metric = -1;
            end
        end

        function z = readFromBuffer(obj, sf)
            a = obj.pDataBuffer.read(sf(2));
            z = a(sf(1):end);
        end

        function discardFromBuffer(obj, idx)
            obj.pDataBuffer.read(idx);
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
            obj.SyncLength = length(obj.BERTSyncBurst);
            
            %% Frame Preable Detectors
            obj.detectLSF = comm.PreambleDetector(obj.LSFPreamble, Threshold= obj.ThresholdMetric, Detections = "First");
            obj.detectBERT = comm.PreambleDetector(obj.BERTPreamble, Threshold= obj.ThresholdMetric, Detections = "First");
            obj.detectEND = comm.PreambleDetector(obj.ENDPreamble, Threshold= obj.ThresholdMetric, Detections = "First");
            
            %% Sync Burst detectors 
            obj.detectSyncBERT = comm.PreambleDetector(obj.BERTSyncBurst,Threshold=obj.ThresholdMetric , Detections="First");
            obj.detectSyncLSF = comm.PreambleDetector(obj.LSFSyncBurst,Threshold=obj.ThresholdMetric , Detections="First");
            obj.detectSyncPacket = comm.PreambleDetector(obj.PacketSyncBurst,Threshold=obj.ThresholdMetric , Detections="First");
            obj.detectSyncStream = comm.PreambleDetector(obj.StreamSyncBurst,Threshold=obj.ThresholdMetric , Detections="First");
            
            %%
            obj.pDataBufferLength  = 3*(obj.FrameLength + obj.WaitGuard);
            obj.pDataBuffer        = dsp.AsyncBuffer(obj.pDataBufferLength);
            

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
            if obj.StartedComm
                
                [c_, cmet_] =   obj.detectEND(buffer);
                [BE_, BEmet_] = obj.detectSyncBERT(buffer);
                [LS_, LSmet_] = obj.detectSyncLSF(buffer);
                [PA_, PAmet_] = obj.detectSyncPacket(buffer);
                [ST_, STmet_] = obj.detectSyncStream(buffer);

                [c, cmet] =   obj.analyzeDetectReturn(c_, cmet_);
                [BE, BEmet] = obj.analyzeDetectReturn(BE_, BEmet_);
                [LS, LSmet] = obj.analyzeDetectReturn(LS_, LSmet_);
                [PA, PAmet] = obj.analyzeDetectReturn(PA_, PAmet_);
                [ST, STmet] = obj.analyzeDetectReturn(ST_, STmet_);
                
                totalMetric = [cmet, BEmet, LSmet, PAmet, STmet];
                totalIndex = [c,BE,LS,PA,ST];
                [maxMetric, maxIdx] = max(totalMetric);
                idx = totalIndex(maxIdx);

                if maxMetric == -1
                    ytemp = obj.readFromBuffer([1, obj.FrameLength]);
                    type = frameType.INVALID;
                elseif maxIdx == 1
                    type = frameType.END;
                    ytemp = obj.readFromBuffer([idx-obj.FrameLength idx]);
                    obj.StartedComm = false;
                else 
                    obj.discardFromBuffer(idx-obj.SyncLength);
                    if obj.pDataBuffer.NumUnreadSamples < obj.FrameLength
                        ytemp = zeros(1, obj.FrameLength, "like", x);
                        type = frameType.INVALID;
                    else
                        type = frameType(bitshift(1, 2+maxIdx));
                        finalIdx = (obj.FrameLength-obj.SyncLength)+idx;
                        beginIdx = idx-obj.SyncLength;
                        ytemp = readFromBuffer(obj, [beginIdx, finalIdx]);
                    end
                end
            else

                [a_, amet_] = obj.detectLSF(buffer);
                [b_, bmet_] = obj.detectBERT(buffer);
                [a, amet] = obj.analyzeDetectReturn(a_, amet_);
                [b, bmet] = obj.analyzeDetectReturn(b_, bmet_);
                
                if amet > bmet
                    type = frameType.STARTLSF;
                    obj.StartedComm = true;
                    ytemp = readFromBuffer(obj,[a-obj.FrameLength, a] );
                    obj.discardFromBuffer(obj.WaitGuard);

                elseif bmet > amet
                    type = frameType.STARTLSF;
                    obj.StartedComm = true;
                    ytemp = readFromBuffer(obj,[b-obj.FrameLength, b] );
                    obj.discardFromBuffer(obj.WaitGuard);
                else
                    type = frameType.INVALID;
                    ytemp = readFromBuffer(obj, [1 obj.FrameLength]);
                end
            end

            commstarted = obj.StartedComm;
            if comm.internal.utilities.isSim()
                y = ytemp;
            else
                y = coder.nullcopy(zeros(obj.FrameLength, 1, 'like', x));
                y(:,1) = ytemp;
            end
        end

        function releaseImpl(obj)
            obj.pFirstCall = true;
        end

        function validatePropertiesImpl(obj)
            % Validate related or interdependent property values
            assert(length(obj.BERTPreamble) == length(obj.LSFPreamble))
            assert(length(obj.BERTPreamble) == length(obj.ENDPreamble))
            
            assert(length(obj.BERTSyncBurst) == length(obj.LSFSyncBurst))
            assert(length(obj.BERTSyncBurst) == length(obj.PacketSyncBurst))
            assert(length(obj.BERTSyncBurst) == length(obj.StreamSyncBurst))
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
            out2 = "frameType";
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
