
clearvars -except Param
close all


%Check if its connected
plutoInfo = findPlutoRadio;
if (plutoInfo.SerialNum == 0)
    return
end
Fs = 60e6; 								 % Specify the sample rate of the waveform in Hz

%% Program Code

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
    'OutputSamplesPerSymbol', 5, ...
    'FilterSpanInSymbols', 32);
waveform = rcFilter(waveform);

start_freq = 2.4e9;
stop_freq = 2.8e9;
delta_freq = stop_freq-start_freq;
k = ceil(delta_freq/Fs);
T = timer('TimerFcn',@(~,~)disp(tx.CenterFrequency),'StartDelay',5);


tx = sdrtx('Pluto', CenterFrequency=2.45e9, ...
    BasebandSampleRate=Fs, ShowAdvancedProperties=true);
tx.Gain = 0;
transmitRepeat(tx, waveform);

