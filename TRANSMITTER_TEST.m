%% Initialize Pluto
close all
clear variables

%rx = sdrrx('Pluto', ...
%            'CenterFrequency',915e6, ...
%            'BasebandSampleRate',1e6);

tx = sdrtx('Pluto','Gain',-20);

%Check if its connected
plutoInfo = findPlutoRadio;
if (plutoInfo.SerialNum == 0)
    return
end

%% Transmitter Config

%fs = 2e6;
%tx.BasebandSampleRate = fs;
%tx.CenterFrequency = 2.415e9;
%% Waveform Code
% Creates a sine wave at 200kHz and transmits it at 2.415GHz

%sw = dsp.SineWave;
%sw.Amplitude = 0.5;
%sw.Frequency = 100e3;
%sw.ComplexOutput = true;
%sw.SampleRate = fs;
%sw.SamplesPerFrame = 5000;
%txWaveform = sw(); 

%% Add Data to Signal

% Following an example
% Create Random Data

data = randi([0 1], 2^15, 1);

% Apparently Modulate Data:

modData = comm.QPSKModulator('BitInput',true);
txData  = modData(data);

% Filters
% Will need to set the filters on specific codes

rctFilter = comm.RaisedCosineTransmitFilter('OutputSamplesPerSymbol', 12);

%Transmit Signal Over Radio
transmitRepeat(tx,rctFilter(txData));
%data = rcrFilter(rx());

%% Transmitter Code

%tx.Gain = -5;
%transmitRepeat(tx,txWaveform);