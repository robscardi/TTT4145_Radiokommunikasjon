clear variables
close all
GHz = 1e9;
MHz = 1e6;
kHz = 1e3;

roll_off = 0.5;
M = 4;

R = (48*kHz*24);

B = R/(log2(M))*(1+roll_off);

target_ber = 1e-9;
EbNo_vec = 0:0.01:20;
BER_awgn_qpsk= berawgn(EbNo_vec,'psk',M, 'nondiff');


y = 1;

for i=(1:length(BER_awgn_qpsk))
    if(BER_awgn_qpsk(i)> target_ber)
        y = i;
    end
end 
fit = polyfit(EbNo_vec(y-1:y), BER_awgn_qpsk(y-1:y), 1);
target_EbNo = (target_ber-fit(2))/fit(1);

figure;
plot(EbNo_vec, log10(BER_awgn_qpsk));
xline(target_EbNo)
yline(log10(target_ber))
grid on;




maximum_output_power = 7.5; % dBm
k = 1.38e-23;
c = 3e8;
f = 2.4*GHz;
lambda = c/f;
d = 10;
FSL = (lambda/(4*pi*d))^2;
FSL_dB = 10*log10(FSL);
T = 290;
N_floor = 10*log10(k*T);
Noise_floor_transm = -156; %dBm/hz
Bandwidth = 20*MHz;

NF_transm = Noise_floor_transm -174 + 10*log10(Bandwidth);
