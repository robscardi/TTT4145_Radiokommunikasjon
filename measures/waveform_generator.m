
%% Generating QAM waveform
% QAM configuration
M = 16; 	 % Modulation order
% input bit source:
in = randi([0, 1], 60000, 1);

% Generation
waveform = qammod(in, M, 'bin', 'InputType', 'bit', 'UnitAveragePower', true);

Fs = 60e6; 								 % Specify the sample rate of the waveform in Hz

% Filtering:
rcFilter = comm.RaisedCosineTransmitFilter('Shape', 'Normal', ...
    'RolloffFactor', 0.1, ...
    'OutputSamplesPerSymbol', 30, ...
    'FilterSpanInSymbols', 32);
waveform = rcFilter(waveform);
Fs = Fs*rcFilter.OutputSamplesPerSymbol;

%% Visualize
% Time Scope
timeScope = timescope('SampleRate', Fs, ...
    'TimeSpanOverrunAction', 'scroll', ...
    'TimeSpanSource', 'property', ...
    'TimeSpan', 4.7368e-05);
timeScope(waveform);
release(timeScope);

% Spectrum Analyzer
spectrum = spectrumAnalyzer('SampleRate', Fs);
spectrum(waveform);
release(spectrum);

% Constellation Diagram
constel = comm.ConstellationDiagram('ColorFading', true, ...
    'ShowTrajectory', 0, ...
    'SamplesPerSymbol', 30, ...
    'ShowReferenceConstellation', false);
constel(waveform);
release(constel);


