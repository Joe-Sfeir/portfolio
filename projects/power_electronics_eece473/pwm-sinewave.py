import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, filtfilt

# Parameters
Vd = 1              # DC bus voltage, use 1 for normalized voltage
f_sine = 50         # desired sine frequency, Hz
f_sw = 1000         # switching/carrier frequency, Hz
ma = 0.8            # modulation index, must be <= 1 for linear SPWM

T = 2 / f_sine      # simulate 2 sine cycles
fs_sample = 200000  # simulation sampling frequency
t = np.arange(0, T, 1/fs_sample)

# Sine control/reference signal
v_cont = ma * np.sin(2 * np.pi * f_sine * t)

# Triangular carrier from -1 to +1
carrier = 2 * np.abs(2 * ((t * f_sw) % 1) - 1) - 1

# Bipolar PWM: output is +Vd when sine > triangle, otherwise -Vd
v_pwm = np.where(v_cont > carrier, Vd, -Vd)

# Low-pass filter to extract the sine-like fundamental
cutoff = 200  # Hz, above 50 Hz but below switching frequency
b, a = butter(4, cutoff / (fs_sample / 2), btype='low')
v_filtered = filtfilt(b, a, v_pwm)

# Plot reference and carrier
plt.figure(figsize=(12, 4))
plt.plot(t, v_cont, label="Sine reference $v_{cont}$")
plt.plot(t, carrier, label="Triangular carrier $v_{tri}$", alpha=0.7)
plt.xlim(0, 0.04)
plt.grid(True)
plt.legend()
plt.title("Sine reference compared with triangular carrier")
plt.xlabel("Time (s)")
plt.ylabel("Voltage")
plt.show()

# Plot PWM output
plt.figure(figsize=(12, 4))
plt.plot(t, v_pwm, label="PWM output $v_o$")
plt.xlim(0, 0.04)
plt.grid(True)
plt.legend()
plt.title("PWM output voltage")
plt.xlabel("Time (s)")
plt.ylabel("Voltage")
plt.show()

# Plot PWM with filtered sine
plt.figure(figsize=(12, 4))
plt.plot(t, v_pwm, label="PWM output", alpha=0.4)
plt.plot(t, v_filtered, label="Filtered PWM / fundamental", linewidth=2)
plt.plot(t, ma*np.sin(2*np.pi*f_sine*t), "--", label="Original sine reference")
plt.xlim(0, 0.04)
plt.grid(True)
plt.legend()
plt.title("PWM becomes sine-like after filtering")
plt.xlabel("Time (s)")
plt.ylabel("Voltage")
plt.show()