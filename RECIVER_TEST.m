%% Pluto Init 
close all
clear variables

rx = sdrrx('Pluto', 'SamplesPerFrame',1e6,'OutputDataType','double');

%Check if its connected
plutoInfo = findPlutoRadio;
if (plutoInfo.SerialNum == 0)
    return
end

%% Reciver Config
%rx.CenterFrequency = 2.415e9;
%rx.BasebandSampleRate = 2e6;
%L =20000;
%rx.SamplesPerFrame = L;
%freq = (-L/2:L/2 -1)*(1/rx.BasebandSampleRate) + rx.CenterFrequency


%% Reciver Code

%figure;
%data = rx()
%f = fftshift(fft(complex(data)));
%plot(freq, abs(f)/length(f));

% New Data based on data transmit

rcrFilter = comm.RaisedCosineReceiveFilter('InputSamplesPerSymbol'  , 12, ...
                                           'DecimationFactor'       , 4);

data = rcrFilter(rx());

% Black Magic

VFD = dsp.VariableFractionalDelay;
cd = comm.ConstellationDiagram;

rem = 12/4;

data = data(end-rem*1000+1:end);

for index = 0:300
    tau_hat = index/50;
    delayedSig = VFD(data, tau_hat);
    o = sum(reshape(delayedSig,rem,...
     length(delayedSig)/rem).',2)./rem;
    
    cd(o);
    pause(0.1);
end