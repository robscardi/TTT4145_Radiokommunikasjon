close all
clearvars -except Param

a = repmat(FSKtoQPSK([3 -3]'), 192/2, 1);
b = pskmod(randi([0 1],192*2, 1), 4, pi/4, "gray", "InputType","bit");
c = zeros(192, 1);
d = repmat(FSKtoQPSK([-3 3]'), 192/2, 1);
e = repmat(FSKtoQPSK([-1 1]'), 192/2, 1);

after_channel_a = awgn(a, 0);
after_channel_a = after_channel_a*0.1;

after_channel_b = awgn(b, 0);
after_channel_b = after_channel_b*0.1;

after_channel_c = awgn(c, 0);
after_channel_c = after_channel_c*0.1;

gain_control = comm.AGC("DesiredOutputPower",1);

after_channel_a = gain_control(after_channel_a);
after_channel_b = gain_control(after_channel_b);
after_channel_c = gain_control(after_channel_c);

res_a = xcorr(a, after_channel_a);
res_b = xcorr(a, after_channel_b);
res_c = xcorr(a, after_channel_c);
res_d = xcorr(a, d);
res_e = xcorr(a, e);


figure
plot(abs(res_a));
hold on
plot(abs(res_b));
plot(abs(res_c));
plot(abs(res_d));
plot(abs(res_e));

[valuea, indexa] = max(abs(res_a));
[valueb, indexb] = max(abs(res_b));
[valuec, indexc] = max(abs(res_c));

%% Sync Burst
a = xcorr((Param.SyncBurst.LSFSymbol), (Param.SyncBurst.LSFSymbol));
b = xcorr((Param.SyncBurst.LSFSymbol), (Param.SyncBurst.StreamSymbol));
c = xcorr((Param.SyncBurst.LSFSymbol), (Param.SyncBurst.BERTSymbol));
d = xcorr(Param.SyncBurst.StreamSymbol, Param.SyncBurst.BERTSymbol);

figure
hold on
plot(abs(a))
plot(abs(b))
plot(abs(c))
plot(abs(b))
legend


