
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
SimParams.PlutoCenterFrequency      = 928e6;
SimParams.PlutoGain                 = 30;
SimParams.PlutoFrontEndSampleRate   = SimParams.Fs;
SimParams.PlutoFrameLength          = SimParams.Interpolation * SimParams.FrameSize;

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
%% Protocol specifications
    %% Preables
    SimParams.Preamble.LSF = repmat([+3 -3]', 96,1);
    SimParams.Preamble.BERT = repmat([-3 +3]', 96,1);

    %% Sinc Burst 
    SimParams.SyncBurst.LSF = [+3, +3, +3, +3, -3, -3, +3, -3]';
    SimParams.SyncBurst.BERT = [-3, +3, -3, -3, +3, +3, +3, +3]';
    SimParams.SyncBurst.Stream = [-3, -3, -3, -3, +3, +3, -3, +3]';
    SimParams.SyncBurst.Packet = [+3, -3, +3, +3, -3, -3, -3, -3]';
end 