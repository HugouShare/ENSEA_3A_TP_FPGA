#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include "altera_avalon_i2c.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"

/* ADXL345 */
#define ADXL345_ADDR       0x53
#define REG_DEVID          0x00
#define REG_POWER_CTL      0x2D
#define REG_DATAX0         0x32

/* LED */
#define LED_COUNT          10
#define LED_CENTER         4   // LED centrale (0 à 9)

/* Prototypes */
void adxl345_init(ALT_AVALON_I2C_DEV_t *i2c);
void adxl345_read_xyz(ALT_AVALON_I2C_DEV_t *i2c, int16_t *x, int16_t *y, int16_t *z);
uint16_t angle_to_leds(int16_t x);

/* ---------------- MAIN ---------------- */
int main(void)
{
    ALT_AVALON_I2C_DEV_t *i2c_dev;
    int16_t x, y, z;
    uint16_t led_value;

    printf("Initialisation I2C...\n");

    i2c_dev = alt_avalon_i2c_open("/dev/i2c_0");
    if (!i2c_dev) {
        printf("Erreur ouverture I2C\n");
        return -1;
    }

    alt_avalon_i2c_master_target_set(i2c_dev, ADXL345_ADDR);

    adxl345_init(i2c_dev);

    printf("ADXL345 prêt\n");

    while (1) {
        adxl345_read_xyz(i2c_dev, &x, &y, &z);

        led_value = angle_to_leds(x);

        IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, led_value);

        usleep(50000); // 50 ms
    }
}

/* ------------ ADXL345 INIT ------------ */
void adxl345_init(ALT_AVALON_I2C_DEV_t *i2c)
{
    uint8_t tx[2];
    uint8_t rx;

    /* Vérification DEVID */
    tx[0] = REG_DEVID;
    alt_avalon_i2c_master_tx_rx(i2c, tx, 1, &rx, 1, ALT_AVALON_I2C_NO_INTERRUPTS);

    if (rx != 0xE5) {
        printf("ADXL345 non détecté (DEVID=0x%02X)\n", rx);
    }

    /* POWER_CTL -> Measure = 1 */
    tx[0] = REG_POWER_CTL;
    tx[1] = 0x08;
    alt_avalon_i2c_master_tx(i2c, tx, 2, ALT_AVALON_I2C_NO_INTERRUPTS);
}

/* ----------- READ XYZ ----------- */
void adxl345_read_xyz(ALT_AVALON_I2C_DEV_t *i2c, int16_t *x, int16_t *y, int16_t *z)
{
    uint8_t tx = REG_DATAX0;
    uint8_t rx[6];

    alt_avalon_i2c_master_tx_rx(
        i2c,
        &tx,
        1,
        rx,
        6,
        ALT_AVALON_I2C_NO_INTERRUPTS
    );

    *x = (int16_t)((rx[1] << 8) | rx[0]);
    *y = (int16_t)((rx[3] << 8) | rx[2]);
    *z = (int16_t)((rx[5] << 8) | rx[4]);
}

/* -------- ANGLE → LED -------- */
uint16_t angle_to_leds(int16_t x)
{
    int led;
    uint16_t value = 0;

    /* x ≈ ±256 ≈ ±1g (mode ±2g) */
    if (x > 300) x = 300;
    if (x < -300) x = -300;

    led = LED_CENTER + (x * LED_CENTER) / 300;

    if (led < 0) led = 0;
    if (led >= LED_COUNT) led = LED_COUNT - 1;

    value = (1 << led);

    return value;
}

