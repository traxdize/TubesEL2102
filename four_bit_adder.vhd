library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity four_bit_adder is
    port (
        a, b: in std_logic_vector(3 downto 0); -- 4-bit inputs
        cin: in std_logic;                    -- Carry-in
        sum: out std_logic_vector(3 downto 0); -- 4-bit sum
        cout: out std_logic                   -- Carry-out
    );
end four_bit_adder;

architecture behavior of four_bit_adder is
    signal full_sum: unsigned(4 downto 0); -- Temporary signal to store result with carry
begin
    -- Perform addition
    full_sum <= unsigned(a) + unsigned(b) + unsigned(cin);

    -- Assign outputs
    sum <= std_logic_vector(full_sum(3 downto 0)); -- Lower 4 bits as sum
    cout <= full_sum(4); -- 5th bit as carry-out
end behavior;
