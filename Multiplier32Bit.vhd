library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplier32Bit is
    Port ( 
        a : in signed(31 downto 0);
        b   : in signed(31 downto 0);
        product     : out signed(63 downto 0)
    );
end Multiplier32Bit;

architecture Behavioral of Multiplier32Bit is
begin
    -- Perform signed multiplication
    product <= a * b;
end Behavioral;
