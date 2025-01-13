import numpy as np
import matplotlib.pyplot as plt
import math
import serial
import time

# Fungsi-fungsi untuk konversi float ke fixed-point dan sebaliknya
def float_to_fixed(value, integer_bits=7, fractional_bits=8):
    scale = 2**fractional_bits
    max_val = 2**(integer_bits + fractional_bits - 1) - 1
    min_val = -2**(integer_bits + fractional_bits - 1)
    fixed_value = int(value * scale)
    return max(min(fixed_value, max_val), min_val) & 0xFFFF

def fixed_to_float_32bit(fixed_value, integer_bits=15, fractional_bits=16):
    scale = 2**fractional_bits
    if fixed_value & (1 << 31):
        fixed_value -= (1 << 32)
    return fixed_value / scale

# Parameter gelombang sinusoid yang disimulasikan
amplitude = 1  # Peak value
frequency = 60  # Frequency in Hz
duration = 1
samples_to_store = 8
sampling_rate = frequency * samples_to_store  # Jumlah sampel setiap detik
# phase_input = int(input('Masukkan perbedaan fasa: '))
phase_input = np.random.uniform(-90, 90) # Pemilihan perbedaan fasa acak untuk pengujian
phase_difference = math.radians(phase_input)  # Perbedaan fasa dalam 
t = np.linspace(0, duration, sampling_rate, endpoint=False)

# Pembuatan gelombang sinusoid
sine_wave1 = amplitude * np.sin(2 * np.pi * frequency * t)
sine_wave2 = amplitude * np.sin(2 * np.pi * frequency * t + phase_difference)

# Penyimpanan sample
y1_samples = sine_wave1[:samples_to_store]
y2_samples = sine_wave2[:samples_to_store]

# Setting plot
plt.figure(figsize=(15, 8), dpi=100)

t_plot = np.linspace(0, duration, 1000, endpoint=False)
sine_wave1_plot = amplitude * np.sin(2 * np.pi * frequency * t_plot)
sine_wave2_plot = amplitude * np.sin(2 * np.pi * frequency * t_plot + phase_difference)

plt.plot(t_plot, sine_wave1_plot, 'b-', label='Wave 1', linewidth=2, alpha=0.6)
plt.plot(t_plot, sine_wave2_plot, 'g-', label='Wave 2', linewidth=2, alpha=0.6)

t_samples = np.linspace(0, duration, samples_to_store, endpoint=False)
plt.plot(t_samples, y1_samples, 'ro', markersize=12, label='Samples Wave 1', markeredgecolor='black', markeredgewidth=2)
plt.plot(t_samples, y2_samples, 'yo', markersize=12, label='Samples Wave 2', markeredgecolor='black', markeredgewidth=2)

plt.grid(True, linestyle='--', alpha=0.7)

plt.xlabel('Time (s)', fontsize=12, fontweight='bold')
plt.ylabel('Amplitude', fontsize=12, fontweight='bold')
plt.title('Sine Waves with Sample Points', fontsize=14, fontweight='bold', pad=20)

plt.legend(fontsize=10, loc='upper right')

plt.axis([0, duration, -1.2, 1.2])

for i, (t, y1, y2) in enumerate(zip(t_samples, y1_samples, y2_samples)):
    plt.annotate(f'Sample {i}\n({y1:.3f})', 
                (t, y1),
                xytext=(0, 15),
                textcoords='offset points',
                ha='center',
                va='bottom',
                bbox=dict(boxstyle='round,pad=0.5', fc='white', ec='red', alpha=0.8),
                fontsize=9)
    
    plt.annotate(f'Sample {i}\n({y2:.3f})',
                (t, y2),
                xytext=(0, -15),
                textcoords='offset points',
                ha='center',
                va='top',
                bbox=dict(boxstyle='round,pad=0.5', fc='white', ec='green', alpha=0.8),
                fontsize=9)

plt.annotate(f'Phase Difference: {math.degrees(phase_difference):.1f}°',
            xy=(0.02, 0.95),
            xycoords='axes fraction',
            bbox=dict(boxstyle='round,pad=0.5', fc='white', ec='blue', alpha=0.8),
            fontsize=10)

plt.tight_layout()

plt.show()

paired_data = list(zip(y1_samples, y2_samples))

# Convert samples to fixed-point
y1_fixed = [float_to_fixed(v) for v in y1_samples]
y2_fixed = [float_to_fixed(v) for v in y2_samples]


# Fungsi untuk mengirim melalui ke FPGA melalui UART
def send_16bit_value(ser, value):
    msb = (value >> 8) & 0xFF
    lsb = value & 0xFF
    print(f"Sending MSB: {msb:08b} ({msb})")
    ser.write(bytes([msb]))
    time.sleep(0.05)  # Increased delay between bytes
    print(f"Sending LSB: {lsb:08b} ({lsb})")
    ser.write(bytes([lsb]))
    time.sleep(0.05)  # Increased delay after complete word

def read_32bit_result(ser):
    print("\nWaiting for response bytes...")
    result = 0
    bytes_received = 0
    timeout_start = time.time()
    
    while bytes_received < 4 and (time.time() - timeout_start) < 10:  # 5 second timeout
        if ser.in_waiting > 0:
            byte = ser.read(1)
            value = int.from_bytes(byte, byteorder='big')
            print(f"Received byte {bytes_received}: {value:08b} ({value})")
            result = (result << 8) | value
            bytes_received += 1
            timeout_start = time.time()  # Reset timeout for next byte
        time.sleep(0.01)  # Small delay to prevent busy waiting
    
    if bytes_received < 4:
        print(f"Timeout: Only received {bytes_received} bytes")
        return None
    return result

# Komunikasi FPGA
with serial.Serial('COM7', 9600, timeout=1.0) as ser:
    # Reset data
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    
    print("\nStarting transmission of all samples...")
    
    # Pengiriman titik sample
    for i in range(samples_to_store):
        print(f"\nSending pair {i+1} of {samples_to_store}")
        print(f"Wave1 sample {i}: {y1_fixed[i]:016b}")
        send_16bit_value(ser, y1_fixed[i])
        
        print(f"Wave2 sample {i}: {y2_fixed[i]:016b}")
        send_16bit_value(ser, y2_fixed[i])
        
        time.sleep(0.1)  # Delay
    
    print("\nAll samples sent. Waiting for result...")
    time.sleep(0.5)  # Delay sebelum pembacaan hasil
    
    # Read the final result
    result = read_32bit_result(ser)
    if result is not None:
        print(f"\nFinal Results:")
        print(f"Raw value (hex): {result:08X}")
        print(f"Raw value (bin): {result:032b}")
        float_result = fixed_to_float_32bit(result)
        print(f"Hasil akhir: {float_result}")
        print(f"Hasil yang diharapkan: {phase_input}")
    else:
        print("Failed to receive complete result")

print("\nTransmission complete")