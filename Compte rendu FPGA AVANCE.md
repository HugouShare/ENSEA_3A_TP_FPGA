# Compte rendu : TP FPGA AVANCE  

Lien vers sujet FPGA AVANCE : [sujet TP FPGA AVANCE](https://github.com/lfiack/ENSEA_2A_FPGA_Public/blob/main/majeure/3-tp/fpga_adv_tp.md)  

## 📑 Sommaire

<details>
<summary><b>📌 Cliquer pour afficher le sommaire</b></summary>

<br>

- [📖 Introduction](#introduction)

- [🧠 Tutoriel Nios V](#tutoriel-nios-v)
  - [📂 Organisation](#organisation)
  - [🛠️ Création du projet](#création-du-projet)
  - [🧩 Création du SOPC](#création-du-sopc)
  - [🔁 De retour dans Quartus](#de-retour-dans-quartus)
  - [💻 Création du projet soft](#création-du-projet-soft)
  - [👋 Hello, world!](#hello-world)
  - [💡 L'inévitable chenillard](#linévitable-chenillard)

- [🚀 Petit projet](#petit-projet)
  - [🧭 Le niveau à bulles](#le-niveau-à-bulles)

- [🏁 Conclusion](#conclusion)

</details>  

## Introduction  

Durant ces séances de travaux pratiques, nous allons concevoir un SOPC (System On a Programmable Chip).  
Notre système comportera les différents blocs de composants suivants :  
<img width="344" height="347" alt="image" src="https://github.com/user-attachments/assets/41b0f7eb-3913-46e6-9715-fca536032a1f" />  

## Tutoriel Nios V  

### Organisation  

Un projet soft-processeur pouvant rapidement devenir complexe, il est nécessaire de bien organiser son projet.  
Ainsi, nous adoptons l'organisation suivante : 
- Un dossier principal nommé tp_nios_v contenant notre projet et composé des sous-dossiers suivants :
	- rtl : contiens les codes VHDL et Verilog
	- synt : le projet Quartus pour la synthèse
	- sim : les fichiers de simulation Modelsim
	- sopc : la configuration du soft-processeur
	- soft : le code C exécuté par le soft-processeur  

### Création du projet  

1. Dans le dossier ```synt```, nous créeons deux fichiers :
    * ```tp_nios_v.qpf```
    * ```tp_nios_v.qsf```

2. Dans le fichier ```tp_nios_v.qpf```, nous ajoutons les deux lignes suivantes :
```tcl
QUARTUS_VERSION = "24.1"
PROJECT_REVISION = "tp_nios_v"
```

3. Dans le fichier ```tp_nios_v.qsf```, nous ajoutons les lignes suivantes :

```tcl
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEBA6U23I7
set_global_assignment -name TOP_LEVEL_ENTITY "tp_nios_v"
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

set_global_assignment -name VHDL_FILE ../rtl/tp_nios_v.vhd
```

4. Dans le dossier ```rtl```, nous créeons le fichier ```tp_nios_v.vhd```

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity tp_nios_v is
    port (
        i_clk : in std_logic;
        i_rst_n : in std_logic;

        o_led : out std_logic_vector(9 downto 0)
    );
end entity tp_nios_v;

architecture rtl of tp_nios_v is
    
begin
    
end architecture rtl;
```

5. Enfin, nous ajoutons les contraintes directement dans le fichier ```tp_nios_v.qsf``` :

```tcl
set_location_assignment PIN_V11 -to i_clk
set_location_assignment PIN_AH17 -to i_rst_n
set_location_assignment PIN_AG28 -to o_led[0]
set_location_assignment PIN_AE25 -to o_led[1]
set_location_assignment PIN_AG26 -to o_led[2]
set_location_assignment PIN_AG25 -to o_led[3]
set_location_assignment PIN_AG23 -to o_led[4]
set_location_assignment PIN_AH21 -to o_led[5]
set_location_assignment PIN_AF22 -to o_led[6]
set_location_assignment PIN_AG20 -to o_led[7]
set_location_assignment PIN_AG18 -to o_led[8]
set_location_assignment PIN_AG15 -to o_led[9]

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to i_clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to i_rst_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to o_led[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to o_led[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to o_led[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to o_led[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to o_led[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to o_led[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to o_led[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to o_led[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to o_led[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to o_led[9]
```

6. Puis nous ouvrons le projet (```tp_nios_v.qpf```) dans Quartus.

### Création du SOPC  

1. Nous lançons maintenant ```Platform Designer```

> Tools > Platform Designer

Cet outil va nous permettre de construire notre propre micro-contrôleur ! 😁

2. Sur Platform Designer, nous créeons alors notre propre système composé : d'un soft-processeur NIOS V, d'une mémoire ROM, du JTAG UART et de GPIOS.  

Une fois tous les composants ajoutés et les différents signaux connectés entre eux, nous obtenons alors la structure globale suivante :  
<img width="1064" height="661" alt="image" src="https://github.com/user-attachments/assets/96b83f9c-8d9e-402b-89ee-39df9c965fd4" />  

3. Ensuite, nous générons les adresses.  

> System > Assign Base Addresses

4. Puis, nous configurons le vecteur de reset :

> Nous double-cliquons sur le processeur ```intel_niosv_m_0```
> Dans la section ```Traps, Exceptions and Interrupts```, nous configurons ```Reset Agent``` sur ```on_chip_memory2_0.s1```

5. Et nous sauvegardons.

6. Pour finir, nous générons le code HDL puis fermons Platform Designer.

> Cliquez sur Generate HDL. Choisissez VHDL au lieu de Verilog. Laisser le reste des paramètres par défault.

### De retour dans Quartus

1. Nous ajoutons le fichier ```sopc/nios/synthesis/nios.qip``` au projet, comme proposé par le logiciel.

2. Puis nous ouvrons le fichier ```tp_nios_v.vhd```, avant la déclaration de l'```entity```, nous ajoutons les deux lignes suivantes :

```vhdl
library nios;
use nios.nios;
```

3. Nous instançons le soft-processeur :

```vhdl
nios0 : entity nios.nios
    port map (
        clk_clk                          => i_clk,
        reset_reset_n                    => i_rst_n,
        pio_0_external_connection_export => o_led
    );
```

> NOTE :  
> Les noms des signaux peuvent être copié-collés depuis le fichier ```sopc/nios/nios_inst.vhd```

4. Puis, nous compilons le projet et programmons la carte, comme d'habitude.

>[!IMPORTANT]  
>A ce stade là, il nous est impossible de flasher notre carte FPGA car il nous manque certains fichier et une licence.  
>Nous suivons donc le tutoriel suivant afin d'obtenir une licence auprès d'INTEL [tutoriel](https://github.com/lfiack/ENSEA_2A_FPGA_Public/blob/main/majeure/3-tp/get_licence.md).  

### Création du projet soft

1. Dans le dossier ```soft```, nous créons un dossier ```app```

2. Dans ce dossier ```app```, nous créeons un fichier ```main.c```

3. Puis, nous lançons l'outil ```niosv-shell```.

4. À l'aide de la commande ```cd```, nous nous déplaçons jusqu'à notre dossier de travail (```tp_nios_v```).

5. Nous créeons la bsp : 

> niosv-bsp -c -t=hal --sopc-info=sopc/nios.sopcinfo soft/bsp/settings.bsp

6. Nous créeons le projet de l'application :

> niosv-app -a=soft/app/ -b=soft/bsp/ -s=soft/app/main.c

7. Enfin, nous lançons l'IDE depuis le terminal ```niosv-shell```:

> RiscFree

8. Une fenêtre nous demande de choisir un _workspace_. Nous choisissons le dossier ```soft```.

9. Nous importons alors la ```bsp```

> File > Import Nios V CMake project...

10. Et l'```app```

> File > Import Nios V CMake project...

### Hello, world!

1. Nous ouvrons le fichier ```main.c``` et ajoutons le code suivant :

```C
#include <stdio.h>

int main (void)
{
	printf("Hello, world!\n");

	return 0;
}
```

2. Nous compilons le projet

3. Lançons le programme :

> Run > Run 

Choisissons :  

> Ashling RISC-V Hardware Debugging

Puis :  

> app.elf

Dans l'onglet ```Debugger``` :  

> Cliquez sur Auto-detect Scan Chain

Puis, nous choisissons :   

> 5CSEBA6

Enfin, nous cliquons sur ```Run```.

4. Le soft-processeur est maintenant programmé. Nous déconnectons le debugger

5. Dans le terminal, nous nous connectons au soft-processeur 

> juart-terminal

Nous voyons alors bel et bien apparaître le contenu de notre printf !  

<img width="1471" height="143" alt="image" src="https://github.com/user-attachments/assets/d584a7e5-c777-4003-8fa7-f0e83126cfce" />  

### L'inévitable chenillard

Notre printf étant fonctionnel, nous nous attaquons alors à l'implémentation d'un chenillard en C dans notre SOPC.  

Voici le code C que nous écrivons :  

```C
#include <unistd.h>  // usleep
#include "system.h"
#include "altera_avalon_pio_regs.h"

#define NB_LEDS 10
#define DELAY_US 200000  // 200 ms

int main(void)
{
    unsigned int led_value;
    int i;

    while (1)
    {
        /* Défilement de gauche à droite */
        for (i = 0; i < NB_LEDS; i++)
        {
            led_value = (1 << i);
            IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, led_value);
            usleep(DELAY_US);
        }

        /* Défilement de droite à gauche */
        for (i = NB_LEDS - 2; i > 0; i--)
        {
            led_value = (1 << i);
            IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, led_value);
            usleep(DELAY_US);
        }
    }

    return 0;
}
```

Une fois le code compilé puis runné, nous obtenons alors le magnifique résultat suivant :  
![PXL_20260112_150929661 TS](https://github.com/user-attachments/assets/2d724ff2-b589-4237-8b92-580db8ce0cee)  

## Petit projet

Notre objectif est maintenant de réutiliser le télécran fait lors des TPs précédents et de faire en sorte que l'écran se nettoye lorsque la carte FPGA est secouée.  

Pour ce faire, nous allons utiliser l'accéléromètre ADXL345 situé sur le shield de notre carte FPGA d'Analog Device dont la documentation est disponible ici : [adxl345.pdf](https://www.analog.com/media/en/technical-documentation/data-sheets/adxl345.pdf).  

### Le niveau à bulles
 
L'objectif de ce projet est d'afficher l'angle de la carte sur les LED à la manière d'un niveau à bulles.

Pour ce faire nous nous aidons de l'[Annexe](#annexe) et en particulier des parties concernant le [Contrôleur I2C](#contrôleur-i2c) et l'[Accéléromètre ADXL345](#accéléromètre-adxl345).

Nous suivons le protocole suivant :  
1. Éditez le soft-processeur pour ajouter un contrôleur I2C.
2. Modifiez le VHDL en conséquent.
3. Supprimer le dossier ```bsp``` ainsi que tous les fichiers (sauf ```main.c```) dans le dossier ```app```.
4. Recréez la bsp et l'app, importez-les dans RiscFree.
    * Le chenillard devrait toujours être fonctionnel !
5. Écrivez le code permettant de représenter l'angle de la carte sur les LED à la manière d'un niveau à bulles.

Ainsi, dans un premier temps, on commence donc par modifier le fichier Quartus Platform Designer afin d'ajouter un bloc I2C.  
Suite à cela, nous regénérons notre fichier VHDL décrivant notre SOPC, puis retéléversons le script VHDL sur notre carte FPGA avant de regénérer la BSP et les fichiers du dossier app.    
Une fois tout cela fait, nous compilons et exécutons le code C suivant :  

```C
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
```

Malheureusement, nous n'avons pas obtenu le résultat désiré une fois le code téléversé dans notre système.  

## Conclusion  

En conclusion, durant ces dernières séances de TP nous avons appris : 
- À construire un système de type SOPC (System On a Programmable Chip) basé sur un soft-processeur de type NIOS V via Platform designer
- À écrire du code en C et le téléverser comme il se doit dans notre système

# FIN DE MON DERNIER TP A L'ENSEA 😁 
