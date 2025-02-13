gi%% Initialize Pluto
%rx = sdrrx('Pluto', ...
%            'CenterFrequency',915e6, ...
%            'BasebandSampleRate',1e6);
clearvars -except Param
close all

tx = sdrtx('Pluto');
%Check if its connected
plutoInfo = findPlutoRadio;
%if (plutoInfo.SerialNum == 0)
    %return
%end
Fs = 60e6; 								 % Specify the sample rate of the waveform in Hz

%% Program Code
tx.CenterFrequency = 2.400e9;
tx.BasebandSampleRate = 19e6;
tx.Gain = -10;
tx.BasebandSampleRate = Fs
%%
% QAM configuration
M = 16; 	 % Modulation order
% input bit source:
in = randi([0, 1], 600000, 1);

% Generation
waveform = qammod(in, M, 'bin', 'InputType', 'bit', 'UnitAveragePower', true);

% Filtering:
rcFilter = comm.RaisedCosineTransmitFilter('Shape', 'Normal', ...
    'RolloffFactor', 0.1, ...
    'OutputSamplesPerSymbol', 30, ...
    'FilterSpanInSymbols', 32);
waveform = rcFilter(waveform);

start_freq = 2.4e9;
stop_freq = 2.8e9;
delta_freq = stop_freq-start_freq;
k = ceil(delta_freq/Fs);
T = timer('TimerFcn',@(~,~)disp(tx.CenterFrequency),'StartDelay',1e-3);

for i = 0:k
    tx.CenterFrequency = start_freq+(Fs*i);
    transmitRepeat(tx, waveform);
    start(T)
    wait(T)
end
