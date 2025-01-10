def fixed_to_float_32bit(fixed_value, integer_bits=15, fractional_bits=16):
    scale = 2**fractional_bits
    if fixed_value & (1 << 31):
        fixed_value -= (1 << 32)
    return fixed_value / scale

def fixed_to_float_16bit(fixed_value, integer_bits=7, fractional_bits=8):
    scale = 2**fractional_bits
    if fixed_value & (1 << 15):
        fixed_value -= (1 << 16)
    return fixed_value / scale

def float_to_fixed_16bit(value, integer_bits=7, fractional_bits=8):
    scale = 2**fractional_bits
    max_val = 2**(integer_bits + fractional_bits - 1) - 1
    min_val = -2**(integer_bits + fractional_bits - 1)
    fixed_value = int(value * scale)
    return format(max(min(fixed_value, max_val), min_val) & 0xFFFF, '016b')

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

result = fixed_to_float_32bit(0b00000000000000111001111001100110)

print(float_to_fixed_16bit(0.7071067811865475))
print(fixed_to_float_16bit(0b0000000010110101))
print(fixed_to_float_32bit(0b11110011001011000011011000101100))
print(float_to_fixed_32bit(0.777))


print(result/4)