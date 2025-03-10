classdef testFrameSynchronizer < matlab.unittest.TestCase
    
    properties
        DUT
        Preamble
        SyncBurstLSF
        SyncBurstBERT
        SyncBurstStream
        SyncBurstPacket
    end

    methods(TestClassSetup)
        % Shared setup for the entire test class
        function setupDUT(testCase)
            testCase.Preamble = FSKtoQPSK([+3 -3]');
            testCase.SyncBurstLSF = FSKtoQPSK([+3, +3, +3, +3, -3, -3, +3, -3]');
            testCase.SyncBurstBERT = FSKtoQPSK([-3, +3, -3, -3, +3, +3, +3, +3]');
            testCase.SyncBurstPacket = FSKtoQPSK([+3, -3, +3, +3, -3, -3, -3, -3]');
            testCase.SyncBurstStream = FSKtoQPSK([-3, -3, -3, -3, +3, +3, -3, +3]');

            testCase.DUT = FramePreambleDetector( ...
                PreamblePattern = testCase.Preamble,...
                LSFSyncBurst = testCase.SyncBurstLSF, ...
                BERTSyncBurst = testCase.SyncBurstBERT, ...
                StreamSyncBurst = testCase.SyncBurstStream, ...
                PacketSyncBurst = testCase.SyncBurstPacket, ...
                ThresholdMetric = 10);
            
        end
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    methods(Test)
        % Test methods
        
        function Test1(testCase)
            message = [testCase.SyncBurstPacket; mod_wrap(randi([0 1],184*2,1), "bit")];
            noise = randomNoise(1000);
            header = repmat(testCase.Preamble, 192/2,1);
            LSF_mess = [testCase.SyncBurstLSF; mod_wrap(randi([0 1],184*2,1), "bit")];
            whole_message = [noise; header; noise; LSF_mess; noise; message; noise; message; noise; noise ];
            n_message = 0;
            n_iter = floor(length(whole_message)/192);
            
            whole_message = awgn(whole_message, 20);

            j = 1; k = 192;
            for i=1:n_iter
                [res, type] = testCase.DUT(whole_message(j:k));
                if type == frameType.PACKET
                    a = xcorr(res, message);
                    max(abs(a))
                    n_message = n_message +1;
                end
                j = j +192;
                k = k +192;
            end
            assert(n_message == 2)
        end
    end
    
end