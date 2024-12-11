library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Multiplier16Bit is
    Port (
        A : in  STD_LOGIC_VECTOR(15 downto 0);
        B : in  STD_LOGIC_VECTOR(15 downto 0);
        Result : out  STD_LOGIC_VECTOR(31 downto 0)
    );
end Multiplier16Bit;

architecture Behavioral of Multiplier16Bit is
begin
    process(A, B)
    begin
        Result <= std_logic_vector(unsigned(A) * unsigned(B));
    end process;
end Behavioral;
