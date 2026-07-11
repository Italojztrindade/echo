extends Control

@onready var inventory_button = %InventoryButton
@onready var start_combat_button = %StartCombatButton

# atributos
@onready var title_label = $VBoxContainer/TitleLabel
@onready var level_info_label = %LevelInfoLabel
@onready var btn_upgrade_hp = %BtnUpgradeHP
@onready var btn_upgrade_atk = %BtnUpgradeATK
@onready var btn_upgrade_def = %BtnUpgradeDEF
@onready var btn_upgrade_luck = %BtnUpgradeLUCK
@onready var repeat_floor_button = %RepeatFloorButton

func _ready() -> void:
	# Conecta os botões ao fluxo
	inventory_button.pressed.connect(_on_open_inventory)
	start_combat_button.pressed.connect(_on_advance_floor)
	repeat_floor_button.pressed.connect(_on_repeat_floor)
	
	btn_upgrade_hp.pressed.connect(func(): _upgrade_stat("hp"))
	btn_upgrade_atk.pressed.connect(func(): _upgrade_stat("atk"))
	btn_upgrade_def.pressed.connect(func(): _upgrade_stat("def"))
	btn_upgrade_luck.pressed.connect(func(): _upgrade_stat("luck"))
	_update_ui()
	
func _update_ui() -> void:
	var player = RunManager.current_player
	var boss_floor = 8
	if player == null: return
	
	title_label.text = "Acampamento - " + player.character_name
	
	# Mostra o Nível e a XP
	level_info_label.text = "Nível: %d | XP: %d/%d | Pontos: %d" % [
		player.current_level, player.current_xp, player.xp_required_for_next_level, player.unspent_stat_points
	]
	
	# Mostra quanto ele tem daquele status atualmente no botão
	btn_upgrade_hp.text = "+ HP Máx (" + str(player.stats.max_hp) + ")"
	btn_upgrade_atk.text = "+ Ataque (" + str(player.stats.base_attack) + ")"
	btn_upgrade_def.text = "+ Defesa (" + str(player.stats.base_defense) + ")"
	btn_upgrade_luck.text = "+ Sorte (" + str(player.stats.base_luck) + ")"
	
	# Trava os botões se ele não tiver pontos para gastar
	var can_upgrade = player.unspent_stat_points > 0
	btn_upgrade_hp.disabled = !can_upgrade
	btn_upgrade_atk.disabled = !can_upgrade
	btn_upgrade_def.disabled = !can_upgrade
	btn_upgrade_luck.disabled = !can_upgrade
	
	if RunManager.current_floor == 0:
		# Acabou de iniciar a run. Não há o que repetir.
		repeat_floor_button.visible = false
		start_combat_button.text = "Iniciar Jornada (Andar 1)"
		start_combat_button.modulate = Color(1, 1, 1)
		
	elif RunManager.current_floor >= boss_floor:
		# Andar do Boss
		repeat_floor_button.visible = false
		start_combat_button.text = "Enfrentar o Chefe!"
		start_combat_button.modulate = Color(0.9, 0.2, 0.2)
		
	else:
		# Andares normais (1 ao 7)
		repeat_floor_button.visible = true
		start_combat_button.text = "Avançar para Andar " + str(RunManager.current_floor + 1)
		start_combat_button.modulate = Color(1, 1, 1)
		
	if RunManager.current_floor >= boss_floor:
		# Se for o andar do Boss, esconde o botão de repetir
		repeat_floor_button.visible = false
		
		# (Opcional) Muda o texto do botão principal para dar um clima épico
		start_combat_button.text = "Enfrentar o Chefe!"
		start_combat_button.modulate = Color(0.9, 0.2, 0.2) # Deixa o botão vermelho
	else:
		repeat_floor_button.visible = true
		start_combat_button.text = "Avançar para o Combate"
		start_combat_button.modulate = Color(1, 1, 1) # Cor original
	
# Função responsável por gastar o ponto e aumentar o status
func _upgrade_stat(stat_type: String) -> void:
	var player = RunManager.current_player
	
	# Proteção dupla
	if player.unspent_stat_points <= 0: return
	
	# Gasta 1 ponto
	player.unspent_stat_points -= 1
	
	# Aplica o bônus dependendo de onde ele clicou
	match stat_type:
		"hp":
			player.stats.max_hp += 5 # HP sobe de 5 em 5
			RunManager.current_player_hp += 5 # Já cura o jogador na hora também!
		"atk":
			player.stats.base_attack += 10
		"def":
			player.stats.base_defense += 10
		"luck":
			player.stats.base_luck += 1
			
	# Atualiza a tela para refletir a compra
	_update_ui()
func _on_open_inventory() -> void:
	# Carrega a cena da mochila
	get_tree().change_scene_to_file("res://scenes/InventoryScreen.tscn")

func _on_start_combat() -> void:
	# Carrega a cena do tabuleiro
	get_tree().change_scene_to_file("res://scenes/Board.tscn")
	
func _on_advance_floor() -> void:
	RunManager.current_floor += 1 # Sobe o andar apenas aqui!
	get_tree().change_scene_to_file("res://scenes/Board.tscn")


func _on_repeat_floor() -> void:
	# Não soma nada no current_floor, apenas recarrega o combate
	get_tree().change_scene_to_file("res://scenes/Board.tscn")
