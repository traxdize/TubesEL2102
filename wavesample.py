import numpy as np
import matplotlib.pyplot as plt
import math
import serial
import time

# Parameters for the sine waves
amplitude = 1  # Peak value
frequency = 60  # Frequency in Hz
duration = 1
samples_to_store = 8
sampling_rate = frequency * samples_to_store  # Number of samples per second
phase_difference = math.radians(40)  # Phase difference in radians

# Generate time values
t = np.linspace(0, duration, sampling_rate, endpoint=False)

# Generate the sine waves
sine_wave1 = amplitude * np.sin(2 * np.pi * frequency * t)
sine_wave2 = amplitude * np.sin(2 * np.pi * frequency * t + phase_difference)

# Select samples representing an integer number of cycles
y1_samples = sine_wave1[:samples_to_store]
y2_samples = sine_wave2[:samples_to_store]

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

# Convert samples to fixed-point
y1_fixed = [float_to_fixed(v) for v in y1_samples]
y2_fixed = [float_to_fixed(v) for v in y2_samples]

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

# Main communication loop
with serial.Serial('COM7', 9600, timeout=1.0) as ser:
    # Clear any existing data
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    
    print("\nStarting transmission of all samples...")
    
    # Send all 8 pairs of samples first
    for i in range(samples_to_store):
        print(f"\nSending pair {i+1} of {samples_to_store}")
        print(f"Wave1 sample {i}: {y1_fixed[i]:016b}")
        send_16bit_value(ser, y1_fixed[i])
        
        print(f"Wave2 sample {i}: {y2_fixed[i]:016b}")
        send_16bit_value(ser, y2_fixed[i])
        
        time.sleep(0.1)  # Increased delay between pairs
    
    print("\nAll samples sent. Waiting for result...")
    time.sleep(0.5)  # Increased delay before reading result
    
    # Print number of bytes waiting
    waiting_bytes = ser.in_waiting
    print(f"Bytes waiting to be read: {waiting_bytes}")
    
    # Read the final result
    result = read_32bit_result(ser)
    if result is not None:
        print(f"\nFinal Results:")
        print(f"Raw value (hex): {result:08X}")
        print(f"Raw value (bin): {result:032b}")
        float_result = fixed_to_float_32bit(result)
        print(f"Converted to float: {float_result}")
    else:
        print("Failed to receive complete result")

print("\nTransmission complete")