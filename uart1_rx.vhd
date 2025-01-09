library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart1_rx is
    port (
        i_CLOCK          : in std_logic;
        i_RX             : in std_logic;
        o_DATA           : out std_logic_vector(7 downto 0);
        o_sig_CRRP_DATA  : out std_logic;
        o_BUSY           : out std_logic
    );
end uart1_rx;

architecture behavior of uart1_rx is
    -- Create a smaller counter for the segments
    constant c_CLKS_PER_BIT : integer := 5206;
    constant c_CLKS_PER_SEGMENT : integer := c_CLKS_PER_BIT/16;
    
    type t_rx_state is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal r_state : t_rx_state := IDLE;
    
    -- Split the counter into smaller segments
    signal r_CLOCK_COUNT : unsigned(12 downto 0) := (others => '0');  -- Explicitly sized
    signal r_BIT_INDEX : integer range 0 to 7 := 0;
    signal r_DATA_BUFFER : std_logic_vector(7 downto 0) := (others => '0');
    signal r_RX_SYNC : std_logic_vector(2 downto 0) := (others => '1');
    
    -- Add comparison constants to reduce combinational logic
    constant c_HALF_BIT : unsigned(12 downto 0) := to_unsigned(c_CLKS_PER_BIT/2, 13);
    constant c_FULL_BIT : unsigned(12 downto 0) := to_unsigned(c_CLKS_PER_BIT-1, 13);
    
begin
    process(i_CLOCK)
    begin
        if rising_edge(i_CLOCK) then
            -- Default assignment to reduce logic
            r_CLOCK_COUNT <= r_CLOCK_COUNT + 1;
            r_RX_SYNC <= r_RX_SYNC(1 downto 0) & i_RX;
            
            case r_state is
                when IDLE =>
                    o_BUSY <= '0';
                    o_sig_CRRP_DATA <= '0';
                    r_CLOCK_COUNT <= (others => '0');
                    r_BIT_INDEX <= 0;
                    
                    if (r_RX_SYNC(2) = '1' and r_RX_SYNC(1) = '0') then
                        r_state <= START_BIT;
                        o_BUSY <= '1';
                    end if;
                    
                when START_BIT =>
                    if r_CLOCK_COUNT = c_HALF_BIT then
                        if r_RX_SYNC(1) = '0' then
                            r_CLOCK_COUNT <= (others => '0');
                            r_state <= DATA_BITS;
                        else
                            r_state <= IDLE;
                        end if;
                    end if;
                    
                when DATA_BITS =>
                    if r_CLOCK_COUNT = c_FULL_BIT then
                        r_CLOCK_COUNT <= (others => '0');
                        r_DATA_BUFFER(r_BIT_INDEX) <= r_RX_SYNC(1);
                        
                        if r_BIT_INDEX = 7 then
                            r_state <= STOP_BIT;
                        else
                            r_BIT_INDEX <= r_BIT_INDEX + 1;
                        end if;
                    end if;
                    
                when STOP_BIT =>
                    if r_CLOCK_COUNT = c_FULL_BIT then
                        if r_RX_SYNC(1) = '1' then
                            o_DATA <= r_DATA_BUFFER;
                            o_sig_CRRP_DATA <= '0';
                        else
                            o_sig_CRRP_DATA <= '1';
                        end if;
                        r_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
end behavior;