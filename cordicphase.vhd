library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;   
use work.Fixed_Point_Types.all;

entity cordicphase is
    port(
        i_CLOCK         : in std_logic;
        i_RESET         : in std_logic; -- Reset input
        i_RX            : in std_logic;
        o_TX            : out std_logic := '1';
        o_RX_BUSY       : out std_logic;
        o_sig_CRRP_DATA : out std_logic;
        o_TX_BUSY       : out std_logic;
        o_DATA_READY    : out std_logic;
        o_DATA          : out signed(15 downto 0)
    );
end cordicphase;

architecture behavior of cordicphase is
    -- Basic UART signals
    signal s_RX_BUSY      : std_logic;
    signal s_prev_RX_BUSY : std_logic := '0';
    signal s_rx_data      : signed(7 downto 0);
    signal s_TX_START     : std_logic := '0';
    signal s_TX_BUSY      : std_logic;
    signal r_TX_DATA      : std_logic_vector(7 downto 0);
    
    -- Data handling
    signal r_word_buffer  : signed(15 downto 0) := (others => '0');
    signal r_wave_count   : integer range 0 to 1 := 0;
    
    -- Memory
    type memory_type is array(0 to 15) of signed(15 downto 0);
    signal r_memory       : memory_type := (others => (others => '0'));
    signal r_mem_index    : integer range 0 to 15 := 0;
    signal r_mem_full     : std_logic := '0';
    signal r_pair_count   : integer range 0 to 7 := 0;

    -- Signal untuk accumulator
    signal x_values       : signed_array;
    signal y_values       : signed_array;
    signal start_accum    : std_logic := '0';
    signal s_accum_done   : std_logic;
    signal s_accum_result : signed(31 downto 0);
    signal s_load_values  : std_logic := '0';

    -- CORDIC singals
    signal cordic_start   : std_logic := '0';
    signal cordic_done    : std_logic;
    signal phase_result   : signed(31 downto 0);
    
    -- State machine
    type t_state is (IDLE, STORE_MSB, WAIT_LSB, STORE_WORD, LOAD_VALUES, WAIT_LOAD, START_ACCUMULATOR, CORDIC_PROCESS, SEND_RESULT);
    signal r_state : t_state := IDLE;
    signal r_result_bytes    : signed(31 downto 0);
    signal r_byte_count     : integer range 0 to 3 := 0;

    -- Components
    component uart1_tx is
        port(
            i_CLOCK   : in std_logic;
            i_START   : in std_logic;
            o_BUSY    : out std_logic;
            i_DATA    : in std_logic_vector(7 downto 0);
            o_TX_LINE : out std_logic := '1'
        );
    end component;
    
    component uart1_rx is
        port(
            i_CLOCK         : in std_logic;
            i_RX            : in std_logic;
            o_DATA          : out signed(7 downto 0); 
            o_sig_CRRP_DATA : out std_logic;
            o_BUSY          : out std_logic
        );
    end component;

    component fixed_point_accumulator is
        port(
            clk             : in std_logic;
            reset           : in std_logic;
            start           : in std_logic;
            x               : in signed_array;
            y               : in signed_array;
            result          : out signed(31 downto 0);
            done            : out std_logic
        );
    end component;

    component inverse_cordic is
        port(
            clk             : in std_logic;
            reset           : in std_logic;
            start           : in std_logic;
            x_input         : in signed(31 downto 0);
            phase_result    : out signed(31 downto 0);
            done_cordic     : out std_logic
        );
    end component;
    
