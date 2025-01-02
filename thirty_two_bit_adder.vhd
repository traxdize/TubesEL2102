library ieee;
use ieee.std_logic_1164.all;

entity thirty_two_bit_adder is
    port (
        a, b: in std_logic_vector(31 downto 0); -- Input 32-bit vectors
        subtract: in std_logic;                 -- Subtraction control signal
        sum: out std_logic_vector(31 downto 0); -- Output sum
        overflow: out std_logic                 -- Overflow detection signal
    );
end thirty_two_bit_adder;

architecture fa_arch of thirty_two_bit_adder is
    component four_bit_adder
        port (
            a, b: in std_logic_vector(3 downto 0);
            cin: in std_logic;
            sum: out std_logic_vector(3 downto 0);
            cout: out std_logic
        );
    end component;

    signal t: std_logic_vector(7 downto 0);         -- Carry-out signals for each 4-bit adder
    signal var: std_logic_vector(31 downto 0);      -- Inverted b for subtraction
    signal s: std_logic_vector(31 downto 0);        -- Intermediate sum signals
    signal internal_overflow: std_logic;            -- Internal overflow signal
begin
    -- Handle subtraction by inverting b when `subtract` is active
    var(31 downto 0) <= not b(31 downto 0) when subtract = '1' else b(31 downto 0);

    -- Port mapping to 4-bit adders
    FA0: four_bit_adder port map (
        a => a(3 downto 0), 
        b => var(3 downto 0), 
        cin => subtract, 
        sum => s(3 downto 0), 
        cout => t(0)
    );

    FA1: four_bit_adder port map (
        a => a(7 downto 4), 
        b => var(7 downto 4), 
        cin => t(0), 
        sum => s(7 downto 4), 
        cout => t(1)
    );

    FA2: four_bit_adder port map (
        a => a(11 downto 8), 
        b => var(11 downto 8), 
        cin => t(1), 
        sum => s(11 downto 8), 
        cout => t(2)
    );

    FA3: four_bit_adder port map (
        a => a(15 downto 12), 
        b => var(15 downto 12), 
        cin => t(2), 
        sum => s(15 downto 12), 
        cout => t(3)
    );

    FA4: four_bit_adder port map (
        a => a(19 downto 16), 
        b => var(19 downto 16), 
        cin => t(3), 
        sum => s(19 downto 16), 
        cout => t(4)
    );

    FA5: four_bit_adder port map (
        a => a(23 downto 20), 
        b => var(23 downto 20), 
        cin => t(4), 
        sum => s(23 downto 20), 
        cout => t(5)
    );

    FA6: four_bit_adder port map (
        a => a(27 downto 24), 
        b => var(27 downto 24), 
        cin => t(5), 
        sum => s(27 downto 24), 
        cout => t(6)
    );

    FA7: four_bit_adder port map (
        a => a(31 downto 28), 
        b => var(31 downto 28), 
        cin => t(6), 
        sum => s(31 downto 28), 
        cout => internal_overflow
    );

    -- Overflow detection for signed addition
    overflow <= '1' when (a(31) = '0' and var(31) = '0' and s(31) = '1') or 
                         (a(31) = '1' and var(31) = '1' and s(31) = '0') 
                else '0';

    -- Assign the final sum
    sum <= s;
end fa_arch;
