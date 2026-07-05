extends Node

# Estado do Jogador
var _player_data: PlayerData
var _player_current_hp: int = 0
var _current_energy: int = 0


# Estado do Inimigo
var _current_enemy_data: EnemyData
var _enemy_current_hp: int = 0

# Dano base do jogador ao acertar um par (pode ser alterado por relíquias/afinidade depois)
var _base_player_damage: int = 10 

# --- ESTADO DAS PASSIVAS ---
var _is_hunter: bool = false
var _combo_count: int = 0
var _hunter_energy_consumed: int = 0
var _arcanist_shield_active: bool = false

var _ability_used_this_turn: bool = false # NOVO: Trava de habilidade
var _has_special_stored: bool = false # O jogador tem um especial guardado?
var _special_active_this_turn: bool = false # Ele apertou o botão NESTE turno?2

# Estados temporários das habilidades ativas
var _last_resolved_turn_id: int = -1
# NOVO: A trava absoluta contra "ecos" e turnos duplos
var _processing_turn: bool = false


func _ready() -> void:
	# Blindagem contra o bug do "Turno Duplo" (Impede conexões duplicadas na memória)
	if not SignalBus.pair_matched.is_connected(_on_pair_matched):
		SignalBus.pair_matched.connect(_on_pair_matched)
		
	if not SignalBus.pair_failed.is_connected(_on_pair_failed):
		SignalBus.pair_failed.connect(_on_pair_failed)
		
	if not SignalBus.ability_activated.is_connected(_activate_ability):
		SignalBus.ability_activated.connect(_activate_ability)
		
	# Conexões do botão de Especial e do Tabuleiro Limpo
	if not SignalBus.activate_special_requested.is_connected(_on_activate_special_requested):
		SignalBus.activate_special_requested.connect(_on_activate_special_requested)
		
	if not SignalBus.board_cleared.is_connected(_on_board_cleared):
		SignalBus.board_cleared.connect(_on_board_cleared)
# --- INICIALIZAÇÃO DO COMBATE ---

# O RunManager chamará isso quando a run começar ou trocar de sala
func start_combat(player: PlayerData, enemy: EnemyData) -> void:
	_player_data = player
	_current_enemy_data = enemy
	
	_player_current_hp = RunManager.current_player_hp
	_enemy_current_hp = _current_enemy_data.hp
	# Inicializa HP (se for início de run. Se for entre salas, o HP do jogador é mantido)
	if _player_current_hp == 0:
		_player_current_hp = _player_data.max_hp
		
	_configure_passives()
	print("Combate Iniciado: ", player.character_name, " vs ", enemy.enemy_name)
	
	SignalBus.floor_changed.emit(RunManager.current_floor)
	# Atualiza a UI inicial
	
	SignalBus.energy_changed.emit(_current_energy)
	SignalBus.player_hp_changed.emit(_player_current_hp, _player_data.max_hp)
	SignalBus.enemy_hp_changed.emit(_enemy_current_hp, _current_enemy_data.hp)

# --- REGRAS DE NEGÓCIO ---
func _configure_passives() -> void:
	pass
			
func _on_pair_matched(_card_data: CardData) -> void:
	if _processing_turn: 
		return
	_processing_turn = true
	if _current_enemy_data != null and _enemy_current_hp > 0:
		_gain_energy(1)
		_deal_damage_to_enemy(_base_player_damage)
		print("Sucesso! Processou apenas MATCH.")
		
	# Espera a engine virar para o próximo frame (milissegundos) e então destrava
	await get_tree().process_frame
	_processing_turn = false
	_ability_used_this_turn = false

func _on_pair_failed() -> void:
	# BLINDAGEM: Compartilha a mesma trava para os erros
	if _processing_turn: 
		return
	_processing_turn = true
	
	if _current_enemy_data != null and _enemy_current_hp > 0:
		_gain_energy(1)
		_deal_damage_to_player(_current_enemy_data.damage)
		print("Erro! Processou apenas FAIL.")
		
	# Destrava no próximo frame
	await get_tree().process_frame
	_processing_turn = false
	_ability_used_this_turn = false

func reset_combat_state() -> void:
	_current_energy = 0
	_hunter_energy_consumed = 0
	_arcanist_shield_active = false


# --- GERENCIAMENTO DE ENERGIA ---
func _gain_energy(amount: int) -> void:
	_current_energy += amount
	SignalBus.energy_changed.emit(_current_energy)
	print("Energia recuperada! Atual: ", _current_energy)

func _consume_energy(amount: int) -> void:
	_current_energy -= amount
	if _current_energy < 0: _current_energy = 0
	SignalBus.energy_changed.emit(_current_energy)
	
# --- PROCESSAMENTO DE DANO ---

func _deal_damage_to_enemy(amount: int) -> void:
	var final_damage = amount
	
	var bonus_damage = InventoryManager.get_total_modifier("damage")
	final_damage += bonus_damage
	# 1. Aplica modificadores (Habilidade do Caçador)
	if _hunter_energy_consumed > 0:
		var multiplicador = 1.0 + (float(_hunter_energy_consumed) * 0.1)
		final_damage = int(amount * multiplicador)
		_hunter_energy_consumed = 0 # Reseta o multiplicador
		print("Ataque do Caçador! Multiplicador: x", multiplicador, " | Dano Final: ", final_damage)
	if _special_active_this_turn:
		final_damage *= 2
		_special_active_this_turn = false # Consome a ativação após o golpe
		print("CRÍTICO ESPECIAL APLICADO! Dano dobrado!")
	# 2. Subtrai o HP real e trava no zero
	_enemy_current_hp -= final_damage
	_enemy_current_hp = max(0, _enemy_current_hp)
	
	print("Inimigo recebeu ", final_damage, " de dano. HP restante: ", _enemy_current_hp)
	SignalBus.enemy_hp_changed.emit(_enemy_current_hp, _current_enemy_data.hp)
	
	# 3. Verifica morte
	if _enemy_current_hp <= 0:
		_win_battle()
		RunManager.current_player_hp = _player_current_hp
		SignalBus.enemy_defeated.emit()
	else:
		pass

