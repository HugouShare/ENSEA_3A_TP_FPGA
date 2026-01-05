library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encodeur is
    port (
        i_clk   : in  std_logic;
        i_rst_n : in  std_logic;
        i_A     : in  std_logic;
        i_B     : in  std_logic;
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

architecture rtl of encodeur is
    signal A_d, B_d : std_logic;
    signal compteur : unsigned(9 downto 0);
begin

    process(i_clk, i_rst_n)
    begin
        if i_rst_n = '0' then
            A_d <= '0';
            B_d <= '0';
            compteur <= (others => '0');

        elsif rising_edge(i_clk) then
            -- m�morisation des �tats pr�c�dents
            A_d <= i_A;
            B_d <= i_B;

            -- INCR�MENTATION
            if (i_A = '1' and A_d = '0' and i_B = '0') or
               (i_A = '0' and A_d = '1' and i_B = '1') then
                compteur <= compteur + 1;

            -- D�CR�MENTATION
            elsif (i_B = '1' and B_d = '0' and i_A = '0') or
                  (i_B = '0' and B_d = '1' and i_A = '1') then
                compteur <= compteur - 1;
            end if;
        end if;
    end process;

    o_led_0 <= compteur(0);
	 o_led_1 <= compteur(1);
	 o_led_2 <= compteur(2);
	 o_led_3 <= compteur(3);
	 o_led_4 <= compteur(4);
	 o_led_5 <= compteur(5);
	 o_led_6 <= compteur(6);
	 o_led_7 <= compteur(7);
	 o_led_8 <= compteur(8);
	 o_led_9 <= compteur(9);
	 
end architecture;