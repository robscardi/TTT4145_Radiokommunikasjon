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
output_power_900 = 30 -28.1;
output_power_24 = 30 -31.5;
tran_power = 10^(maximum_output_power/10);
k = 1.38e-23;
c = 3e8;
f = 2.4*GHz;
f_900 = 928*MHz;
f_24 = 2.45*GHz;
lambda = c/f;
lambda_900 = c/f_900;
lambda_24 = c/f_24;

d = 5;
FSL = (lambda/(4*pi*d))^2;
FSL_900 = (lambda_900/(4*pi*d))^2;
FSL_24 = (lambda_24/(4*pi*d))^2;
FSL_dB = 10*log10(FSL);
FSL_dB_24 = 10*log10(FSL_24);
FSL_dB_900 = 10*log10(FSL_900);

Noise_floor = -125; %dBm/Hz
N0_lin = (10^(Noise_floor/10));
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
Eirp_900=output_power_900+G_ant_dB;
Eirp_24=output_power_24+G_ant_dB;

EIRP_lin = 10^(Eirp/10);
Model_losses = N*log10(d/d_0);
Model_losses_lin = 10^(Model_losses/10);
L_0=FSL_dB- Model_losses;
L_900 = FSL_dB_900 -Model_losses;
L_24 = FSL_dB_24 -Model_losses;

NF_rec = 3;

G_over_T = G_ant_lin/noise_temp;
G_over_T_dB = 10*log10(G_over_T);

CN_db = Eirp+L_0+G_ant_dB-N0_dB;
CN_db_900 = Eirp_900+L_900+G_ant_dB-N0_dB;
CN_db_24 = Eirp_900+L_24+G_ant_dB-N0_dB;

CN_lin = 10^(CN_db/10);

LB_EbN0=Eirp+L_0+G_ant_dB-N0_dB-R_dB-NF_rec;
LB_EbN0_24=CN_db_24-R_dB-NF_rec;
LB_EbN0_900=CN_db_900-R_dB-NF_rec;

LB_EbN0_lin = 10^(LB_EbN0/10);

EbN0_margin = LB_EbN0 -target_EbNo
EbN0_margin_24 = LB_EbN0_24 -target_EbNo
EbN0_margin_900 = LB_EbN0_900 -target_EbNo

