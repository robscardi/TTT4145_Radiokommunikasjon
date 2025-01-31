%% Pluto Init

rx = sdrrx('Pluto');

%Check if its connected
plutoInfo = findPlutoRadio;
if (plutoInfo.SerialNum == 0)
    return
end

%% Reciver Config
rx.CenterFrequency = 2.415e9;
rx.BasebandSampleRate = 2e6;

figure;

for i = 0:1:100
    data = rx()
    plot(real(data));
end