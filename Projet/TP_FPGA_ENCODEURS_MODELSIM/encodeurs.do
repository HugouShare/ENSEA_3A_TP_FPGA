# =========================================================
# Script ModelSim pour la simulation de l'encodeur
# =========================================================

# Nettoyage
quit -sim

# Création de la librairie de travail
vlib work

# Compilation des fichiers VHDL
vcom encodeurs.vhd
vcom encodeurs_tb.vhd

# Lancement de la simulation
vsim -c work.composant_nul_tb

# Affichage des signaux principaux
add wave -divider "Horloge & Reset"
add wave clk
add wave reset

add wave -divider "Encodeur"
add wave A
add wave B

add wave -divider "Sortie"
add wave leds

# Affichage en non signé pour le compteur
radix unsigned
wave zoom full

# Lancement de la simulation
run 2 us

# Fin
echo "Simulation terminée"