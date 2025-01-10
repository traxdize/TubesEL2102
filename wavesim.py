import numpy as np
import matplotlib.pyplot as plt
import math

def float_to_fixed_32bit(value, integer_bits=15, fractional_bits=16):
    scale = 2**fractional_bits
    max_val = 2**(integer_bits + fractional_bits) - 1
    min_val = -(2**(integer_bits + fractional_bits))
    fixed_value = int(value * scale)
    if fixed_value > max_val:
        fixed_value = max_val
    elif fixed_value < min_val:
        fixed_value = min_val
    fixed_value = fixed_value & 0xFFFF_FFFF  # Keep 32 bits
    # Convert to 32-bit binary string with leading zeros
    return format(fixed_value & 0xFFFF_FFFF, '032b')

def float_to_fixed_16bit(value, integer_bits=7, fractional_bits=8):
    scale = 2**fractional_bits
    max_val = 2**(integer_bits + fractional_bits - 1) - 1
    min_val = -2**(integer_bits + fractional_bits - 1)
    fixed_value = int(value * scale)
    return format(max(min(fixed_value, max_val), min_val) & 0xFFFF, '016b')

# Parameters for the sine wave
amplitude = 1  # Peak value
frequency = 60  # Frequency in Hz
duration = 1   # Duration in seconds
samples_to_store = 8
sampling_rate = frequency*samples_to_store  # Number of samples per second
phase_difference = math.radians(76)  # Phase difference in radians (e.g., π/4 = 45 degrees)

# Generate time values
t = np.linspace(0, duration, sampling_rate, endpoint=False)

# Generate the first sine wave
sine_wave1 = amplitude * np.sin(2 * np.pi * frequency * t)

# Generate the second sine wave with a phase difference
sine_wave2 = amplitude * np.sin(2 * np.pi * frequency * t + phase_difference)

# Select the first 16 samples
y1_samples = sine_wave1[:samples_to_store]
y2_samples = sine_wave2[:samples_to_store]

print("y1_samples (First sine wave):")
for i, sample in enumerate(y1_samples, start=1):
    print(f"Sample {i}: {float_to_fixed_16bit(sample)}")

print("\ny2_samples (Second sine wave):")
for i, sample in enumerate(y2_samples, start=1):
    print(f"Sample {i}: {float_to_fixed_16bit(sample)}")

# Pair the data
paired_data = list(zip(y1_samples, y2_samples))

# Print the paired data
sum = 0
for i, (y1, y2) in enumerate(paired_data):
    multiplication = y1*y2
    sum += multiplication

print(f'Hasil pertambahan: {float_to_fixed_16bit(sum)}')

divres = (sum/samples_to_store)*2

print(float_to_fixed_32bit(divres))
result = math.acos(divres)
degree_result = math.degrees(result)

print(degree_result)