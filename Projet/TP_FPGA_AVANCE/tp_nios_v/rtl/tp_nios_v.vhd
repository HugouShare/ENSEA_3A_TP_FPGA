library ieee;
use ieee.std_logic_1164.all;

library nios;
use nios.nios;

entity tp_nios_v is
    port (
        i_clk       : in    std_logic;
        i_rst_n     : in    std_logic;

        -- I2C (ADXL345)
        io_i2c_sda  : inout std_logic;
        io_i2c_scl  : inout std_logic;

        -- LEDs
        o_led       : out   std_logic_vector(9 downto 0)
    );
end entity tp_nios_v;

architecture rtl of tp_nios_v is

    -- Signaux internes I2C (Avalon I2C IP)
    signal s_i2c_sda_in : std_logic;
    signal s_i2c_scl_in : std_logic;
    signal s_i2c_sda_oe : std_logic;
    signal s_i2c_scl_oe : std_logic;

begin

    --------------------------------------------------------------------
    -- Instance du système Nios
    --------------------------------------------------------------------
    nios0 : entity nios.nios
        port map (
            clk_clk                         => i_clk,
            reset_reset_n                   => i_rst_n,

            -- I2C
            i2c_0_i2c_serial_sda_in         => s_i2c_sda_in,
            i2c_0_i2c_serial_scl_in         => s_i2c_scl_in,
            i2c_0_i2c_serial_sda_oe         => s_i2c_sda_oe,
            i2c_0_i2c_serial_scl_oe         => s_i2c_scl_oe
        );

    --------------------------------------------------------------------
    -- I2C Open-drain
    --------------------------------------------------------------------
    s_i2c_scl_in <= io_i2c_scl;
    io_i2c_scl   <= '0' when s_i2c_scl_oe = '1' else 'Z';

    s_i2c_sda_in <= io_i2c_sda;
    io_i2c_sda   <= '0' when s_i2c_sda_oe = '1' else 'Z';

end architecture rtl;
