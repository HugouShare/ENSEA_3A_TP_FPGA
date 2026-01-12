# Compte rendu du TP FPGA AVANCE

Lien vers sujet FPGA AVANCE : [sujet de FPGA AVANCE](https://github.com/lfiack/ENSEA_2A_FPGA_Public/blob/main/majeure/3-tp/fpga_adv_tp.md)  

## Introduction  

Durant ces séances de travaux pratiques, nous allons concevoir un SOPC (System On a Programmable Chip).  
Notre système sera basé sur la schema suivant :  
<img width="344" height="347" alt="image" src="https://github.com/user-attachments/assets/41b0f7eb-3913-46e6-9715-fca536032a1f" />

## Tutoriel Nios V

### Organisation  

Un projet soft-processeur pouvant rapidement devenir complexe, il est nécessaire de bien organiser son projet.  
Ainsi, nous adoptons l'organisation suivante : 

### Branchement de la carte  

Voici un aperçu de notre carte FPGA :  
<img width="1261" height="634" alt="image" src="https://github.com/user-attachments/assets/b9d4cbae-1ef4-4d9c-98e5-9f7475cf88a6" />

### Création d'un projet  

Nous créons un projet Quartus comme indiqué sur le sujet.  
Notre carte est la : ```5CSEBA6U23I7```  

### Création d'un fichier VHDL  

### Hello world

```C
#include <stdio.h>

int main (void)
{
	printf("Hello, world!\n");

	return 0;
}
```

<img width="1471" height="143" alt="image" src="https://github.com/user-attachments/assets/d584a7e5-c777-4003-8fa7-f0e83126cfce" />

### Chenillard 

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
&&&&&&&&&&&&&& inserer gif &&&&&&&&&&&&&&  

## Petit projet  

### Le niveau à bulles 

Dans un premier temps, on commence par modifier le fichier Quartus Platform Designer.  