func _deal_damage_to_player(amount: int) -> void:
	var final_damage = amount
	
	# 1. Aplica modificadores defensivos (Habilidade do Arcanista)
	if _arcanist_shield_active:
		_arcanist_shield_active = false # Escudo quebra após um uso
		
		if _current_enemy_data.get("is_boss") == true:
			final_damage = int(amount / 2.0)
			print("A Barreira resistiu, mas o Chefe quebrou parte dela! Dano final: ", final_damage)
		else:
			final_damage = 0
			print("A Barreira do Arcanista bloqueou 100% do ataque do lacaio!")
			
	# 2. Subtrai o HP real e trava no zero
	_player_current_hp -= final_damage
	_player_current_hp = max(0, _player_current_hp)
	
	print("Jogador recebeu ", final_damage, " de dano. HP restante: ", _player_current_hp)
	SignalBus.player_hp_changed.emit(_player_current_hp, _player_data.max_hp)
	
	# 3. Verifica Game Over
	if _player_current_hp == 0:
		print("Game Over!")
		SignalBus.game_over.emit()

func _on_activate_special_requested() -> void:
	if _has_special_stored and not _special_active_this_turn:
		_has_special_stored = false
		_special_active_this_turn = true
		print("[Habilidade] Especial ativado! O próximo acerto neste turno causará Dano x2.")
		
func _activate_ability() -> void:
	if _player_data == null: return
	
	if _ability_used_this_turn:
		print("Habilidade bloqueada: Já foi utilizada neste turno!")
		return
	# Transforma o nome para minúsculas para evitar erros de digitação (ex: "Arcanista" -> "arcanista")
	var char_name = _player_data.character_name.to_lower()
	var ability_successfully_used = false
	
	match char_name:
		"explorador":
			if _current_energy >= 3:
				_consume_energy(3)
				SignalBus.flips_allowed_this_turn = 3
				ability_successfully_used = true
				print("[Habilidade] Explorador ativado: 3 cartas permitidas neste turno!")
				
		"caçador":
			if _current_energy >= 3: # Atualizado para 3
				_hunter_energy_consumed = _current_energy
				_consume_energy(_current_energy)
				ability_successfully_used = true
				print("[Habilidade] Caçador preparou ataque crítico de x", _hunter_energy_consumed)
				
		"arcanista":
			if _current_energy >= 5:
				_consume_energy(5)
				_arcanist_shield_active = true
				ability_successfully_used = true
				print("[Habilidade] Arcanista ativou a barreira mágica!")
				
	if ability_successfully_used:
		_ability_used_this_turn = true

# --- MÉTODOS PÚBLICOS (Para Relíquias e Afinidade) ---

func _on_board_cleared() -> void:
	_has_special_stored = true
	SignalBus.special_charged.emit() # Avisa a UI para fazer o botão brilhar/ficar clicável
	print("Especial Carregado! Pode ser usado a qualquer momento.")
# O AffinityManager pode chamar isso quando bater 8 pontos (+20% de dano, por exemplo)
func apply_damage_multiplier(multiplier: float) -> void:
	_base_player_damage = int(_base_player_damage * (1.0 + multiplier))
	print("Dano base do jogador alterado para: ", _base_player_damage)
	
	
# --- LÓGICA DE FIM DE BATALHA ---

func _win_battle() -> void:
	print("Batalha Vencida! Gerando Loot...")
	
	# 1. Gera o Loot e joga na mochila
	_generate_loot()
	
	# 2. (Opcional) Reseta variáveis de estado do combate para a próxima luta
	# ex: _special_active_this_turn = false
	
	# 3. Retorna para a tela de preparação
	# Usamos call_deferred para o Godot terminar os cálculos do frame atual antes de destruir a cena, evitando crashes!
	call_deferred("_return_to_preparation")

func _return_to_preparation() -> void:
	# ATENÇÃO: Confirme se o caminho bate com o da sua cena
	get_tree().change_scene_to_file("res://scenes/PreparationScreen.tscn")

func _generate_loot() -> void:
	# Para este MVP, vamos forjar um item aleatório simples e injetar no Autoload
	var new_loot = RelicData.new()
	
	# Usamos randi() para gerar um número aleatório e fingir que é um drop dinâmico
	new_loot.id = "loot_" + str(randi() % 1000) 
	
	# Sorteia se o item será uma Arma ou um Anel
	if randi() % 2 == 0:
		new_loot.relic_name = "Espada do Saqueador"
		new_loot.slot_type = RelicData.EquipmentSlot.WEAPON
		new_loot.status_modifiers = {"damage": 4}
	else:
		new_loot.relic_name = "Anel da Sobrevivência"
		new_loot.slot_type = RelicData.EquipmentSlot.RING
		new_loot.status_modifiers = {"max_hp": 10}
		
	new_loot.is_permanent = false # Regra que definimos: descarta no fim da run
	
	# O Autoload recebe o item
	InventoryManager.bag.append(new_loot)
	print("Loot Dropado! ", new_loot.relic_name, " adicionado à mochila.")
