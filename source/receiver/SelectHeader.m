classdef (StrictDefaults) SelectHeader < matlab.System
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
        
        LSFSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'
        BERTSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'
        StreamSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'
        PacketSyncBurst {mustBeFloat, mustBeFinite} = [3 -3]'

    end


    methods
        % Constructor
        function obj = SelectHeader(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
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


        function setupImpl(obj)
        end

        function resetImpl(obj)
            % Initialize internal buffer and related properties
        end
        
        function [y] = stepImpl(obj,x)
            % Implement algorithm. Calculate y as a function of input u and
            % internal or discrete states.
            ytemp = zeros(size(obj.LSFSyncBurst));
            switch x
                case frameType.LSF
                    ytemp = obj.LSFSyncBurst(:);
                case frameType.PACKET
                    ytemp = obj.PacketSyncBurst(:);
                case frameType.BERT
                    ytemp = obj.BERTSyncBurst(:);
                case frameType.STREAM
                    ytemp = obj.StreamSyncBurst(:);
            end
            if comm.internal.utilities.isSim()
                y = ytemp;
            else
                y = coder.nullcopy(zeros(8,1, 'like', obj.LSFSyncBurst));
                y(:,1) = ytemp;
            end

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
            ds = struct([]);
        end

        function varargout = getOutputSizeImpl(obj)
            % Return size for each output port
            varargout = {size(obj.LSFSyncBurst)};
        end

        function [out] = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            out ="double";
        end

    
        function [out] = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
           
            % Example: inherit complexity from first input port
            out = true;
        end

        function [out] = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            
            % Example: inherit fixed-size status from first input port
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
