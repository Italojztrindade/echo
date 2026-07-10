class_name HUD
extends CanvasLayer

# Referências aos nós visuais usando @onready para carregamento seguro
@onready var player_hp_label: Label = $UI/PlayerStats/HPLabel
@onready var player_hp_bar: ProgressBar = $UI/PlayerStats/HPBar
@onready var energy_bar: ProgressBar = %EnergyBar
@onready var energy_label: Label = %EnergyLabel
@onready var ability_button: Button = %AbilityButton
@onready var special_button = $UI/SpecialContainer/SpecialButton

@onready var enemy_hp_label: Label = $UI/EnemyStats/HPLabel
@onready var enemy_hp_bar: ProgressBar = $UI/EnemyStats/HPBar
@onready var enemy_mp_label: Label = $UI/EnemyStats/EnemyMPLabel
var current_enemy_name: String = ""

@onready var floor_label: Label = $FloorLabel

func _ready() -> void:
	SignalBus.floor_changed.connect(_on_floor_changed)
	# Inscreve-se nos eventos do SignalBus
	SignalBus.player_hp_changed.connect(_on_player_hp_changed)
	SignalBus.enemy_hp_changed.connect(_on_enemy_hp_changed)
	SignalBus.enemy_setup.connect(_on_enemy_setup)
	special_button.visible = false
	SignalBus.special_charged.connect(_on_special_charged)
	special_button.pressed.connect(_on_special_button_pressed)
	
	# Escuta as alterações de energia
	SignalBus.energy_changed.connect(_on_energy_changed)
	
	# Conecta o clique do botão diretamente ao barramento de eventos
	ability_button.pressed.connect(_on_ability_button_pressed)
	
	
	# Configurações iniciais da barra
	energy_bar.min_value = 0
	energy_bar.max_value = 10 # Um limite visual (podemos ajustar depois se precisar de mais)
	energy_bar.value = 0
	
	# Configura o texto do botão com base no herói escolhido
	_initialize_ability_ui()
	# Valores padrão temporários antes de receber o primeiro sinal
	player_hp_label.text = "Aguardando Combate..."
	enemy_hp_label.text = "Inimigo: ?"

func _initialize_ability_ui() -> void:
	if RunManager.current_player == null: 
		return
		
	var char_name = RunManager.current_player.character_name.to_lower()
	match char_name:
		"explorador":
			ability_button.text = "Revelar Carta (Custo: 3)"
		"caçador":
			ability_button.text = "Ataque Total (Consome Toda EP)"
		"arcanista":
			ability_button.text = "Barreira Mágica (Consome Toda EP)"
			
	# O botão começa desativado porque a run inicia com 0 de energia
	ability_button.disabled = true
	
# --- ATUALIZAÇÕES DE INTERFACE ---
func _on_floor_changed(new_floor: int) -> void:
	floor_label.text = "Andar: " + str(new_floor)
	
	
func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
	# Atualiza o texto
	player_hp_label.text = "Jogador: %d / %d" % [current_hp, max_hp]
	
	# Atualiza a barra
	player_hp_bar.max_value = max_hp
	player_hp_bar.value = current_hp

func _on_enemy_hp_changed(current_hp: int, max_hp: int) -> void:
	enemy_hp_label.text = current_enemy_name + ": %d / %d" % [current_hp, max_hp]
	enemy_hp_bar.max_value = max_hp
	enemy_hp_bar.value = current_hp

func _on_enemy_setup(enemy_name: String, max_hp: int, max_mp: int) -> void:
	current_enemy_name = enemy_name
	# 1. Configura o HP inicial e já coloca o nome do monstro real no lugar de "Inimigo: ?"
	enemy_hp_label.text = enemy_name + ": %d / %d" % [max_hp, max_hp]
	enemy_hp_bar.max_value = max_hp
	enemy_hp_bar.value = max_hp
	
	# 2. Configura o MP que você acabou de adicionar
	enemy_mp_label.text = "MP: " + str(max_mp)
	
func _on_energy_changed(current_energy: int) -> void:
	energy_bar.value = current_energy
	
	energy_label.text = "Energia: " + str(current_energy)
	
	if RunManager.current_player == null: 
		return
		
	var char_name = RunManager.current_player.character_name.to_lower()
	var can_use = false
	
	# Regra de validação para ativar/desativar o botão (Frontend validation)
	match char_name:
		"explorador":
			can_use = (current_energy >= 3)
			ability_button.text = "Revelar Carta" if can_use else "Carregando habilidade"
		"caçador":
			can_use = (current_energy >= 3)
			ability_button.text = "Ataque Total" if can_use else "Carregando habilidade"
		"arcanista":
			can_use = (current_energy >= 5)
			ability_button.text = "Barreira Mágica" if can_use else "Carregando habilidade"
	ability_button.disabled = not can_use
	if can_use:
		# Muda para um tom esverdeado/destacado (R, G, B)
		ability_button.modulate = Color(0.302, 0.722, 0.302, 1.0) 
	else:
		# Volta para a cor branca original (que o Godot escurece por estar disabled)
		ability_button.modulate = Color(1.0, 1.0, 1.0)



func _on_ability_button_pressed() -> void:
	# Dispara o evento global. O CombatManager vai capturar e aplicar o efeito
	SignalBus.ability_activated.emit()
	
func _on_special_charged() -> void:
	# Efeito mágico: mostra o botão
	special_button.visible = true
	special_button.scale = Vector2(0, 0)
	var tween = create_tween()
	tween.tween_property(special_button, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_ELASTIC)

func _on_special_button_pressed() -> void:
	# Avisa o CombatManager que o botão foi clicado
	SignalBus.activate_special_requested.emit()
	# Esconde o botão novamente após o uso
	special_button.visible = false
