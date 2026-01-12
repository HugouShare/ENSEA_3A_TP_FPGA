# Compte rendu : TP FPGA  

Lien vers sujet FPGA : [sujet TP FPGA](https://github.com/lfiack/ENSEA_2A_FPGA_Public/blob/main/mineure/3-tp/fpga_tp.md)  

## Sommaire  

<details>  
<summary><b>📌 Cliquez pour dérouler le sommaire</b></summary>  

<br>

- [📖 Introduction](#introduction)

- [🛠️ Tutoriel Quartus](#tutoriel-quartus)
  - [🔌 Branchement de la carte](#branchement-de-la-carte)
  - [📁 Création d'un projet](#création-dun-projet)
  - [🧾 Création d'un fichier VHDL](#création-dun-fichier-vhdl)
  - [📌 Fichier de contraintes](#fichier-de-contraintes)
  - [⚙️ Compilation et programmation de la carte](#compilation-et-programmation-de-la-carte)
  - [💡 Faire clignoter une LED](#faire-clignoter-une-led)
  - [✨ Chenillard](#chennillard-)

- [🧪 Petit projet : écran magique](#petit-projet--écran-magique)
  - [🎛️ Gestion des encodeurs](#gestion-des-encodeurs)
    - [📊 Analyse fonctionnelle](#analyse-fonctionnelle)
    - [🧠 Implémentation de la solution VHDL](#implémentation-de-la-solution-vhdl)
    - [🖥️ Implémentation du modèle de simulation sur Modelsim](#implémentation-du-modèle-de-simulation-sur-modelsim)
    - [🚀 Implémentation du code VHDL sur la carte FPGA](#implémentation-du-code-vhdl-sur-la-carte-fpga)

  - [📺 Comment visualiser la sortie HDMI ?](#comment-visualiser-la-sortie-hdmi-)

  - [🧩 Contrôleur HDMI](#contrôleur-hdmi)
    - [📦 Entity](#entity)
    - [↔️ Synchro horizontale](#synchro-horizontale)
    - [↕️ Synchro verticale](#synchro-verticale)
    - [🧪 Test et simulation sur ModelSim](#test-et-simulation-sur-modelsim)
    - [🎯 Data enable : pixels actifs](#data-enable--pixels-actifs)
    - [📍 Générateur d'adresses et de coordonnées](#générateur-dadresses-et-de-coordonnées)

  - [🖱️ Déplacement d'un pixel](#déplacement-dun-pixel)
  - [🧠 Mémorisation](#mémorisation)
  - [🧹 Effacement](#effacement)
  - [🏁 Résultat final de notre telecran](#résultat-final-de-notre-telecran)

- [✅ Conclusion](#conclusion)

</details>  

## Introduction  

Durant ces premières séances de travaux pratiques nous allons travailler sur Quartus et Modelsim.  

Nos objectifs vont être :  
- de faire clignoter une LED sur notre carte FPGA
- d'implémenter un chenillard sur notre carte FPGA, en se basant sur un détecteur de front montant et descendant ainsi qu'un compteur
- d'implémenter un écran magique permettant de visualiser, via VLC, les dessins faits par l'utilisateur

## Tutoriel Quartus  

### Branchement de la carte  

Voici un aperçu de notre carte FPGA :  
<img width="1261" height="634" alt="image" src="https://github.com/user-attachments/assets/b9d4cbae-1ef4-4d9c-98e5-9f7475cf88a6" />

### Création d'un projet  

Nous créons un projet Quartus comme indiqué sur le sujet.  
Notre carte est la : ```5CSEBA6U23I7```  

### Création d'un fichier VHDL  

Nous créons un fichier VHDL et écrivons le code fournis dans le sujet.  
Ce code permet d'allumer la LED0 lorsqu'un bouton poussoir de l'encodeur gauche est enfoncé.  
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

> [!IMPORTANT]
> ATTENTION : le nom de l'entité doit être le même que celui du projet !

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
5° : nous sélectionnons le fichier ```.sof``` dans le dossier output_files et cochons la case ```Program/Configure```  

Nous obtenons alors le résultat suivant : la LED est allumée par défaut et s'éteind lorsque l'on appui sur l'encodeur de gauche.  
Nous voulons le fonctionnement inverse.  
Nous modifions donc le code de la manière suivante afin d'obtenir le résultat souhaité :  
```
led0 <= not pushl;
```  
Nous obtenons alors bien le résultat souhaité : la LED LED0 est éteinte par défaut et lorsque l'on appui sur l'encodeur gauche, celle-ci s'allume !  

### Faire clignoter une LED  

Nous voulons maintenant passer d'un mode de fonctionnement combinatoire vers un mode de fonctionnement en séquentiel.  

D'après le document "DE10-Nano user manual", nous obtenons l'information suivante :  
<img width="1036" height="245" alt="image" src="https://github.com/user-attachments/assets/b9454622-d1fd-4841-ab4d-ed316acf3c3c" />  

Nous implémentons alors le code suivant :  
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

Dans la zone de compilation, nous ouvrons : Compile Design > Analysis & Synthesis > Netlist Viewers puis lançons ```RTL Viewer```    

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
| Clignotement de LED | Clignotement de LED avec appui sur RESET |
|--------------------|------------------------------------------|
| ![](https://github.com/user-attachments/assets/685e772d-a2a3-4353-b15c-ef6fd09bc2f2) | ![](https://github.com/user-attachments/assets/6dbf51bc-e1bc-4628-9276-16b61fa65c4f) |

> NOTE :  
> Dans ```i_rst_n``` le suffixe __n_ sert à indiquer la logique inversée : '1' -> '0' et inversement '0' -> '1'.  

### Chennillard !!!  

> CODE VHDL :  
> Projet > TP_FPGA_CHENILLARD  

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
>La ligne ```r_leds <= r_leds(0) & r_leds(9 downto 1);``` permet de réaliser le décallage du '1'.  
>Elle permet de rajouter en bout de ligne un '1' et donc de le décaler dans le buffer.  

Nous obtenons alors un beau chenillard ! 😁  
![PXL_20251212_103750952](https://github.com/user-attachments/assets/e038c168-e414-40ad-b3ed-ba4ec03203d5)  

> NOTE :  
> Seul le code VHDL correspondant au chenillard est fourni dans le dossier ```Projet``` puisqu'il s'appuie sur les parties précédentes et en est une version finale.  

## Petit projet : écran magique  

L'objectif est de réaliser un télécran.  
```
Nous adopterons une démarche en plusieurs étapes afin de parvenir au résultat final, tout en suivant la démarche suivante pour chaque étape :  
- Concevoir un schéma pour répondre à la problématique
- Implémenter la solution en VHDL
- Simuler cette solution
- Tester sur la carte
```

### Gestion des encodeurs  

L'idée est la suivante : lorsque l'on tourne l'encodeur vers la droite, on incrémente la valeur d'un compteur. Lorsque l'on tourne l'encodeur vers la gauche, on décrémente la valeur du compteur.  
Nous voulons, en plus de cela, afficher sur les leds la valeur du compteur qui ira donc de 1 à 10 (pour pouvoir afficher la valeur du compteur sur les LEDs étant au nombre de 10).  

De manière plus détaillée, le fonctionnement est le suivant : un encodeur renvoie deux signaux : A et B, qui sont en quadrature de phase.  

Il y a alors deux conditions possible pour incrémenter le registre :  
- Front montant sur A et B à l'état bas
- Front descendant sur A et B à l'état haut
 
Et il y a deux conditions possible pour décrémenter le registre :  
- Front montant sur B et A à l'état bas
- Front descendant sur B et A à l'état haut

Ainsi, le compteur augmente si le signal A est en avance de phase sur B et diminue si le signal A est en retard de phase sur le signal B.  

#### Analyse fonctionnelle  

D'un point de vue fonctionnel, les idées mentionnées précédemment peuvent se traduire par le schema RTL suivant :  
<img width="1023" height="241" alt="image" src="https://github.com/user-attachments/assets/ee5caea8-2a68-4fe0-b9da-183df4c9c530" />  

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
        o_led_0 : out std_logic;
        o_led_1 : out std_logic;
        o_led_2 : out std_logic;
        o_led_3 : out std_logic;
        o_led_4 : out std_logic;
        o_led_5 : out std_logic;
        o_led_6 : out std_logic;
        o_led_7 : out std_logic;
        o_led_8 : out std_logic;
        o_led_9 : out std_logic
    );
end entity;

architecture rtl of encodeur is

    ------------------------------------------------------------------
    -- PARAMÈTRE DE DEBOUNCE
    -- (ex: 50_000 cycles ≈ 1 ms @ 50 MHz)
    ------------------------------------------------------------------
    constant DEBOUNCE_CYCLES : integer := 50_000;

    ------------------------------------------------------------------
    -- SIGNAUX DEBOUNCE A
    ------------------------------------------------------------------
    signal A_sync   : std_logic := '0';
    signal A_stable : std_logic := '0';
    signal A_count  : integer range 0 to DEBOUNCE_CYCLES := 0;

    ------------------------------------------------------------------
    -- SIGNAUX DEBOUNCE B
    ------------------------------------------------------------------
    signal B_sync   : std_logic := '0';
    signal B_stable : std_logic := '0';
    signal B_count  : integer range 0 to DEBOUNCE_CYCLES := 0;

    ------------------------------------------------------------------
    -- DÉTECTION DE FRONTS
    ------------------------------------------------------------------
    signal A_d, B_d : std_logic := '0';

    ------------------------------------------------------------------
    -- COMPTEUR
    ------------------------------------------------------------------
    signal compteur : unsigned(9 downto 0) := (others => '0');

begin

    ------------------------------------------------------------------
    -- PROCESS UNIQUE : DEBOUNCE + ENCODEUR
    ------------------------------------------------------------------
    process(i_clk, i_rst_n)
    begin
        if i_rst_n = '0' then
            -- Reset global
            A_sync   <= '0';
            A_stable <= '0';
            A_count  <= 0;

            B_sync   <= '0';
            B_stable <= '0';
            B_count  <= 0;

            A_d <= '0';
            B_d <= '0';

            compteur <= (others => '0');
				

        elsif rising_edge(i_clk) then
            ------------------------------------------------------------------
            -- SYNCHRONISATION (anti-métastabilité)
            ------------------------------------------------------------------
            A_sync <= i_A;
            B_sync <= i_B;

            ------------------------------------------------------------------
            -- DEBOUNCE A
            ------------------------------------------------------------------
            if A_sync /= A_stable then
                A_count <= A_count + 1;
                if A_count = DEBOUNCE_CYCLES then
                    A_stable <= A_sync;
                    A_count  <= 0;
                end if;
            else
                A_count <= 0;
            end if;

            ------------------------------------------------------------------
            -- DEBOUNCE B
            ------------------------------------------------------------------
            if B_sync /= B_stable then
                B_count <= B_count + 1;
                if B_count = DEBOUNCE_CYCLES then
                    B_stable <= B_sync;
                    B_count  <= 0;
                end if;
            else
                B_count <= 0;
            end if;

            ------------------------------------------------------------------
            -- DÉTECTION DE FRONTS (sur signaux propres)
            ------------------------------------------------------------------
            A_d <= A_stable;
            B_d <= B_stable;

            ------------------------------------------------------------------
            -- LOGIQUE ENCODEUR
            ------------------------------------------------------------------
				-- INCRÉMENTATION
				if (A_stable = '1' and A_d = '0' and B_stable = '0') or
					(A_stable = '0' and A_d = '1' and B_stable = '1') then

					 if compteur = 9 then
						  compteur <= (others => '0');  -- retour à 0
					 else
						  compteur <= compteur + 1;
					 end if;

				-- DÉCRÉMENTATION
				elsif (B_stable = '1' and B_d = '0' and A_stable = '0') or
						(B_stable = '0' and B_d = '1' and A_stable = '1') then

					 if compteur = 0 then
						  compteur <= to_unsigned(9, compteur'length); -- retour à 9
					 else
						  compteur <= compteur - 1;
					 end if;

				end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- DECODAGE DU COMPTEUR VERS LES LEDS (ONE-HOT)
    --------------------------------------------------------------------
    process(compteur)
    begin
        -- éteindre toutes les LEDs par défaut
        o_led_0 <= '0';
        o_led_1 <= '0';
        o_led_2 <= '0';
        o_led_3 <= '0';
        o_led_4 <= '0';
        o_led_5 <= '0';
        o_led_6 <= '0';
        o_led_7 <= '0';
        o_led_8 <= '0';
        o_led_9 <= '0';

        case to_integer(compteur) is
            when 0 => o_led_0 <= '1';
            when 1 => o_led_1 <= '1';
            when 2 => o_led_2 <= '1';
            when 3 => o_led_3 <= '1';
            when 4 => o_led_4 <= '1';
            when 5 => o_led_5 <= '1';
            when 6 => o_led_6 <= '1';
            when 7 => o_led_7 <= '1';
            when 8 => o_led_8 <= '1';
            when 9 => o_led_9 <= '1';
            when others => null; -- aucune LED si > 9
        end case;
    end process;

end architecture;
```  

#### Implémentation du modèle de simulation sur Modelsim  

> CODE SIMULATION :  
> Projet > TP_FPGA_ENCODEURS_MODELSIM  

Nous commençons d'abord par simuler le comportement qu'aurait une carte FPGA suite à l'implémentation de notre solution VHDL.  

Après avoir écrit notre fichier ```encodeurs_tb.bhd```, nous obtenons les résultats de simulations suivants :  
<img width="1876" height="624" alt="image" src="https://github.com/user-attachments/assets/c79c4c95-6c6a-4077-b2ab-9d96e279ffdc" />  

#### Implémentation du code VHDL sur la carte FPGA  

> CODE CIBLE :  
> Projet > TP_FPGA_ENCODEURS_QUARTUS  

Suite à cela, nous téléversons alors notre fichier VHDL sur notre carte FPGA.  

Voici le schéma RTL généré par Quartus :  
<img width="1849" height="429" alt="image" src="https://github.com/user-attachments/assets/00e54cc4-dedf-4427-93e9-629ea8364190" />  
Pour voir celui-ci plus en détails : [cliquez-ici](https://github.com/HugouShare/ENSEA_3A_TP_FPGA-FPGA_AVANCE/blob/main/Projet/TP_FPGA/fichier%20RTL.pdf)

### Comment visualiser la sortie HDMI ?  

Nous branchons le cable HDMI à notre carte et à l'adaptateur.  
Puis nous branchons le port USB à l'ordinateur.  
Enfin, nous lançons le logiciel VLC et ajoutons un nouveau _Capture device_ et définissons le _Video device name_ à ```USB Video```.  

Voici ce que nous obtenons pour le moment :  
<img width="636" height="613" alt="image" src="https://github.com/user-attachments/assets/544abffe-df75-41b0-b813-94bff751b3c2" />  

### Contrôleur HDMI  

Afin de concevoir un contrôleur HDMI, nous reprenons ce que nous avons conçu durant la séance de TD :  

#### Entity  

1. Création d'un fichier _hdmi_controler.vhd_    
2. Écriture de la partie ```generic``` de son ```entity```  
3. Écriture de la partie ```port``` de son ```entity```  

#### Synchro horizontale  

1. Création de trois constantes : ```h_start : h_sync + h_fp``` ,  ```h_end : h_start + h_res``` , ```h_total : h_end + h_bp```  
2. Création de deux registres : ```r_h_count``` et ```r_h_active```  
3. Création d'un process sensible aux signaux d'horloge et de reset  
4. Ecriture des différents scripts des signaux et registres  

#### Synchro verticale  

1. Création de trois constantes : ```v_start : v_sync + v_fp``` ,  ```v_end : v_start + v_res``` , ```v_total : v_end + v_bp```  
2. Création de deux registres : ```r_v_count``` et ```r_v_active```  
3. Création d'un process sensible aux signaux d'horloge et de reset  
4. Ecriture des différents scripts des signaux et registres  
   
#### Test et simulation sur ModelSim  

Après écriture du fichier VHDL, du testbench ainsi que du fichier .do, nous obtenons les résultats suivants sur ModelSim :  
<img width="1807" height="620" alt="image" src="https://github.com/user-attachments/assets/e6c44105-2067-482f-8ab3-932ff538f37b" />  

#### Data enable : pixels actifs  

On décrit le registre de sortie ```o_hdmi_de``` de telle sorte qu'en cas de reset, la sortie prenne la valeur 'O' et en cas de front montant : ```o_hdmi_de <= r_v_active and r_h_active;```.  

#### Générateur d'adresses et de coordonnées  

Nous écrivons le code permettant de générer le signal ```o_pixel_en``` et les signaux ```o_x_counter``` , ```o_y_counter``` et ```o_pixel_address```.  

Nous ajoutons le fichier _hdmi_controler.vhd_ au projet.  

Nous instançons le composant ```hdmi_controler``` dans notre fichier top (telecran.vhd) comme suit :  
```VHDL
-- HDMI controler
    hdmi_ctrl : component hdmi_controler
        port map (
            i_clk           => s_clk_27,
            i_rst_n         => s_rst_n,
            o_hdmi_hs       => o_hdmi_tx_hs,
            o_hdmi_vs       => o_hdmi_tx_vs,
            o_hdmi_de       => o_hdmi_tx_de,
            o_pixel_en      => open,
            o_pixel_address => s_pixel_address,
            o_x_counter     => open,
            o_y_counter     => open
        );
```  

### Déplacement d'un pixel  

Nous modifions le fichier ```telecran.vhd```, on atribue la valeur blanche ```o_hdmi_tx_d``` :  
```VHDL
o_hdmi_tx_d <= (others => '1') when s_pixel_data = x"FF" else (others => '0');
```

### Mémorisation  

Suite à cela, nous implémentons le script permettant de mémoriser les pixels parcourus pour afficher le dessin.  
Pour faire cela, nous utilisons un ```framebuffer``` pour stocker les pixels déjà allumés et les futurs pixels à allumer.  

Une mémoire ```dual-port``` est une mémoire qui possède deux ports d’accès indépendants, permettant deux opérations simultanées sur la même mémoire.   
Elle peut ainsi effectuer en même temps une lecture ou une écriture.  

Fichier ```dpram.vhd``` : 
```VHDL
library ieee;
use ieee.std_logic_1164.all;

entity dpram is
    generic
    (
        mem_size    : natural := 720 * 480;
        data_width  : natural := 8
    );
   port 
   (   
        i_clk_a        : in std_logic;
        i_clk_b        : in std_logic;

        i_data_a    : in std_logic_vector(data_width-1 downto 0);
        i_data_b    : in std_logic_vector(data_width-1 downto 0);
        i_addr_a    : in natural range 0 to mem_size-1;
        i_addr_b    : in natural range 0 to mem_size-1;
        i_we_a      : in std_logic := '1';
        i_we_b      : in std_logic := '1';
        o_q_a       : out std_logic_vector(data_width-1 downto 0);
        o_q_b       : out std_logic_vector(data_width-1 downto 0)
   );
   
end dpram;

architecture rtl of dpram is
    -- Build a 2-D array type for the RAM
    subtype word_t is std_logic_vector(data_width-1 downto 0);
    type memory_t is array(0 to mem_size-1) of word_t;
    
    -- Declare the RAM
    shared variable ram : memory_t;
begin
    -- Port A
    process(i_clk_a)
    begin
        if(rising_edge(i_clk_a)) then 
            if(i_we_a = '1') then
                ram(i_addr_a) := i_data_a;
            end if;
            o_q_a <= ram(i_addr_a);
        end if;
    end process;
    
    -- Port B
    process(i_clk_b)
    begin
        if(rising_edge(i_clk_b)) then
            if(i_we_b = '1') then
                ram(i_addr_b) := i_data_b;
            end if;
            o_q_b <= ram(i_addr_b);
        end if;
    end process;
end rtl;
```  

Extension du composant ```dpram``` dans le fichier ```telecran.vhd``` :  
``` VHDL
	component dpram 
        generic (
            mem_size    : natural := 720 * 480;
            data_width  : natural := 8
        );
        port (   
            i_clk_a     : in std_logic;
            i_clk_b     : in std_logic;
            i_data_a    : in std_logic_vector(data_width-1 downto 0);
            i_data_b    : in std_logic_vector(data_width-1 downto 0);
            i_addr_a    : in natural range 0 to mem_size-1;
            i_addr_b    : in natural range 0 to mem_size-1;
            i_we_a      : in std_logic := '1';
            i_we_b      : in std_logic := '1';
            o_q_a       : out std_logic_vector(data_width-1 downto 0);
            o_q_b       : out std_logic_vector(data_width-1 downto 0)
       );
    end component;

```

Puis nous modifions le signal ```o_hdmi_tx_d```.  

### Effacement   

Afin de pouvoir effectuer une opération d'effacement, il faut :  
- Détecter l’appui sur un bouton  
- Lancer un processus automatique  
- Ecrire 0 partout  
- Puis revenir au fonctionnement normal  

Signaux pour l'effacement qui ont été introduits dans ```telecran.vhd``` :  
```VHDL
	signal r_erase_active : std_logic := '0';
    signal r_erase_addr   : natural range 0 to (720 * 480) - 1 := 0;
    signal s_mux_addr_a   : natural range 0 to (720 * 480) - 1;
    signal s_mux_data_a   : std_logic_vector(7 downto 0);
```

Fonction pour l'effacement : 
```VHDL
	process(i_clk_50, i_rst_n)
    begin
        if i_rst_n = '0' then
            r_erase_active <= '0';
            r_erase_addr   <= 0;
        elsif rising_edge(i_clk_50) then
            if i_left_pb = '0' then -- Bouton pressé
                r_erase_active <= '1';
                r_erase_addr   <= 0;
            elsif r_erase_active = '1' then
                if r_erase_addr = (720 * 480) - 1 then
                    r_erase_active <= '0';
                else
                    r_erase_addr <= r_erase_addr + 1;
                end if;
            end if;
        end if;
    end process;
```

### Résultat final de notre telecran 

Finalement, après intégration de tous les différents blocs construits précédemment, nous implémentons notre script VHDL final. 

D'un point de vue fonctionnel :  
- notre encodeur gauche déplace le pixel à l'horizontal
- l'encodeur droit déplace le pixel à la verticale
- enfin, lorsque nous appuyons sur le bouton de l'encodeur gauche, l'écran s'éteint

Voici une démonstration du résultat final obtenu avec dessin, puis appui sur le bouton RESET :  
![dshow___-VLC-media-player-2026-01-12-16-36-28](https://github.com/user-attachments/assets/d40aa5e9-42af-4f5b-adf0-20ab160f172b)  

## Conclusion  

En conclusion, durant ces première séances de travaux pratiques, nous aurons appris à :  
- Manipuler Quartus (Platform designer, RTL Viewer, ...) ainsi que Modelsim
- Adopter une métthode pour travailler sur une thématique FPGA :
	- Concevoir un schéma pour répondre à la problématique
	- Implémenter la solution en VHDL
	- Simuler cette solution
	- Tester sur la carte
 - Réaliser un chenillard sur carte FPGA ainsi qu'un télécran  

# FIN
