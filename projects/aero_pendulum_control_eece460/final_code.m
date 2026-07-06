%%%SECTION 2: DYNAMIC MODEL%%%
%experimental result for motor aramture resistance
V = [0.2, 0.4, 0.6, 0.8, 0.9, 1, 1.1, 1.15, 1.2, 1.225, 1.3, 1.35, 1.4, 1.6, 1.8, 2];
I = [1.04, 1.225, 1.441, 1.654, 1.76, 1.881, 1.998, 2.073, 2.156, 2.188, 2.245, 2.306, 2.39, 2.597, 2.801, 3.036];
p = polyfit(I, V, 1);
R = p(1); %resistance is the slope of the V-I graph
I_fit = linspace(1.04, 3.036, 100);
V_fit = polyval(p, I_fit);

figure;
plot(I, V, 'o', 'MarkerFaceColor', 'b', 'DisplayName', 'Measured Data');
hold on;
plot(I_fit, V_fit, 'r-', 'LineWidth', 2, 'DisplayName', 'Linear Fit');
title('V-I Graph for Platform #1');
xlabel('Current (A)');
ylabel('Voltage (V)');
grid on;
legend('show','Location','southeast');
hold off;


%%%SECTION 3: SYSTEM ANALYSIS%%%

%freq response (bode)
freq = [0.05, 0.1, 0.2, 0.4, 0.8, 1, 1.3, 1.6, 3.2, 4.4, 6.4, 8, 10];
gain_volts = [0.254, 0.242, 0.228, 0.226, 0.204, 0.206, 0.261, 0.322, 0.464, 0.574, 0.185, 0.082, 0.043];
bias = 0.4;

gain_abs = gain_volts / bias;
gain_db = 20 * log10(gain_abs);
freq_rad = freq / (2*pi);

data = frd(gain_abs, freq); 
sys_est = tfest(data, 2, 0); % 2 poles, 0 zeros

w = logspace(-2, 1.5, 1000);
[mag, phase] = bode(sys_est, w);
mag = squeeze(mag);
mag_model = 20 * log10(mag);
freq_model = w / (2*pi);

figure;
semilogx(freq_rad, gain_db, 'o');
hold on;
semilogx(freq_model, mag_model, 'r');
grid on;

xlabel('Frequency (rad/s)');
ylabel('Gain (dB)');
title('Bode Plot: Experiment vs Model');
legend('Experimental Data', 'Identified Model');



%%%SECTION 4: CONTROLLER DESIGN %%%
%G(s) our Plant model
G_plant = tf(17.38,[1 1.873 22.25]);

%adding 1st-order Pade aproximation for 40ms delay
G_delay = tf([-0.02 1], [0.02 1]);
G_final = G_plant * G_delay;
%nyquist plot showing stability region
% nyquist(G_final)
% rlocus(G_final)
%root locus with desired pole location



%%%SECTION 5: SIMULATION RESULTS%%%

%G(s) our Plant model
G_plant = tf(17.38,[1 1.873 22.25]);

%adding 1st-order Pade aproximation for 40ms delay
G_delay = tf([-0.02 1], [0.02 1]);
G_final = G_plant * G_delay;

%-%-%-%-%-%-%-%-%-%-%

%controllers  
%P-Controller
C_p = pid(1.35);

%PID-Controller via RL
C_pid1_init = pid(0.98, 0.19, 0.24);
C_pid1_final = pid(3, 4.85, 0.57);

%PID-Controller via FR
C_pid2_init = pid(0.98, 0.19, 0.24);
C_pid2_final = pid(3, 4.85, 0.57);

%LL-Compensator via RL
s = tf('s');
% Replace with your RL Lag-Lead TF
C_ll_init  = 5.32 * ((s+3)/(s+11.58)) * ((s+0.07)/(s+0.001));
C_ll_final = 72 * ((s+4)/(s+38))^2 * ((s+6)/(s+0.05));

%LL-Compensator via FR
C_ll_FR = 72 * ((s+4)/(s+38))^2 * ((s+6)/(s+0.05));

%-%-%-%-%-%-%-%-%-%-%

%simulations (step-response)
t=0:0.1:4; step_val = 0.2;
%OL
y_OL = step(G_final * step_val, t);

%P-controller
y_P = step(feedback(C_p * G_final, 1)*step_val, t);

%PID comparision initial vs final RL
y_pid1_init = step(feedback(C_pid1_init * G_final, 1)*step_val, t);
y_pid1_final = step(feedback(C_pid1_final * G_final, 1)*step_val, t);

%PID comparision initial vs final FR
y_pid2_init = step(feedback(C_pid2_init * G_final, 1)*step_val, t);
y_pid2_final = step(feedback(C_pid2_final * G_final, 1)*step_val, t);

%LL comparision initial vs final RL
y_ll_init = step(feedback(C_ll_init * G_final, 1)*step_val, t);
y_ll_final = step(feedback(C_ll_final * G_final, 1)*step_val, t);

%LL comparision initial vs final FR
y_ll_FR = step(feedback(C_ll_FR * G_final, 1)*step_val, t);

%-%-%-%-%-%-%-%-%-%-%

%plotting step responses
reference = step_val;
OS = reference * 1.15;
ts = 1.5;
upper_limit = reference * 1.05;
lower_limit = reference * 0.95;

