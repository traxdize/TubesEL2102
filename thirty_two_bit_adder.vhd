library ieee;
use ieee.std_logic_1164.all;

--define entity
entity thirty_two_bit_adder is --entity name
     port (a, b: in std_logic_vector(31 downto 0); --input ports
        subtract: in std_logic; --input port
        sum: out std_logic_vector (31 downto 0); --output port
        overflow: out std_logic); --output port
end thirty_two_bit_adder; --end entity

--define architecture
architecture fa_arch of thirty_two_bit_adder is --architecture name
     component four_bit_adder --component name
    port (a, b: in std_logic_vector(3 downto 0); --input ports
           cin : in std_logic; --input port
           sum: out std_logic_vector (3 downto 0); --output port
           cout: out std_logic); --output port
     end component; --end component

signal t: std_logic_vector (6 downto 0); --signal declaration
signal var: std_logic_vector (31 downto 0); --signal declaration
signal s: std_logic_vector(31 downto 0); --signal declaration
begin --begin architecture
--LHS: 4-bit compnent ports => RHS: 32-bit entity ports
    var(31 downto 0)<= not b(31 downto 0) when subtract='1' else b(31 downto 0);
    FA0: four_bit_adder port map (a(3 downto 0) => a(3 downto 0), b(3 downto 0) => var(3 downto 0), cin => subtract, sum(3 downto 0) => s(3 downto 0), cout => t(0)); --port map
    FA1: four_bit_adder port map (a(3 downto 0) => a(7 downto 4), b(3 downto 0) => var(7 downto 4), cin => t(0), sum(3 downto 0) => s(7 downto 4), cout => t(1)); --port map
    FA2: four_bit_adder port map (a(3 downto 0) => a(11 downto 8), b(3 downto 0) => var(11 downto 8), cin => t(1), sum(3 downto 0) => s(11 downto 8), cout => t(2)); --port map
    FA3: four_bit_adder port map (a(3 downto 0) => a(15 downto 12), b(3 downto 0) => var(15 downto 12), cin => t(2), sum(3 downto 0) => s(15 downto 12), cout => t(3)); --port map
    FA4: four_bit_adder port map (a(3 downto 0) => a(19 downto 16), b(3 downto 0) => var(19 downto 16), cin => t(3), sum(3 downto 0) => s(19 downto 16), cout => t(4)); --port map
    FA5: four_bit_adder port map (a(3 downto 0) => a(23 downto 20), b(3 downto 0) => var(23 downto 20), cin => t(4), sum(3 downto 0) => s(23 downto 20), cout => t(5)); --port map
    FA6: four_bit_adder port map (a(3 downto 0) => a(27 downto 24), b(3 downto 0) => var(27 downto 24), cin => t(5), sum(3 downto 0) => s(27 downto 24), cout => t(6)); --port map
    FA7: four_bit_adder port map (a(3 downto 0) => a(31 downto 28), b(3 downto 0) => var(31 downto 28), cin => t(6), sum(3 downto 0) => s(31 downto 28), cout => overflow); --port map
    overflow <= '1' when a(31)/=a(30) and b(31)/=b(30) else '0'; --overflow condition
            '0'; --overflow condition
end fa_arch; --end architecture
