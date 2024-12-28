library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplier16Bit is
    Port (
        A : in  STD_LOGIC_VECTOR(15 downto 0); -- Input 1 (16 Bit)
        B : in  STD_LOGIC_VECTOR(15 downto 0); -- Input 2 (16 Bit)
        Result : out STD_LOGIC_VECTOR(30 downto 0) -- Output (31-bit)
    );
end Multiplier16Bit;
    
architecture Behavioral of Multiplier16Bit is
    -- Signals for signed conversion and multiplication
    signal signed_A : SIGNED(15 downto 0);
    signal signed_B : SIGNED(15 downto 0);
    signal signed_Product : SIGNED(30 downto 0);
begin
    -- Convert inputs to signed
    signed_A <= SIGNED(A);
    signed_B <= SIGNED(B);

    -- Perform multiplication
    signed_Product <= signed_A * signed_B;

    -- Assign result to output
    Result <= STD_LOGIC_VECTOR(signed_Product);
end Behavioral;

