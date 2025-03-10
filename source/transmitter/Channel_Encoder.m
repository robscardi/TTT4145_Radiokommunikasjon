classdef (StrictDefaults) Channel_Encoder < matlab.System
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
        
        EOTPattern {mustBeFloat, mustBeFinite} = [3 -3]'
        PreamblePattern {mustBeFloat, mustBeFinite} = [3 -3]'

        LSFSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'
        BERTSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'
        StreamSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'
        PacketSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'
        FrameLength {mustBeInteger, mustBeFinite} = 192

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
        PreambleLength
        SyncLength

        detectEND

        detectSyncLSF
        detectSyncBERT
        detectSyncStream
        detectSyncPacket

        pDataBufferLength 
        pDataBuffer 
        pSyncIndexBuffer
        pBufferedFrameType
        
        Preamble
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
        function hex = hexToArray(x,y)
            hex=hexToBinaryVector(x,8);
            hex=transpose(hex);
            if y==1
                hex=double(reshape(hex,1,[]));
            else
                hex=reshape(hex,1,[]);
            end
        end
    
        function binary=decToArray(x,y,z)
            binary=decimalToBinaryVector(x,z);
            binary=transpose(binary);
            if y==1
                binary=double(reshape(binary,1,[]));
            else
                binary=reshape(binary,1,[]);
            end
        end
    
        function symbolvector=binaryToSymbol(x)
            symbolvector=zeros(1,(length(x)/2));
            j=1;
            for i=1:2:length(x)
                sym=binaryVectorToDecimal([x(i),x(i+1)]);
                switch sym
                    case 0
                        symbolvector(j)=1;
                    case 1
                        symbolvector(j)=3;
                    case 2
                        symbolvector(j)=-1;
                    case 3
                        symbolvector(j)=-3;
                end
            j=j+1;
            end
        end
    
        function Messages = FormatMessageForWorkspace(NOF,ChunkLength,...
                FrameNumberSize, InputData)
                t=zeros(NOF,1);
            
                Frame_number = zeros(NOF,FrameNumberSize);
            
                Messages=zeros(NOF,ChunkLength);
            
                for i=1:NOF
                    for j=1:ChunkLength
                    Messages(i,j)=InputData(j);
                    end
                end 
            
                if FrameNumberSize==15
                    j=1;
                    for i=1:NOF
                        if i>=2^(FrameNumberSize)-1
                            j=1;
                        elseif i==NOF
                            Frame_number(i,1:16)=decToArray(2^FrameNumberSize,0,16);
                        
                        else
                            Frame_number(i,1:16)=decToArray(j,0,16);
                        end
                        j=j+1;
                    end
                end    
            
                if FrameNumberSize==5
                    j=1;
                    for i=1:NOF
                        if i>=2^FrameNumberSize
                            j=1;
                        elseif i==NOF
                            Frame_number(i,1:6)=decToArray(57,0,6);
                            break
                        
                        else
                            Frame_number(i,1:6)=decToArray(j,0,6);
                        end
                        j=j+1;
                    end
                end
            Messages=[t,Messages,Frame_number];
        end 


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
            
            obj.SyncLength = length(obj.BERTSyncBurst);
            obj.PreambleLength = length(obj.PreamblePattern);

            %% Sync Burst detectors
            obj.EoT= comm.PreambleDetector(obj.EOTPattern,Threshold=obj.ThresholdMetric , Detections="All"); 
            obj.Preamble = comm.PreambleDetector(obj.BERTSyncBurst,Threshold=obj.ThresholdMetric , Detections="All");
            obj.LSFSB = comm.PreambleDetector(obj.LSFSyncBurst,Threshold=obj.ThresholdMetric , Detections="All");
            obj.StreamSB = comm.PreambleDetector(obj.PacketSyncBurst,Threshold=obj.ThresholdMetric , Detections="All");
            obj.PacketSB = comm.PreambleDetector(obj.StreamSyncBurst,Threshold=obj.ThresholdMetric , Detections="All");
            
            %%
            obj.pDataBufferLength  = obj.pSyncIdxBufferLength*(obj.FrameLength);
            obj.pDataBuffer        = dsp.AsyncBuffer(obj.pDataBufferLength);
            obj.pSyncIndexBuffer   = -1; %dsp.AsyncBuffer(obj.pSyncIdxBufferLength);
            obj.pBufferedFrameType = frameType.INVALID;
            obj.pFirstCall         = false;

            setup(obj.pDataBuffer, cast(1,'like',x));
            obj.commStarted = false;
            obj.currentState = frameSyncState.NEUTRAL;

            obj.Preamble = repmat(obj.PreamblePattern, floor(obj.FrameLength/obj.PreambleLength),1);
        end

        function resetImpl(obj)
            % Initialize internal buffer and related properties
            obj.pDataBuffer.reset();
            obj.commStarted = false;
            obj.currentState = frameSyncState.NEUTRAL;
        end
        
        function [y,type] = stepImpl(obj,x)
            % Implement algorithm. Calculate y as a function of input u and
            % internal or discrete states.
            if obj.pSyncIndexBuffer > 0
                if obj.pDataBuffer.NumUnreadSamples >= obj.FrameLength
                    ytemp = obj.pDataBuffer.read(obj.FrameLength);
                    obj.pSyncIndexBuffer = -1;
                    type = obj.pBufferedFrameType;
                else
                    ytemp = obj.peekFromBuffer(obj.FrameLength);
                    type = frameType.INVALID;
                end
            else
                ytemp = obj.peekFromBuffer(obj.FrameLength);
                type = frameType.INVALID;
            end

            if comm.internal.utilities.isSim()
                y = ytemp;
            else
                y = coder.nullcopy(zeros(obj.FrameLength, 1, 'like', x));
                y(:,1) = ytemp;
            end
            
            obj.pDataBuffer.write(x(:));
            buffer = obj.pDataBuffer.peek(obj.pDataBufferLength);

            if obj.commStarted && obj.pSyncIndexBuffer < 0
                [c_, cmet_] =   obj.detectEND(buffer);
                [~, cmet] =   obj.analyzeDetectReturn(c_, cmet_);
                
                if cmet > -1 
                    y = obj.peekFromBuffer(obj.FrameLength);
                    type = frameType.INVALID;
                    obj.StartedComm = false;
                    obj.currentState = frameSyncState.NEUTRAL;
                else
                    switch obj.currentState
                        case frameSyncState.STREAM
                            t = obj.detectSync(obj.detectSyncStream, buffer);
                            if t
                                obj.pBufferedFrameType = frameType.STREAM;
                                obj.allignSync(obj.pSyncIndexBuffer)
                            end
                            
                        case frameSyncState.PACKET
                            t = obj.detectSync(obj.detectSyncPacket, buffer);
                            if t
                                obj.pBufferedFrameType = frameType.PACKET;
                                obj.allignSync(obj.pSyncIndexBuffer)
                            end
                            
                        case frameSyncState.BERT %UNUSED
                            t = obj.detectSync(obj.detectSyncBERT, buffer);
                            if t
                                obj.pBufferedFrameType = frameType.BERT;
                                obj.allignSync(obj.pSyncIndexBuffer)
                            end
                        case frameSyncState.LSF
                            t = obj.detectSync(obj.detectSyncLSF, buffer);
                            if t
                                obj.pBufferedFrameType = frameType.LSF;
                                obj.currentState = frameSyncState.STREAM;
                                obj.allignSync(obj.pSyncIndexBuffer)
                            end
                    end
                end
            elseif ~obj.commStarted
                metric = xcorr(buffer, obj.Preamble);
                [value, idx] = max(abs(metric(1:obj.pDataBufferLength)));
                %idx = idx - obj.FrameLength;
                if value > 200 && idx > obj.FrameLength-1
                    obj.discardFromBuffer(idx);
                    obj.commStarted = true;
                    obj.currentState = frameSyncState.LSF;
                end
            end

        end

        function releaseImpl(obj)
            obj.pFirstCall = true;
        end

        function validatePropertiesImpl(obj)
            % Validate related or interdependent property values            
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

        function [out,out2] = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            out = propagatedInputDataType(obj,1);
            out2 = "frameType";
        end

        

        function [out,out2] = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            out = true;
            out2 = false;

            % Example: inherit complexity from first input port
            % out = propagatedInputComplexity(obj,1);
        end

        function [out,out2] = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            out = true;
            out2 = true;

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
