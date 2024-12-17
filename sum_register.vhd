library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sum_register is
    port (
        clk    : in  std_logic;                      -- Clock input
        reset  : in  std_logic;                      -- Reset input (asynchronous)
        load   : in  std_logic;                      -- Load enable signal
        din    : in  std_logic_vector(31 downto 0);  -- Data input (from 32-bit Full Adder)
        dout   : out std_logic_vector(31 downto 0)   -- Data output
    );
end entity sum_register;

architecture behavioral of sum_register is
    signal reg : std_logic_vector(31 downto 0);  -- Internal signal to hold register value
begin
    process (clk, reset)
    begin
        if reset = '1' then
            reg <= (others => '0');  -- Reset register to 0
        elsif rising_edge(clk) then
            if load = '1' then
                reg <= din;  -- Load data into register
            end if;
        end if;
    end process;

    dout <= reg;  -- Output the register value
end architecture behavioral;
