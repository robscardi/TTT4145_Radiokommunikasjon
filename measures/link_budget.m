clear variables
close all
GHz = 1e9;
MHz = 1e6;
kHz = 1e3;

roll_off = 0.5;
M = 4;

R = (9600);
R_dB = 10*log10(R);

B = R/(log2(M))*(1+roll_off);

target_ber = 1e-6;
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
output_power_900 = 0 +30;
output_power_24 = 
tran_power = 10^(maximum_output_power/10);
k = 1.38e-23;
c = 3e8;
f = 2.4*GHz;
lambda = c/f;
d = 5;
FSL = (lambda/(4*pi*d))^2;
FSL_dB = 10*log10(FSL);
T = 290;
N_floor = 10*log10(k*T);
Noise_floor = -70; %dBm
Res = 300*kHz;
N0_lin = (10^(Noise_floor/10)/Res);
noise_temp = N0_lin/k;
noise_temp_db = 10*log10(noise_temp);

k_db = 10*log10(k);

N0_dB = 10*log10(N0_lin);
%Bandwidth = 20*MHz;

%NF_transm = Noise_floor_transm -174 + 10*log10(Bandwidth);
G_ant_dB = 2.1;
G_ant_lin = 10^(G_ant_dB/20);
N=30;
d_0=1;
R_dB=10*log10(R);

Eirp=maximum_output_power+G_ant_dB;
EIRP_lin = 10^(Eirp/10);
Model_losses = N*log10(d/d_0);
Model_losses_lin = 10^(Model_losses/10);
L_0=FSL_dB- Model_losses;
NF_rec = 3;
G_over_T = G_ant_lin/noise_temp;
G_over_T_dB = 10*log10(G_over_T);
CN_db = Eirp+L_0+G_ant_dB-N0_dB;
CN_lin = 10^(CN_db/10);
LB_EbN0=Eirp+L_0+G_ant_dB-N0_dB-R_dB-NF_rec;
LB_EbN0_lin = 10^(LB_EbN0/10);

EbN0_margin = LB_EbN0 -target_EbNo

