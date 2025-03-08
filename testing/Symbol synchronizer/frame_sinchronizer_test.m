close all
clearvars -except Param

frameSynchronizer = FramePreambleDetector( ...
    PreamblePattern = Param.Preamble,...
    LSFSyncBurst = Param.SyncBurst.LSF, ...
    BERTSyncBurst = Param.SyncBurst.BERT, ...
    StreamSyncBurst = Param.SyncBurst.Stream, ...
    PacketSyncBurst = Param.SyncBurst.Packet, ...
    ThresholdMetric = 15);

message = [Param.SyncBurst.Stream; mod_wrap(randi([0 1],184*2,1), "bit")];
noise = mod_wrap(randi([0 1],192*2,1), "bit");
header = repmat(Param.Preamble, 192/2,1);
LSF_mess = [Param.SyncBurst.LSF; mod_wrap(randi([0 1],184*2,1), "bit")];
whole_message = [noise; header; noise; LSF_mess; noise; message; noise; message; noise; noise ];
n_message = 0;
n_iter = floor(length(whole_message)/192);

j = 1; k = 192;
for i=1:n_iter
    [res, type] = frameSynchronizer(whole_message(j:k));
    if type == frameType.STREAM
        assert(all(message == res))
        n_message = n_message +1;
    end
    j = j +192;
    k = k +192;
end
assert(n_message == 2)