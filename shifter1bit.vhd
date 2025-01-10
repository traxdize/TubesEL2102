library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Right Shifter Entity
entity Shifter1bit is -- Melakukan operasi pergeseran bit ke kanan pada data input.
    Port ( clk : in STD_LOGIC;                 -- Clock signal
           reset : in STD_LOGIC;               -- Reset signal
           Data_in : in STD_LOGIC_VECTOR(15 downto 0); -- Input data
           Data_out : out STD_LOGIC_VECTOR(15 downto 0)); -- Shifted output (Hasil pergeseran 1 bit)
end Shifter1bit;

architecture Behavioral of Shifter1bit is
    signal shifted_data : STD_LOGIC_VECTOR(15 downto 0); -- Internal shifted data
begin
    process(clk, reset) -- Proses untuk melakukan pergeseran 1 bit.
    begin
        if reset = '1' then
            shifted_data <= (others => '0'); -- Reset output menjadi 0
        elsif rising_edge(clk) then
            shifted_data <= '0' & Data_in(15 downto 1); -- Geser 1 bit ke kanan, MSB diisi 0
        end if;
    end process;

    Data_out <= shifted_data; -- Map the internal signal to the output port
end Behavioral;
