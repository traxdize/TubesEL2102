library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity inverse_cordic is
    port(
        clk             : in std_logic;
        reset           : in std_logic;
        start           : in std_logic;
        x_input         : in signed(31 downto 0);
        y_input         : in signed(31 downto 0);
        phase_result    : out signed(31 downto 0);
        done_cordic     : out std_logic
    );
end inverse_cordic;

architecture behavior of inverse_cordic is
    type state_type is (INIT, CORDIC_INIT, CORDIC_MULT1, CORDIC_SHIFT, CORDIC_ADD, DONE_STATE);
    signal state               : state_type;
    signal x_reg, y_reg, z_reg : signed(31 downto 0);
    signal iteration_count     : integer range 0 to 15;
    
    -- Temporary signals for CORDIC calculations
    signal xy_temp, yx_temp : signed(63 downto 0);
    signal atan_temp : signed(63 downto 0);
    signal x_shift, y_shift : signed(31 downto 0);
    signal d : integer;
    
    type atan_array is array (0 to 15) of signed(31 downto 0);
    constant ATAN_TABLE : atan_array := (
        x"002D0000",  -- atan(1)
        x"001A90A3",  -- atan(1/2)
        x"000E1020",  -- atan(1/4)
        x"00072000",  -- atan(1/8)
        x"00039374",  -- atan(1/16)
        x"0001CA3D",
        x"0000E51E",
        x"000072B0",
        x"00003958",
        x"00001CAC",
        x"00000E56",
        x"0000072B",
        x"00000395",
        x"000001CA",
        x"000000C4",
        x"00000062"
    );

    constant ONE : signed(31 downto 0) := x"00010000";
    constant PI_OVER_2 : signed(31 downto 0) := x"005A0000";

begin
    process(clk, reset)
        variable temp_y: signed(31 downto 0);
    begin
        if reset = '0' then
            state <= INIT;
            x_reg <= (others => '0');
            y_reg <= (others => '0');
            z_reg <= (others => '0');
            iteration_count <= 0;
            done_cordic <= '0';
            
        elsif rising_edge(clk) then
            case state is
                when INIT =>
                    if start = '1' then
                        x_reg <= x_input;
                        y_reg <= y_input;
                        z_reg <= PI_OVER_2;
                        iteration_count <= 0;
                        done_cordic <= '0';
                        state <= CORDIC_INIT;
                    end if;
                
                when CORDIC_INIT =>
                    if x_reg >= 0 then
                        d <= 1;
                    else
                        d <= -1;
                    end if;
                    state <= CORDIC_MULT1;

                when CORDIC_MULT1 =>
                    -- Perform multiplications
                    xy_temp <= y_reg * to_signed(d, 32);
                    yx_temp <= x_reg * to_signed(d, 32);
                    atan_temp <= ATAN_TABLE(iteration_count) * to_signed(d, 32);
                    state <= CORDIC_SHIFT;

                when CORDIC_SHIFT =>
                    -- Apply shifts
                    x_shift <= shift_right(xy_temp, iteration_count)(31 downto 0);
                    y_shift <= shift_right(yx_temp, iteration_count)(31 downto 0);
                    state <= CORDIC_ADD;

                when CORDIC_ADD =>
                    -- Update x, y, and z registers
                    x_reg <= x_reg - x_shift;
                    y_reg <= y_reg + y_shift;
                    z_reg <= z_reg - atan_temp(31 downto 0);

                    -- Prepare for next iteration
                    if iteration_count = 15 then
                        state <= DONE_STATE;
                    else
                        iteration_count <= iteration_count + 1;
                        if (x_reg - x_shift) >= 0 then
                            d <= 1;
                        else
                            d <= -1;
                        end if;
                        state <= CORDIC_MULT1;
                    end if;
                    
                when DONE_STATE =>
                    phase_result <= z_reg;
                    done_cordic <= '1';
                    if reset = '0' then
                        state <= INIT;
                    end if;
            end case;
        end if;
    end process;
end behavior;