%% Initialize Pluto
%rx = sdrrx('Pluto', ...
%            'CenterFrequency',915e6, ...
%            'BasebandSampleRate',1e6);
tx = sdrtx('Pluto');
%Check if its connected
plutoInfo = findPlutoRadio;
if (plutoInfo.SerialNum == 0)
    return
end
%% Waveform Code
fs = 2e6;
sw = dsp.SineWave;
sw.Amplitude = 0.5;
sw.Frequency = 100e3;
sw.ComplexOutput = true;
sw.SampleRate = fs;
sw.SamplesPerFrame = 5000;
txWaveform = sw(); 
%% Program Code
tx.CenterFrequency = 2.400e9;
tx.BasebandSampleRate = fs;
tx.Gain = 0;
transmitRepeat(tx,txWaveform);
%% Reciver Experiment Lol