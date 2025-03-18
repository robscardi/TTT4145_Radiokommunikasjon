
Param = init();

function SimParams = init
%
%% General simulation parameters
SimParams.Rsym = 9e3;             % Symbol rate in Hertz
SimParams.ModulationOrder = 4;      % QPSK alphabet size
SimParams.SymbolBitNumber = log2(SimParams.ModulationOrder);
SimParams.Interpolation = 10;        % Interpolation factor
SimParams.Decimation = 1;           % Decimation factor
SimParams.Tsym = 1/SimParams.Rsym;  % Symbol time in sec
SimParams.Fs   = SimParams.Rsym * SimParams.Interpolation; % Sample rate

%% Frame Specifications
% [BarkerCode*2 | 'Hello world 000\n' | 'Hello world 001\n' ... | 'Hello world 099\n'];
barker = comm.BarkerCode(Length=13, SamplesPerFrame=13);
SimParams.Barker            = barker();
SimParams.FrameSize       = 192; % symbols                                    % Frame size in symbols
SimParams.FrameTime       = SimParams.Tsym*SimParams.FrameSize;
%% Rx parameters
SimParams.RolloffFactor     = 0.5;                      % Rolloff Factor of Raised Cosine Filter
SimParams.ScramblerBase     = 2;
SimParams.ScramblerPolynomial           = [1 1 1 0 1];
SimParams.ScramblerInitialConditions    = [0 0 0 0];
SimParams.RaisedCosineFilterSpan = 8;                  % Filter span of Raised Cosine Tx Rx filters (in symbols)
SimParams.DesiredPower                  = 2;            % AGC desired output power (in watts)
SimParams.AveragingLength               = 50;           % AGC averaging length
SimParams.MaxPowerGain                  = 60;           % AGC maximum output power gain
SimParams.MaximumFrequencyOffset        = 6e3;
% Look into model for details for details of PLL parameter choice. 
% Refer equation 7.30 of "Digital Communications - A Discrete-Time Approach" by Michael Rice.
K = 1;
A = 1/sqrt(2);
SimParams.PhaseRecoveryLoopBandwidth    = 0.01;         % Normalized loop bandwidth for fine frequency compensation
SimParams.PhaseRecoveryDampingFactor    = 1;            % Damping Factor for fine frequency compensation
SimParams.TimingRecoveryLoopBandwidth   = 0.01;         % Normalized loop bandwidth for timing recovery
SimParams.TimingRecoveryDampingFactor   = 1;            % Damping Factor for timing recovery
% K_p for Timing Recovery PLL, determined by 2KA^2*2.7 (for binary PAM),
% QPSK could be treated as two individual binary PAM,
% 2.7 is for raised cosine filter with roll-off factor 0.5
SimParams.TimingErrorDetectorGain       = 2.7*2*K*A^2+2.7*2*K*A^2;
SimParams.PreambleDetectionThreshold    = 0.8;


%% Pluto receiver parameters
SimParams.PlutoGain                 = 0;
SimParams.PlutoFrontEndSampleRate   = SimParams.Fs;
SimParams.PlutoFrameLength          = SimParams.Interpolation * SimParams.FrameSize;
SimParams.MaximumFrequencyOffset    = SimParams.Fs/SimParams.ModulationOrder *0.99;
%% Experiment parameters
SimParams.PlutoFrameTime = SimParams.PlutoFrameLength / SimParams.PlutoFrontEndSampleRate;
SimParams.StopTime = 10;
%% Channel Parameters
SimParams.ChannelSpacing = 12.5;
Band900 = [902 928];
Band24 = [2.4 2.5]*1e3;
SimParams.Channels = [Band900(1):SimParams.ChannelSpacing:Band900(2) ...
    Band24(1):SimParams.ChannelSpacing:Band24(2) ] ...
    + SimParams.ChannelSpacing/2;
