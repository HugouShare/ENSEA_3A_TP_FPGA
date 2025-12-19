# Compte rendu du TP  

Lien vers sujet FPGA : [sujet de FPGA](https://github.com/lfiack/ENSEA_2A_FPGA_Public/blob/main/mineure/3-tp/fpga_tp.md)  
Lien vers sujet FPGA AVANCE :  

## Introduction  

Durant ces séances de travaux pratiques nous allons travailler sur Quartus.  

## Tutoriel Quartus  

### Branchement de la carte  

Voici un aperçu de notre carte FPGA :  
<img width="1261" height="634" alt="image" src="https://github.com/user-attachments/assets/b9d4cbae-1ef4-4d9c-98e5-9f7475cf88a6" />

### Création d'un projet  

Nous créons un projet Quartus comme indiqué sur le sujet.  
Notre carte est la : ```5CSEBA6U23I7```  

### Création d'un fichier VHDL  

Nous créons un fichier VHDL et écrivons le code fournis dans le sujet. Ce code permet d'allumer la LED0 lorsqu'un bouton poussoir de l'encodeur gauche est enfoncé.  
Voici le code :  
```VHDL
library ieee;
use ieee.std_logic_1164.all;

entity tuto_quartus is
    port (
        pushl : in std_logic;
        led0 : out std_logic
    );
end entity tuto_quartus;

architecture rtl of tuto_quartus is
begin
    led0 <= pushl;
end architecture rtl;
```
ATTENTION : le nom de l'entité doit être le même que celui du projet !  

### Fichier de contraintes  

Nous avons :  
```LED0``` est sur la broche ```PIN_AG28```
```pushl``` est sur la broche ```PIN_AH27```
Nous configurons cela via Assignments > Pin Planner  

### Compilation et programmation de la carte  

1° : nous cliquons d'abord sur ```Compile Design```  
2° : nous lançons l'outil de programmation du FPGA => Tools > Programmer  
3° : nous cliquons sur ```Auto detect```  
4° : nous chargeons le bitstream => Clic-droit sur la puce > Edit > Change File  
5° : nous sélectionnons le fichier .sof dans le dossier output_files et cochons la case ```Program/Configure```  

Nous obtenons alors le résultat suivant : la LED est allumée par défaut et s'éteind lorsque l'on appui sur l'encodeur de gauche. Nous voulons le fonctionnement inverse. Nous modifions donc le code de la manière suivante afin d'obtenir le résultat souhaité :  
```
led0 <= not pushl;
```
Nous obtenons alors bien le résultat souhaité : la LED LED0 est éteinte par défaut et lorsque l'on appui sur l'encodeur gauche, celle-ci s'allume !  

### Faire clignoter une LED  

Nous voulons maintenant d'un mode de fonctionnement combinatoire vers un mode de fonctionnement en séquentiel.  

D'après le document "DE10-Nano user manual", nous obtenons l'information suivante :  
<img width="1036" height="245" alt="image" src="https://github.com/user-attachments/assets/b9454622-d1fd-4841-ab4d-ed316acf3c3c" />  

Nous ajoutons le code suivant :  
```VHDL
library ieee;
use ieee.std_logic_1164.all;

entity led_blink is
    port (
        i_clk : in std_logic;
        i_rst_n : in std_logic;
        o_led : out std_logic
    );
end entity led_blink;

architecture rtl of led_blink is
    signal r_led : std_logic := '0';
begin
    process(i_clk, i_rst_n)
    begin
        if (i_rst_n = '0') then
            r_led <= '0';
        elsif (rising_edge(i_clk)) then
            r_led <= not r_led;
        end if;
    end process;
    o_led <= r_led;
end architecture rtl;
```  

$$$$$$$$$$$$$$$$$$$$$$$$$$$$ TRACER LE SCHEMA CORRESPONDANT AU CODE VHDL $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  

Dans la zone de compilation, nous ouvrons : Compile Design > Analysis & Synthesis > Netlist Viewers puis lancer RTL Viewer  
Nous obtenons alors :  
<img width="1469" height="713" alt="image" src="https://github.com/user-attachments/assets/b442d370-8a39-4ec1-aa37-07036f4d8a15" />  

Dans l'état actuel, la LED clignoterait à 50MHz, ce qui est beaucoup trop rapide.  
Nous modifions alors le code de manière à réduire cette fréquence.  

Nous modifions le code comme suit :  
```VHDL
library ieee;
use ieee.std_logic_1164.all;

entity tuto_quartus is
    port (
        i_clk : in std_logic;
        i_rst_n : in std_logic;
        o_led : out std_logic
    );
end entity tuto_quartus;

architecture rtl of tuto_quartus is
    signal r_led_enable : std_logic := '0';
begin
	process(i_clk, i_rst_n)
		 variable counter : natural range 0 to 5000000 := 0;
	begin
		 if (i_rst_n = '0') then
			  counter := 0;
			  r_led_enable <= '0';
		 elsif (rising_edge(i_clk)) then
			  if (counter = 5000000) then
					counter := 0;
					r_led_enable <= not r_led_enable;
					-- r_led_enable <= '1';
			  else
					counter := counter + 1;
					-- r_led_enable <= '0';
			  end if;
		 end if;
	end process;
	o_led <= r_led_enable;
end architecture rtl;
```

Depuis la vue RTL, nous obtenons alors :  
<img width="1529" height="368" alt="image" src="https://github.com/user-attachments/assets/647aa895-4294-4c81-b638-b6c9a60f3a21" />  

Nous utilisons l'encodeur gauche comme bouton de RESET.  

Après avoir compilé et téléversé le code sur la carte FPGA, nous obtenons le résultat suivant :  
![Clignotement de LED](https://github.com/user-attachments/assets/685e772d-a2a3-4353-b15c-ef6fd09bc2f2)  
![Clignotement de LED avec appui sur RESET](https://github.com/user-attachments/assets/6dbf51bc-e1bc-4628-9276-16b61fa65c4f)  

Dans ```i_rst_n``` le suffixe _n sert à indiquer une logique inversée : '1' -> '0' et inversement '0' -> '1'.  

### Chennillard !!!  

> CODE : Projet > TP_FPGA_CHENILLARD  

Nous réalisons maintenant un chennillard sur notre carte FPGA.  

Nous avons maintenant 10 LEDs configurées comme suit :  
<img width="253" height="565" alt="image" src="https://github.com/user-attachments/assets/937df7fa-2427-4d26-b986-59d42cb6aec0" />  

Nous écrivons le code suivant :  
```VHDL
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
```  
>NOTE :  
>La ligne ```r_leds <= r_leds(0) & r_leds(9 downto 1);``` permet de réaliser le décallage du '1'. Elle permet de rajouter en bout de ligne un '1' et donc de le décaler dans le buffer.  

Nous obtenons alors un beau chenillard ! 😁  
![PXL_20251212_103750952](https://github.com/user-attachments/assets/e038c168-e414-40ad-b3ed-ba4ec03203d5)  

> NOTE :  
> Seul le code VHDL correspondant au chenillard est fourni dans le dossier ```Projet``` puisqu'il s'appuie sur les parties précédentes et en est une version finale.  

## Petit projet : écran magique  

L'objectif est de réaliser un télécran.  

Nous adopterons une démarche en plusieurs étapes afin de parvenir au résultat final, tout en suivant la démarche suivante pour chaque étape :  
- Concevoir un schéma pour répondre à la problématique
- Implémenter la solution en VHDL
- Simuler cette solution
- Tester sur la carte

### Gestion des encodeurs  

L'idée est la suivante : lorsque l'on tourne l'encodeur vers la droite, on incrémente la valeur d'un compteur. Lorsque l'on tourne l'encodeur vers la gauche, on décrémente la valeur du compteur.  
Nous voulons, en plus de cela, afficher sur les leds la valeur du compteur qui ira donc de 1 à 10 (pour pouvoir afficher la valeur du compteur sur les LEDs étant au nombre de 10).  

De manière plus détaillée, le fonctionnement est le suivant :  
Un encodeur renvoie deux signaux : A et B, qui sont en quadrature de phase.  
Il y a deux conditions possible pour incrémenter le registre :  
- Front montant sur A et B à l'état bas
- Front descendant sur A et B à l'état haut  
Il y a deux conditions possible pour décrémenter le registre :  
- Front montant sur B et A à l'état bas
- Front descendant sur B et A à l'état haut
Ainsi, le compteur augmente si le signal A est en avance de phase sur B et diminue si le signal A est en retard de phase sur le signal B.

#### Analyse fonctionnelle  

$$$$$$$$$$$$$$$$$$$$$$$$$$ A REPRENDRE $$$$$$$$$$$$$$$$$$$$$$$$$$$$

Notre schéma est constitué de deux bascules D synchrones qui permettent de mémoriser les états succéssifs du signal A. La première stocke l'état du courant A et la deuxième stocke l'état précédent du signal A. 

Pour avoir un front montant : On a ```A(t-1) = 0 ``` et ```A(t) = 1 ``` avec les sorties des bascules ```Q2= 0 ``` et ```Q1= 1 ```. Nous devons donc avoir comme condition logique ```Front_montant = Q₁ AND (NOT Q₂) ```. Notre bloc ```???``` est donc une porte logique combinatoire implémentant : ```E <= Q1 and not Q2;```

Pour avoir un front descendant : On a ```A(t-1) = 1 ``` et ```A(t) = 0 ``` avec les sorties des bascules ```Q2= 1 ``` et ```Q1= 0 ```. Nous devons donc avoir comme condition logique ```Front_descendant = (NOT Q₁) AND Q₂ ```. Notre bloc ```???``` est donc une porte logique combinatoire implémentant : ```E <= not Q1 and Q2;```

#### Implémentation de la solution VHDL  

Afin de réaliser un encodeur comme désiré, nous implémentons la solution VHDL suivante :  
```VHDL
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
            -- memorisation des etats precedents
            A_d <= i_A;
            B_d <= i_B;

            -- INCREMENTATION
            if (i_A = '1' and A_d = '0' and i_B = '0') or
               (i_A = '0' and A_d = '1' and i_B = '1') then
                compteur <= compteur + 1;

            -- DECREMENTATION
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
```

#### Implémentation du modèle de simulation sur Modelsim  

> CODE SIMULATION : Projet > TP_FPGA_ENCODEURS_MODELSIM  

Nous commençons d'abord par simuler le comportement qu'aurait une carte FPGA suite à l'implémentation de notre solution VHDL.  

Après avoir écrit notre fichier ```encodeurs_tb.bhd```, nous obtenons les résultats de simulations suivants :  
<img width="1421" height="504" alt="image" src="https://github.com/user-attachments/assets/e128e36f-d2b3-402c-abf8-7e0ae297283a" />  
<img width="1419" height="503" alt="image" src="https://github.com/user-attachments/assets/481640d8-7bae-48d1-a335-b3e0c201ce07" />  
$$$$$$$$$ IMAGES DE SIMULATION A MODIFIER PAR RAPPORT A NOUVELLE VERSION $$$$$$$$$$$$$$$$

#### Implémentation du code VHDL sur la carte FPGA  

> CODE CIBLE : Projet > TP_FPGA_ENCODEURS_QUARTUS

Suite à cela, nous téléversons alors notre fichier VHDL sur notre carte FPGA.  

Voici le schéma RTL généré par Quartus :  
$$$$$$$$$$$$$$$$$$$ INSERER SHCEMA RTL QUARTUS $$$$$$$$$$$$$$$$$$$

Voici le résultat :  
$$$$$$$$$$$$$$$$$$ INSERER IMAGE VIDEO FPGA AVEC ENCODEUR $$$$$$$$$$$$$$
