close all
clearvars -except Param

R = 19;
N = 17;
a = zadoffChuSeq(19,N)
b = zadoffChuSeq(23, N)

res_a = xcorr(a,a);
res_b = xcorr(b,a);
figure
hold on
plot(abs(res_a))
plot(abs(res_b))

figure
hold on
plot(angle(res_a))
plot(angle(res_b))

message = [randomNoise(100);a; randomNoise(100)];

res_c = xcorr(a, message);
res_d = xcorr(b, message);

figure
hold on
plot(abs(res_c))
plot(abs(res_d))