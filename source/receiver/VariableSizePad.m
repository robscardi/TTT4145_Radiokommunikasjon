classdef (StrictDefaults) VariableSizePad < matlab.System
    %VARIABLESIZEPAD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Nontunable)
        maxOutput = 192*3;
    end
    
    methods
        function obj = VariableSizePad(varargin)
            setProperties(obj,nargin,varargin{:})
        end
    end

    methods (Access = protected)
        function y = stepImpl(obj,u)
            % Implement algorithm. Calculate y as a function of input u and
            % internal states.
            ytemp = zeros(obj.maxOutput, 1, 'like', u);
            l = length(u);
            if ( l >= obj.maxOutput)
                ytemp(1:obj.maxOutput) = u(1:obj.maxOutput);
            else
                ytemp(1:l) = u(1:l);
            end
            
            if comm.internal.utilities.isSim()
                y = ytemp;
            else
                y = coder.nullcopy(zeros(obj.maxOutput, 1, 'like', u));
                y(:,1) = ytemp;
            end
        end

        function flag = isInputSizeMutableImpl(~,~)
            % Return false if input size cannot change
            % between calls to the System object
            flag = true;
        end

        function out = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            % Example: inherit complexity from first input port
            out = propagatedInputComplexity(obj,1);
        end

        function out = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            out = true;

            % Example: inherit fixed-size status from first input port
            % out = propagatedInputFixedSize(obj,1);
        end
        function varargout = getOutputSizeImpl(obj)
            % Return size for each output port
            %xout = propagatedInputSize(obj,1);

            % Example: inherit size from first input port
            % out = propagatedInputSize(obj,1);
            varargout = {[obj.maxOutput, 1]};
        end
        
    end
end

