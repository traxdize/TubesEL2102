library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity inverse_cordic is
    port(
        clk             : in std_logic;
        reset           : in std_logic;
        start           : in std_logic;
        x_input         : in signed(31 downto 0);
        phase_result    : out signed(31 downto 0);
        done_cordic     : out std_logic
    );
end inverse_cordic;

architecture behavior of inverse_cordic is
    component Multiplier32Bit is
        Port ( 
            a : in signed(31 downto 0);
            b : in signed(31 downto 0);
            product : out signed(63 downto 0)
        );
    end component;

    component subtractor32bit
    port (
        A : in signed(31 downto 0);
        B : in signed(31 downto 0);
        Sum : out signed(31 downto 0)
    );
    end component;
    component shifter1bit
    port(
		input_data  : in signed(31 downto 0);
		output_data	: out signed(31 downto 0)
	);
    end component;

    type state_type is (INIT, X_SQUARE, X_FOUR, X_FINAL, CALC_Y, 
                       CORDIC_MULT1, CORDIC_SHIFT, CORDIC_ADD, DONE_STATE);
    signal state               : state_type;
    signal x_reg, y_reg, z_reg : signed(31 downto 0);
    signal iteration_count     : integer range 0 to 15;
    signal x2, x4              : signed(63 downto 0);
    signal x_squared, x_fourth : signed(31 downto 0);
    
    -- Temporary signals for CORDIC calculations
    signal xy_temp, yx_temp : signed(63 downto 0);
    signal atan_temp : signed(63 downto 0);
    signal x_shift, y_shift : signed(31 downto 0);
    signal d : integer;
    
    -- Signals for multiplier inputs
    signal mult1_a, mult1_b : signed(31 downto 0);
    signal mult2_a, mult2_b : signed(31 downto 0);
    signal mult3_a, mult3_b : signed(31 downto 0);
    signal mult4_a, mult4_b : signed(31 downto 0);
    signal mult5_a, mult5_b : signed(31 downto 0);

    -- Signals for shifter output
    signal x_squared_out : signed(31 downto 0);

    -- Signals for subtractor outputs
    signal subtract_temp_y : signed(31 downto 0);
    signal subtract_x_reg : signed(31 downto 0);
    signal subtract_z_reg : signed(31 downto 0);

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
    -- Instantiate multipliers
    mult_x2: Multiplier32Bit port map (
        a => mult1_a,
        b => mult1_b,
        product => x2
    );

    mult_x4: Multiplier32Bit port map (
        a => mult2_a,
        b => mult2_b,
        product => x4
    );

    mult_xy: Multiplier32Bit port map (
        a => mult3_a,
        b => mult3_b,
        product => xy_temp
    );

    mult_yx: Multiplier32Bit port map (
        a => mult4_a,
        b => mult4_b,
        product => yx_temp
    );

    mult_atan: Multiplier32Bit port map (
        a => mult5_a,
        b => mult5_b,
        product => atan_temp
    );

    shifter_1 : shifter1bit port map (
        input_data => x_squared,
        output_data => x_squared_out
    );

    substract_tempy : subtractor32bit port map(
        A => ONE,
        B => x_squared_out,
        Sum => subtract_temp_y
    );

    subtract_xreg : subtractor32bit port map (
        A => x_reg,
        B => x_shift,
        Sum => subtract_x_reg
    );

    subtract_yreg : subtractor32bit port map(
        A => z_reg,
        B => signed(atan_temp(31 downto 0)), 
        Sum => subtract_z_reg
    );


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
                        mult1_a <= x_input;
                        mult1_b <= x_input; -- MULTIPLIER 32 X 32 BIT
                        state <= X_SQUARE;
                        done_cordic <= '0'; 
                    end if;
                
                when X_SQUARE =>
                    x_squared <= x2(47 downto 16); -- Scale back to fixed-point -- SLICER 16 BIT, KALAU ADA YANG NIAT BIKIN, BIKIN AJA
                    mult2_a <= x_squared;
                    mult2_b <= x_squared; -- MULTIPLIER 32 X 32 BIT
                    state <= X_FOUR;

                when X_FOUR =>
                    state <= X_FINAL;
                
                when X_FINAL =>
                    x_fourth <= x4(47 downto 16); -- SLICER 32 BIT
                    state <= CALC_Y;
                
                when CALC_Y =>
                    -- Aproksimasi untuk akar (1-x**2)
                    -- temp_y <= ONE;
                    -- temp_y := temp_y - shift_right(x_squared, 1); -- 1 BIT RIGHT-SHIFTER dan 32 BIT SUBSTRACTOR
                    -- temp_y <= subtract_temp_y;
                    temp_y := subtract_temp_y - shift_right(x_fourth, 3); -- 3 BIT RIGHT-SHIFTER dan 32 BIT SUBSTRACTOR
                    
                    y_reg <= temp_y;
                    z_reg <= PI_OVER_2;
                    iteration_count <= 0;
                    
                    -- Determine initial rotation direction
                    if x_reg >= 0 then
                        d <= 1;
                    else
                        d <= -1;
                    end if;
                    state <= CORDIC_MULT1;

                when CORDIC_MULT1 =>
                    -- Perform multiplications
                    mult3_a <= y_reg;
                    mult3_b <= to_signed(d, 32); -- MULTIPLIER 32 X 32 BIT
                    mult4_a <= x_reg;
                    mult4_b <= to_signed(d, 32); -- MULTIPLIER 32 X 32 BIT
                    mult5_a <= ATAN_TABLE(iteration_count);
                    mult5_b <= to_signed(d, 32); -- MULTIPLIER 32 X 32 BIT
                    state <= CORDIC_SHIFT;

                when CORDIC_SHIFT =>
                    -- Apply shifts
                    x_shift <= shift_right(xy_temp, iteration_count)(31 downto 0); -- Ini ignore aja
                    y_shift <= shift_right(yx_temp, iteration_count)(31 downto 0);
                    state <= CORDIC_ADD;

                when CORDIC_ADD =>
                    -- Update x, y, and z registers
                    -- x_reg <= x_reg - x_shift; -- 32 BIT SUBSTRACTOR
                    x_reg <= subtract_x_reg;

                    y_reg <= y_reg + y_shift; -- 32 BIT ADDER

                    -- z_reg <= z_reg - atan_temp(31 downto 0); -- 32 BIT SUBSTRACTOR
                    z_reg <= subtract_z_reg;

                    -- Prepare for next iteration
                    if iteration_count = 15 then
                        state <= DONE_STATE;
                    else
                        iteration_count <= iteration_count + 1;
                        if (x_reg - x_shift) >= 0 then -- ini biarin aja
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