begin
    -- Component instantiation
    u_TX : uart1_tx port map(
        i_CLOCK   => i_CLOCK,
        i_START   => s_TX_START,
        o_BUSY    => s_TX_BUSY,
        i_DATA    => r_TX_DATA,
        o_TX_LINE => o_TX
    );
    
    u_RX : uart1_rx port map(
        i_CLOCK         => i_CLOCK,
        i_RX            => i_RX,
        o_DATA          => s_rx_data,
        o_sig_CRRP_DATA => o_sig_CRRP_DATA,
        o_BUSY          => s_RX_BUSY
    );

    u_ACCUM : fixed_point_accumulator port map(
        clk     => i_CLOCK,
        reset   => i_RESET,
        start   => start_accum,
        x       => x_values,
        y       => y_values,
        result  => s_accum_result,
        done    => s_accum_done
    );

    u_CORDIC : inverse_cordic port map(
        clk             => i_CLOCK,
        reset           => i_RESET,
        start           => cordic_start,
        x_input         => s_accum_result,
        phase_result    => phase_result,
        done_cordic     => cordic_done
    );
    
    -- Main process
    process(i_CLOCK, i_RESET)
    begin
        if i_RESET = '0' then
            -- Reset all signals and state variables
            r_state <= IDLE;
            s_prev_RX_BUSY <= '0';
            s_TX_START <= '0';
            r_TX_DATA <= (others => '0');
            r_word_buffer <= (others => '0');
            r_wave_count <= 0;
            r_mem_index <= 0;
            r_mem_full <= '0';
            start_accum <= '0';
            s_load_values <= '0'; 
            r_pair_count <= 0;
            r_byte_count <= 0;
            cordic_start <= '0';

            -- Explicitly reset the memory array
            for i in 0 to r_memory'length - 1 loop
                r_memory(i) <= (others => '0');
            end loop;

        elsif rising_edge(i_CLOCK) then
            -- Synchronize busy signals
            s_prev_RX_BUSY <= s_RX_BUSY;
            s_load_values <= '0';
            
            -- Reset TX start when busy
            if s_TX_START = '1' and s_TX_BUSY = '1' then
                s_TX_START <= '0';
            end if;
            
            case r_state is
                when IDLE =>
                    -- Wait for RX to complete (falling edge of busy)
                    if s_RX_BUSY = '0' and s_prev_RX_BUSY = '1' then
                        r_word_buffer(15 downto 8) <= s_rx_data;
                        r_state <= STORE_MSB;
                    end if;
                
                when STORE_MSB =>
                    -- Wait for next byte to start
                    if s_RX_BUSY = '1' then
                        r_state <= WAIT_LSB;
                    end if;
                
                when WAIT_LSB =>
                    -- Wait for LSB reception
                    if s_RX_BUSY = '0' and s_prev_RX_BUSY = '1' then
                        r_word_buffer(7 downto 0) <= s_rx_data;
                        r_state <= STORE_WORD;
                    end if;
                
                when STORE_WORD =>
                    -- Store complete word
                    r_memory(r_mem_index) <= r_word_buffer;

                    if r_wave_count = 0 then
                        r_wave_count <= 1;
                        r_mem_index <= r_mem_index + 1;
                        r_state <= IDLE;
                    else
                        r_wave_count <= 0;
                        r_pair_count <= r_pair_count + 1;

                        if r_pair_count = 7 then
                            r_mem_full <= '1';
                            r_pair_count <= 0;
                            r_state <= LOAD_VALUES;
                        else
                            r_mem_index <= r_mem_index + 1;
                            r_state <= IDLE;
                        end if;
                    end if;
                                        
                when LOAD_VALUES =>
                    for i in 0 to 7 loop
                        x_values(i) <= r_memory(i*2);
                        y_values(i) <= r_memory(i*2 + 1);
                    end loop;
                    start_accum <= '0';
                    r_state <= WAIT_LOAD;
                
                when WAIT_LOAD =>
                    r_state <= START_ACCUMULATOR;
                    start_accum <= '1';
                
                when START_ACCUMULATOR =>
                    if s_accum_done = '1' then
                        r_byte_count <= 0;
                        start_accum <= '0'; 
                        cordic_start <= '1';
                        r_state <= CORDIC_PROCESS;
                    end if;
                
                when CORDIC_PROCESS =>
                    r_result_bytes <= phase_result;
                    if cordic_done = '1' then
                        cordic_start <= '0';
                        r_state <= SEND_RESULT;
                    end if;

                when SEND_RESULT =>
                    s_TX_START <= '1';
                    case r_byte_count is
                        when 0 => r_TX_DATA <= std_logic_vector(unsigned(r_result_bytes(31 downto 24)));
                        when 1 => r_TX_DATA <= std_logic_vector(unsigned(r_result_bytes(23 downto 16)));
                        when 2 => r_TX_DATA <= std_logic_vector(unsigned(r_result_bytes(15 downto 8)));
                        when 3 => r_TX_DATA <= std_logic_vector(unsigned(r_result_bytes(7 downto 0)));
                    end case;
                    
                    if r_byte_count < 4 then
                        r_byte_count <= r_byte_count + 1;
                    end if;                        
            end case;
        end if;
    end process;
    
    -- Output assignments
    o_RX_BUSY <= s_RX_BUSY;
    o_TX_BUSY <= s_TX_BUSY;
    o_DATA_READY <= r_mem_full;
    o_DATA <= r_word_buffer;
end behavior;
