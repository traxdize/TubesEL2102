-- Subtractor 32 bit
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity subtractor32bit is
    port (
        A : in std_logic_vector(31 downto 0);
        B : in std_logic_vector(31 downto 0);
        Sum : out std_logic_vector(31 downto 0)
    );
end entity subtractor32bit;

architecture behavioral of subtractor32bit is
    signal Sum_temp, A_temp, B_temp : unsigned(31 downto 0);
begin
    A_temp <= unsigned(A);
    B_temp <= unsigned(B);
    Sum_temp <= A_temp - B_temp;
    Sum <= std_logic_vector(Sum_temp);
end architecture behavioral;