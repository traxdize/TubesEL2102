library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity Multiplier16Bit is
    Port ( 
        -- Input A: 1 sign bit, 7 decimal bits, 8 fractional bits
        input_a : in STD_LOGIC_VECTOR(15 downto 0);
        -- Input B: 1 sign bit, 7 decimal bits, 8 fractional bits
        input_b : in STD_LOGIC_VECTOR(15 downto 0);
        -- Output: 1 sign bit, 14 decimal bits, 16 fractional bits
        output : out STD_LOGIC_VECTOR(30 downto 0)
    );
end Multiplier16Bit;
architecture Behavioral of Multiplier16Bit is
    -- Internal signals 
    signal sign_a, sign_b : STD_LOGIC;
    signal value_a, value_b : UNSIGNED(14 downto 0);
    signal extended_a, extended_b : UNSIGNED(15 downto 0); -- Extended untuk presisi lebih baik
    signal mult_result : UNSIGNED(31 downto 0); -- Full precision multiplication
    signal final_result : UNSIGNED(29 downto 0);
    signal final_sign : STD_LOGIC;  
begin
    -- Extract signs
    sign_a <= input_a(15);
    sign_b <= input_b(15);
    -- Extract absolute values (remove sign bit)
    value_a <= UNSIGNED(input_a(14 downto 0));
    value_b <= UNSIGNED(input_b(14 downto 0));
    -- Extend values dengan satu bit tambahan untuk presisi
    extended_a <= '0' & value_a;
    extended_b <= '0' & value_b;
    -- Multiply dengan full precision
    mult_result <= extended_a * extended_b;
    -- Adjust result untuk format output yang benar
    -- Kita mengambil bit yang tepat untuk memastikan posisi decimal point benar
    final_result <= mult_result(29 downto 0);
    -- Calculate final sign (XOR of input signs)
    final_sign <= sign_a xor sign_b;
    -- Combine sign and result
    output <= final_sign & STD_LOGIC_VECTOR(final_result);
end Behavioral;
