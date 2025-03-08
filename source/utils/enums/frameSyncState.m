classdef frameSyncState < uint8
    enumeration 
        NEUTRAL(0)
        LSF(1)
        BERT(2)
        PACKET(4)
        STREAM(8)
    end
end