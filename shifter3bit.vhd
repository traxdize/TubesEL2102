library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Right Shifter Entity
entity shifter3bit is -- Melakukan operasi pergeseran 3 bit ke kanan pada data input.
    Port ( clk : in STD_LOGIC;                 -- Clock signal
           reset : in STD_LOGIC;               -- Reset signal
           Data_in : in STD_LOGIC_VECTOR(15 downto 0); -- Input data
           Data_out : out STD_LOGIC_VECTOR(15 downto 0)); -- Shifted output (Hasil pergeseran 3 bit)
end shifter3bit;

architecture Behavioral of shifter3bit is
    signal shifted_data : STD_LOGIC_VECTOR(15 downto 0); -- Internal shifted data
begin
    process(clk, reset) -- Proses untuk melakukan pergeseran 3 bit.
    begin
        if reset = '1' then
            shifted_data <= (others => '0'); -- Reset output menjadi 0
        elsif rising_edge(clk) then
            shifted_data <= "000" & Data_in(15 downto 3); -- Geser 3 bit ke kanan, MSB diisi 000
        end if;
    end process;

    Data_out <= shifted_data; -- Map the internal signal to the output port
end Behavioral;
