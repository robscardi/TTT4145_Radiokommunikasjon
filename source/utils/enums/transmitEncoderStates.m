classdef transmitEncoderStates < Simulink.IntEnumType
    enumeration
        WAIT(0)
        LSF(1)
        PACKET(2)
        START(4)
        EOT(8)
        INITIALGARBAGE(16)
    end
end

