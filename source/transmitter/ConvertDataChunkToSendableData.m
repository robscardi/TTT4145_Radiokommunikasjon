function ConvertDataChunkToSendableData(NOF,Data,State)

Packet = Data(d,1:200);
Packets=FormatMessageForWorkspace(NOF,200,5,Packet);
SendableData=zeros(NOF+3,384);

%Preamble
SendableData(1,:)=Preample;

%LSF
LSF_frame=[0,LSF];
Stream_mode=0;%Packet Mode
LSF_chain=sim("transmit_LSF");
SendableData(2,:)=LSF_chain.LSF;

    for d=1:NOF
    DFP=Packets(d,:);
    tx=sim("transmit_packet.slx");
    SendableData(d+2,:)=tx.Packet;
    if tx.MetaData(1,1)==1
        SendableData(d+3,:)=EoT;
        break
    end   

    end
    %Upsample Frame by Frame (192 symbols)
    %Upsampling Factor
    Ufactor=10;
    alpha = 0.5;
    SymbolSpan = 8;
    
    t=zeros(height(SendableData),1);
    
    SendableDataWithTime=[t,SendableData];
    
    DataToPluto = zeros(height(SendableDataWithTime),width(SendableData)*5);
    for d=1:height(SendableDataWithTime)
        DTP=SendableDataWithTime(d,:);
        output=sim("raised_cosine");
        DataToPluto(d,:) = output.filtered;
    end
end