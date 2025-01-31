%% Pluto Init 
close all
clear variables

rx = sdrrx('Pluto');

%Check if its connected
plutoInfo = findPlutoRadio;
if (plutoInfo.SerialNum == 0)
    return
end

%% Reciver Config
rx.CenterFrequency = 2.415e9;
rx.BasebandSampleRate = 2e6;
L =20000;
rx.SamplesPerFrame = L;
freq = (-L/2:L/2 -1)*(1/rx.BasebandSampleRate) + rx.CenterFrequency

figure;

    data = rx()
    f = fftshift(fft(complex(data)));
    plot(freq, abs(f)/length(f));
