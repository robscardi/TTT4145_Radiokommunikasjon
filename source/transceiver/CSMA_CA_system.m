classdef (StrictDefaults) CSMA_CA_system < matlab.System
    % untitled Add summary here
    %
    % NOTE: When renaming the class name untitled, the file name
    % and constructor name must be updated to use the class name.
    %
    % This template includes most, but not all, possible properties, attributes,
    % and methods that you can implement for a System object in Simulink.

    % Public, tunable properties
    properties
        Power_level = 3
        Probability = 0.25
    end

    % Public, non-tunable properties
    properties (Nontunable)

    end

    % Discrete state properties
    properties (DiscreteState)

    end

    % Pre-computed constants or internal states
    properties (Access = private)
        time
        buffer
        dim
    end

    methods
        % Constructor
        function obj = CSMA_CA_system(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
        end
    end

    methods (Access = protected)
        %% Common functions
        function setupImpl(obj, x)
            % Perform one-time calculations, such as computing constants
            obj.time = -1;
            obj.buffer = dsp.AsyncBuffer(15);
            obj.dim = size(x);
        end

        function y = stepImpl(obj, powerlevel, started, frame)
            % Implement algorithm. Calculate y as a function of input u and
            % internal or discrete states.
            ytemp = zeros(obj.dim);
            obj.buffer.write(frame);
            if started
                if ~any(powerlevel > obj.Power_level)
                    ytemp = obj.buffer.read(1);
                end
            end

            if comm.internal.utilities.isSim()
                y = ytemp;
            else
                y = coder.nullcopy(zeros(obj.FrameLength, 1, 'like', x));
                y(:,1) = ytemp;
            end
        end

        function resetImpl(obj)
            % Initialize / reset internal or discrete properties
            obj.buffer.reset()
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
            
            % Example: inherit size from first input port
            out = propagatedInputSize(obj,1);
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
