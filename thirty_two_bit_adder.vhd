library ieee;
use ieee.std_logic_1164.all;

entity thirty_two_bit_adder is
     port (a, b: in std_logic_vector(31 downto 0);
        subtract: in std_logic;
        sum: out std_logic_vector (31 downto 0);
        overflow: out std_logic);
end thirty_two_bit_adder;

architecture fa_arch of thirty_two_bit_adder is
     component four_bit_adder
    port (a, b: in std_logic_vector(3 downto 0);
           cin : in std_logic;
           sum: out std_logic_vector (3 downto 0);
           cout: out std_logic);
     end component;

signal t: std_logic_vector (6 downto 0);
signal var: std_logic_vector (31 downto 0);
signal s: std_logic_vector(31 downto 0);
signal internal_overflow: std_logic;
begin
    var(31 downto 0) <= not b(31 downto 0) when subtract='1' else b(31 downto 0);
    
    FA0: four_bit_adder port map (
        a(3 downto 0) => a(3 downto 0), 
        b(3 downto 0) => var(3 downto 0), 
        cin => subtract, 
        sum(3 downto 0) => s(3 downto 0), 
        cout => t(0)
    );
    
    FA1: four_bit_adder port map (
        a(3 downto 0) => a(7 downto 4), 
        b(3 downto 0) => var(7 downto 4), 
        cin => t(0), 
        sum(3 downto 0) => s(7 downto 4), 
        cout => t(1)
    );
    
    FA2: four_bit_adder port map (
        a(3 downto 0) => a(11 downto 8), 
        b(3 downto 0) => var(11 downto 8), 
        cin => t(1), 
        sum(3 downto 0) => s(11 downto 8), 
        cout => t(2)
    );
    
    FA3: four_bit_adder port map (
        a(3 downto 0) => a(15 downto 12), 
        b(3 downto 0) => var(15 downto 12), 
        cin => t(2), 
        sum(3 downto 0) => s(15 downto 12), 
        cout => t(3)
    );
    
    FA4: four_bit_adder port map (
        a(3 downto 0) => a(19 downto 16), 
        b(3 downto 0) => var(19 downto 16), 
        cin => t(3), 
        sum(3 downto 0) => s(19 downto 16), 
        cout => t(4)
    );
    
    FA5: four_bit_adder port map (
        a(3 downto 0) => a(23 downto 20), 
        b(3 downto 0) => var(23 downto 20), 
        cin => t(4), 
        sum(3 downto 0) => s(23 downto 20), 
        cout => t(5)
    );
    
    FA6: four_bit_adder port map (
        a(3 downto 0) => a(27 downto 24), 
        b(3 downto 0) => var(27 downto 24), 
        cin => t(5), 
        sum(3 downto 0) => s(27 downto 24), 
        cout => t(6)
    );
    
    FA7: four_bit_adder port map (
        a(3 downto 0) => a(31 downto 28), 
        b(3 downto 0) => var(31 downto 28), 
        cin => t(6), 
        sum(3 downto 0) => s(31 downto 28), 
        cout => internal_overflow
    );
    
    -- Overflow detection logic
    overflow <= '1' when (a(31) = '0' and var(31) = '0' and s(31) = '1') or 
                         (a(31) = '1' and var(31) = '1' and s(31) = '0') 
                else '0';
    
    -- Assign sum output
    sum <= s;
end fa_arch;
