library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_encodeur is
end entity;

architecture sim of tb_encodeur is

    -- Composant à tester
    component encodeur
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            A     : in  std_logic;
            B     : in  std_logic;
            leds  : out std_logic_vector(9 downto 0)
        );
    end component;

    -- Signaux internes
    signal clk   : std_logic := '0';
    signal reset : std_logic := '0';
    signal A     : std_logic := '0';
    signal B     : std_logic := '0';
    signal leds  : std_logic_vector(9 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    ------------------------------------------------------------------
    -- Instanciation du DUT
    ------------------------------------------------------------------
    dut : encodeur
        port map (
            clk   => clk,
            reset => reset,
            A     => A,
            B     => B,
            leds  => leds
        );

    ------------------------------------------------------------------
    -- Génération de l'horloge
    ------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    ------------------------------------------------------------------
    -- Stimuli
    ------------------------------------------------------------------
    stim_process : process
    begin
        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 50 ns;

        ----------------------------------------------------------------
        -- Rotation sens horaire (A en avance sur B) => INCRÉMENT
        -- Séquence : 00 ? 10 ? 11 ? 01 ? 00
        ----------------------------------------------------------------
        for i in 0 to 3 loop
            A <= '0'; B <= '0'; wait for 40 ns;
            A <= '1'; B <= '0'; wait for 40 ns;
            A <= '1'; B <= '1'; wait for 40 ns;
            A <= '0'; B <= '1'; wait for 40 ns;
        end loop;

        ----------------------------------------------------------------
        -- Pause
        ----------------------------------------------------------------
        A <= '0'; B <= '0';
        wait for 200 ns;

        ----------------------------------------------------------------
        -- Rotation sens anti-horaire (B en avance sur A) => DÉCRÉMENT
        -- Séquence : 00 ? 01 ? 11 ? 10 ? 00
        ----------------------------------------------------------------
        for i in 0 to 3 loop
            A <= '0'; B <= '0'; wait for 40 ns;
            A <= '0'; B <= '1'; wait for 40 ns;
            A <= '1'; B <= '1'; wait for 40 ns;
            A <= '1'; B <= '0'; wait for 40 ns;
        end loop;

        ----------------------------------------------------------------
        -- Fin de simulation
        ----------------------------------------------------------------
        wait;
    end process;

end architecture;

