extends Node

signal board_cleared()
# Emitido quando o jogador vira a primeira ou segunda carta
signal card_flipped(card_node: Node)
signal force_reveal_random_card()
# Emitido pelo CombatManager ou CardManager quando um par é validado
signal pair_matched(card: CardData)
signal pair_failed()
var flips_allowed_this_turn: int = 2
var current_flips: int = 0
signal clear_unmatched_cards() # Sinal puramente visual
var is_board_locked: bool = false
# Emitido pelo AffinityManager quando uma nova meta de família é atingida
signal affinity_threshold_reached(family: String, level: int)

# Emitido para atualizar a UI
signal player_hp_changed(current_hp: int, max_hp: int)
signal gold_changed(current_gold: int)
signal floor_changed(new_floor: int)

# Sinais do Sistema de Energia e Habilidades
signal energy_changed(current_energy: int)
signal ability_activated() # O botão do HUD vai emitir isso

# Combate
signal enemy_hp_changed(current_hp: int, max_hp: int)
signal enemy_defeated()
signal game_over()
signal enemy_setup(enemy_name: String, max_hp: int, max_mp: int)

# Sinais do Ataque Especial (Ultimate)
signal special_charged() # Acende o botão no HUD
signal activate_special_requested() # O botão do HUD avisa que foi clicado