SimParams.DutyCycle = 100;
SimParams.PlutoCenterFrequency      = SimParams.Channels(4)*1e6;
%% Protocol specifications

    %% Preambles
    SimParams.Preambles.LSF = repmat([+3 -3]', 96,1);
    SimParams.Preambles.LSFBinary = hexToArray([
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77"],1)';
    SimParams.Preambles.BERT = repmat([-3 +3]', 96,1);
    SimParams.Preambles.LSFSymbol = repmat([1+1i -1-1i 1-1i -1+1i]', 192/4,1); %mod_wrap(SimParams.Preambles.LSFBinary, "bit");
    %% Sync Burst 
    
    SimParams.SyncBurst.LSF = [+3, +3, +3, +3, -3, -3, +3, -3]';
    SimParams.SyncBurst.LSFBinary = hexToArray(["55", "F7"],1)';
    SimParams.SyncBurst.LSFSymbol = mod_wrap(SimParams.SyncBurst.LSFBinary, "bit");
    
    SimParams.SyncBurst.BERT = [-3, +3, -3, -3, +3, +3, +3, +3]';
    SimParams.SyncBurst.BERTBinary = hexToArray(["DF", "55"], 1)';
    SimParams.SyncBurst.BERTSymbol = mod_wrap(SimParams.SyncBurst.BERTBinary, "bit");
   
    SimParams.SyncBurst.Stream = [-3, -3, -3, -3, +3, +3, -3, +3]';
    SimParams.SyncBurst.StreamBinary = hexToArray(["FF", "5D"],1)';
    SimParams.SyncBurst.StreamSymbol = mod_wrap(SimParams.SyncBurst.StreamBinary, "bit");

    SimParams.SyncBurst.Packet = [+3, -3, +3, +3, -3, -3, -3, -3]';
    SimParams.SyncBurst.PacketBinary = hexToArray(["75", "FF"],1)';
    SimParams.SyncBurst.PacketSymbol = mod_wrap(SimParams.SyncBurst.PacketBinary, "bit");
    
    %% EOT
    SimParams.EOT.EoTBinary = hexToArray([
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D"],1)';
    SimParams.EOT.EoTSymbols = mod_wrap(hexToArray(["55", "5D"],1)', "bit"); 
    %% Interleaving Table
    %Interleaving Table
    InterleavingVector=zeros(367,1);
    for i=1:367
    InterleavingVector(i)=mod((45*i+92*i^2),368);
    end
    SimParams.InterleavingTable=InterleavingVector;
    %% Puncturing Vectors
    SimParams.Puncturing.P1=[1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1; ...
    1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1];

    SimParams.Puncturing.P2 = [1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 0;];

    SimParams.Puncturing.P3 = [1; 1; 1; 1; 1; 1; 1; 0;];
    %% PsedoRandom Vector
    SimParams.RandomizeHex= hexToArray([
    "D6", "B5", "E2", "30", "82", "FF", "84", "62", "BA", "4E", ...
    "96", "90", "D8", "98", "DD", "5D", "0C", "C8", "52", "43", ...
    "91", "1D", "F8", "6E", "68", "2F", "35", "DA", "14", "EA", ...
    "CD", "76", "19", "8D", "D5", "80", "D1", "33", "87", "13", ...
    "57", "18", "2D", "29", "78", "C3"],0)';
    %% Golay Generation
    
    SimParams.Golay.Matrix.P = hex2poly('0xC75');
    [H,G] = cyclgen(23, SimParams.Golay.Matrix.P);
     
    G_P = G(1:12, 1:11);
    I_K = eye(12);
    SimParams.Golay.Matrix.G = [I_K G_P SimParams.Golay.Matrix.P.'];
    SimParams.Golay.Matrix.H = [transpose([G_P SimParams.Golay.Matrix.P.']) I_K];
    
    SimParams.Golay.Matrix.StartValues=[1,41,81,121,161,201];
    SimParams.Golay.Matrix.GolayParts=[1,13,25,37];
    SimParams.Golay.Matrix.OutputParts=[1,25,49,73];
    SimParams.Golay.Matrix.EncodedOutput=zeros(1,96);

    %% Source and Destination
    SimParams.Source = hexToArray([
    "D6", "B5", "E2", "30", "82", "FF", "84", "62", "BA", "4E", ...
    "96", "90", "D8", "98", "DD"],1)';
    SimParams.Destination = hexToArray([
    "A3", "7F", "C1", "2D", "E8", "5B", "99", "4A", "F2", "6C", ...
    "D7", "3E", "81", "B4", "0F"],1)';
    %% Test Vector
    SimParams.Test = hexToArray([
    "A1", "3F", "C7", "2B", "E5", "9D", "84", "4C", "FA", "61", ...
    "D3", "7E", "B9", "05", "8F", "52", "AC", "DD", "14", "76", ...
    "29", "65", "BF", "08", "93"],1)';
end 