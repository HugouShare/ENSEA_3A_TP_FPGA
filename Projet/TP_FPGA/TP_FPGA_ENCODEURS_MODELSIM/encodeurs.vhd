library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encodeur is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        A     : in  std_logic;
        B     : in  std_logic;
        leds  : out std_logic_vector(9 downto 0)
    );
end entity;

architecture rtl of encodeur is
    signal A_d, B_d : std_logic;
    signal compteur : unsigned(9 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            A_d <= '0';
            B_d <= '0';
            compteur <= (others => '0');

        elsif rising_edge(clk) then
            -- mémorisation des états précédents
            A_d <= A;
            B_d <= B;

            -- INCRÉMENTATION
            if (A = '1' and A_d = '0' and B = '0') or
               (A = '0' and A_d = '1' and B = '1') then
                compteur <= compteur + 1;

            -- DÉCRÉMENTATION
            elsif (B = '1' and B_d = '0' and A = '0') or
                  (B = '0' and B_d = '1' and A = '1') then
                compteur <= compteur - 1;
            end if;
        end if;
    end process;

    leds <= std_logic_vector(compteur);

end architecture;

