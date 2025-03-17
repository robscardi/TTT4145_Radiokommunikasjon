classdef (StrictDefaults) WaitGuard < matlab.System

    % Public, tunable properties

    properties(Nontunable)
        FrameLength = 192
    end

    % Pre-computed constants or internal states
    properties (Access = private, Nontunable)
        zero
        size
    end

    methods
        % Constructor
        function obj = WaitGuard(varargin)
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

        function setupImpl(obj, DutyCycle)
            % Perform one-time calculations, such as computing constants
            obj.zero = zeros(obj.FrameLength, 1);
            obj.size = (1-DutyCycle/100)*2*obj.FrameLength;
        end
        
        function [y] = stepImpl(obj, DutyCycle)
            
            ytemp = obj.zero(1:obj.size);
            if comm.internal.utilities.isSim()
                y = ytemp;
            else
                y = coder.nullcopy(zeros(obj.FrameLength, 1, 'double'));
                y(:,1) = ytemp;
            end
            
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
            %xout = propagatedInputSize(obj,1);

            % Example: inherit size from first input port
            % out = propagatedInputSize(obj,1);
            varargout = {[obj.size 1]};
        end

        function [out] = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            out = 'double';
        end

        

        function [out] = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            out = true;
        end

        function [out] = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            out = true;
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
