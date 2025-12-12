library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tuto_quartus is
    port (
        i_clk   : in  std_logic;                 
        i_rst_n : in  std_logic; 
		  -- 10 LEDs
        o_led_0  : out std_logic;
		  o_led_1  : out std_logic;
		  o_led_2  : out std_logic;
		  o_led_3  : out std_logic;
		  o_led_4  : out std_logic;
		  o_led_5  : out std_logic;
		  o_led_6  : out std_logic;
		  o_led_7  : out std_logic;
		  o_led_8  : out std_logic;
		  o_led_9  : out std_logic
    );
end entity;

architecture rtl of tuto_quartus is

    signal r_leds     : std_logic_vector(9 downto 0) := "0000000001";
    signal r_counter  : natural := 0;

    constant C_MAX : natural := 5000000;  
begin

    process(i_clk, i_rst_n)
    begin
        if (i_rst_n = '0') then
            r_counter <= 0;
            r_leds    <= "0000000001";         -- recommence à gauche
        elsif rising_edge(i_clk) then

            if (r_counter = C_MAX) then
                r_counter <= 0;   
                r_leds <= r_leds(0) & r_leds(9 downto 1); -- décalage circulaire

            else
                r_counter <= r_counter + 1;
            end if;

        end if;
    end process;

    o_led_0 <= r_leds(0);
	 o_led_1 <= r_leds(1);
	 o_led_2 <= r_leds(2);
	 o_led_3 <= r_leds(3);
	 o_led_4 <= r_leds(4);
	 o_led_5 <= r_leds(5);
	 o_led_6 <= r_leds(6);
	 o_led_7 <= r_leds(7);
	 o_led_8 <= r_leds(8);
	 o_led_9 <= r_leds(9);

end architecture rtl;