%OL
figure('Color','w', 'Name', 'Open Loop'); 
plot(t, y_OL, 'b', 'LineWidth', 2); grid on;
title('Open Loop Step Response'); 
yline(reference, 'k-', '');
yline(OS, 'k--', 'Max OS (15%)');
xline(ts, 'k--', 'Max Ts (1.5s)');
ylabel('Angle (rad)'); xlabel('Time (s)');

%P-Controller
figure('Color','w', 'Name', 'P-Controller'); 
plot(t, y_P, 'b', 'LineWidth', 2); grid on; hold on;
yline(reference, 'k-', '');
yline(OS, 'k--', 'Max OS (15%)');
xline(ts, 'k--', 'Max Ts (1.5s)');
title('P-Controller Step Response'); 
ylabel('Angle (rad)'); xlabel('Time (s)');

%PID via RL comaprision
figure('Color','w', 'Name', 'PID RL'); hold on;
p1 = plot(t, y_pid1_init, 'b', 'LineWidth', 2);
p2 = plot(t, y_pid1_final, 'r', 'LineWidth', 2);
yline(reference, 'k-', '');
yline(OS, 'k--', 'Max OS (15%)', 'LabelHorizontalAlignment', 'left');
xline(ts, 'k--', 'Max Ts (1.5s)', 'LabelVerticalAlignment', 'bottom');
yline(upper_limit, 'k:', '5% Band');
yline(lower_limit, 'k:', '');
title('PID Root Locus Iterations'); 
ylabel('Angle (rad)'); xlabel('Time (s)');
legend([p1 p2], 'Initial', 'Final', 'Location', 'SouthEast');
grid on; axis([0 4 0 0.25]); 

%PID via FR comparision
figure('Color','w', 'Name', 'PID Freq'); hold on;
p1 = plot(t, y_pid2_init, 'b', 'LineWidth', 2);
p2 = plot(t, y_pid2_final, 'r', 'LineWidth', 2);
yline(reference, 'k-', '');
yline(OS, 'k--', 'Max OS (15%)', 'LabelHorizontalAlignment', 'left');
xline(ts, 'k--', 'Max Ts (1.5s)', 'LabelVerticalAlignment', 'bottom');
yline(upper_limit, 'k:', '5% Band');
yline(lower_limit, 'k:', '');
title('PID Freq Response Iterations'); 
ylabel('Angle (rad)'); xlabel('Time (s)');
legend([p1 p2], 'Initial', 'Final', 'Location', 'SouthEast');
grid on; axis([0 4 0 0.25]);

%LL via RL comparision
figure('Color','w', 'Name', 'LL RL'); hold on;
p1 = plot(t, y_ll_init, 'b--', 'LineWidth', 2);
p2 = plot(t, y_ll_final, 'r-', 'LineWidth', 2);
yline(reference, 'k-', '');
yline(OS, 'k--', 'Max OS (15%)', 'LabelHorizontalAlignment', 'left');
xline(ts, 'k--', 'Max Ts (1.5s)', 'LabelVerticalAlignment', 'bottom');
yline(upper_limit, 'k:', '5% Band');
yline(lower_limit, 'k:', '');title('Lag-Lead (Root Locus) Iterations'); 
ylabel('Angle (rad)'); xlabel('Time (s)');
legend([p1 p2], 'Initial', 'Final', 'Location', 'SouthEast');
grid on; axis([0 4 0 0.25]);

% LL via FR (inital and only design)
figure('Color','w', 'Name', 'LL Freq'); hold on;
plot(t, y_ll_final, 'r', 'LineWidth', 2); 
yline(reference, 'k-', '');
yline(OS, 'k--', 'Max OS (15%)', 'LabelHorizontalAlignment', 'left');
xline(ts, 'k--', 'Max Ts (1.5s)', 'LabelVerticalAlignment', 'bottom');
yline(upper_limit, 'k:', '5% Band');
yline(lower_limit, 'k:', '');title('Lag-Lead (Freq Response) Result'); 
ylabel('Angle (rad)'); xlabel('Time (s)');
grid on; axis([0 4 0 0.25]);

%-%-%-%-%-%-%-%-%-%-%

%plotting bode plots
%final controller designs
final_pid_rl = C_pid1_final * G_final;
final_pid_fr = C_pid2_final * G_final;
final_ll = C_ll_final * G_final;

%bargins
[GM_rl, PM_rl, Wcg_rl, Wcp_rl] = margin(final_pid_rl);
[GM_fr, PM_fr, Wcg_fr, Wcp_fr] = margin(final_pid_fr);
[GM_ll, PM_ll, Wcg_ll, Wcp_ll] = margin(final_ll);

%bandwidth
BW_rl = bandwidth(feedback(final_pid_rl, 1));
BW_fr = bandwidth(feedback(final_pid_fr, 1));
BW_ll = bandwidth(feedback(final_ll, 1));

%bode of the three final designs
%PID (Root Locus Design)
figure('Color','w', 'Name', 'Bode PID-RL');
margin(final_pid_rl);
grid on;
title('Bode Diagram - PID (Root Locus Design)');

%PID (Frequency Response Design)
figure('Color','w', 'Name', 'Bode PID-FR');
margin(final_pid_fr);
grid on;
title('Bode Diagram - PID (Freq. Response Design)');

%Lag-Lead (Final)
figure('Color','w', 'Name', 'Bode Lag-Lead');
margin(final_ll);
grid on;
title('Bode Diagram - Lag-Lead Compensator');