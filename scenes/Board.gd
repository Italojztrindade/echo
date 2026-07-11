class_name Board
extends Control

# Injeção das dependências via Inspector
@export var card_scene: PackedScene
@export var card_back_image: Texture2D

# Nossa lista base de entidades que participarão da rodada
@export var deck_data: Array[CardData]
@export var available_card_types: Array[CardData]
var _flipped_cards: Array[Node] = []
var _matched_pairs: int = 0

signal board_cleared() # Emitido quando o jogador acerta o último par
@onready var grid_container = %GridContainer

func _ready() -> void:
	SignalBus.force_reveal_random_card.connect(_on_force_reveal_random_card)
	SignalBus.is_board_locked = false
	SignalBus.current_flips = 0
	SignalBus.game_over.connect(_on_game_over)
	SignalBus.card_flipped.connect(_on_card_flipped)
	
	# Consome o jogador salvo no State global
	_initialize_board()
	# 2. Cria um timer assíncrono de 2 segundos e ESPERA ele terminar
	await get_tree().create_timer(2.0).timeout
	
	# 3. Passa por todas as cartas criadas e manda elas virarem para baixo ao mesmo tempo
	for card in grid_container.get_children():
		if card.has_method("hide_card"):
			card.hide_card()
	SignalBus.is_board_locked = false
	# Consome o estado dinâmico do RunManager
	var enemy = RunManager.get_next_enemy()
	
	if RunManager.current_player != null and enemy != null:
		CombatManager.start_combat(RunManager.current_player, enemy)
		print("Andar ", RunManager.current_floor, " iniciado contra ", enemy.card_name)
	else:
		push_warning("Atenção: Falha ao carregar estado da Run.")
		

func _initialize_board() -> void:
	_matched_pairs = 0
	# Limpa o grid caso seja um recarregamento de fase
	for child in grid_container.get_children():
		child.queue_free()
		
	var selected_cards: Array[CardData] = []
	var pairs_needed = 8 # 8 pares = 16 cartas (Grid 4x4)
	
	# Clona a lista original para podermos embaralhar sem alterar os dados base
	var pool = available_card_types.duplicate()
	pool.shuffle()
	
	# Pega até 8 cartas diferentes do pool
	for i in range(min(pairs_needed, pool.size())):
		var card_data = pool[i]
		selected_cards.append(card_data) # Primeira carta do par
		selected_cards.append(card_data) # Segunda carta do par
		
	# Embaralha os pares finais para que as cartas iguais não fiquem juntas
	selected_cards.shuffle()
	
	# Instancia as cartas fisicamente no GridContainer
	for card_data in selected_cards:
		var card_instance = card_scene.instantiate() as CardView
		card_instance.data = card_data
		grid_container.add_child(card_instance)
func _on_force_reveal_random_card() -> void:
	var available_cards = []
	
	# Passa por todas as cartas instanciadas no grid
	for card in grid_container.get_children():
		# IMPORTANTE: Adapte 'is_flipped' e 'is_matched' para os nomes exatos 
		# das variáveis que você usa no seu script Card.gd
		if card.has_method("hide_card") and not card.is_flipped and not card.is_matched:
			available_cards.append(card)
			
	if available_cards.size() > 0:
		var random_card = available_cards.pick_random()
		
		# Adapte '_on_pressed()' para o nome exato da função que vira a carta no seu Card.gd
		random_card._on_pressed() 
		print("Carta revelada pela passiva do Explorador!")

func _on_card_flipped(card_node: Node) -> void:
	if SignalBus.is_board_locked or _flipped_cards.has(card_node):
		return
		
	_flipped_cards.append(card_node)
	
	# Verifica se já virou o máximo permitido para ESTE turno
	if _flipped_cards.size() == SignalBus.flips_allowed_this_turn:
		SignalBus.is_board_locked = true
		
		await get_tree().create_timer(1.0).timeout
		_resolve_turn()
		
		if not is_inside_tree():
			return
		
		_flipped_cards.clear()
		SignalBus.flips_allowed_this_turn = 2 
		
		SignalBus.current_flips = 0
		await get_tree().create_timer(0.3).timeout
		
		if not is_inside_tree():
			return
			
		if _matched_pairs >= 8:
			_reload_board_mid_combat()
		else:
			SignalBus.is_board_locked = false
		

func _reload_board_mid_combat() -> void:
	print("Tabuleiro limpo! Recarregando cartas...")
	# Deixa a trava = true (não deixa o jogador clicar em nada)
	SignalBus.board_cleared.emit()
	
	# Espera 1 segundo pro jogador comemorar a última carta antes de sumir tudo
	await get_tree().create_timer(1.0).timeout 
	
	_initialize_board()
	
	await get_tree().create_timer(2.0).timeout
	for card in grid_container.get_children():
		if card.has_method("hide_card"):
			card.hide_card()
			
	SignalBus.is_board_locked = false
	
func _resolve_turn() -> void:
	var match_found = false
	var matched_data: CardData = null
	
	if _flipped_cards.size() >= 2:
		for i in range(_flipped_cards.size()):
			for j in range(i + 1, _flipped_cards.size()):
				# 2. Na hora da regra de negócio, olhamos o ID dos dados DENTRO da peça!
				if _flipped_cards[i].data.id == _flipped_cards[j].data.id:
					match_found = true
					matched_data = _flipped_cards[i].data # Salva o dado para emitir o dano
					break
			if match_found: break
		
	if match_found:
		_matched_pairs += 1
		SignalBus.pair_matched.emit(matched_data)
	else:
		SignalBus.pair_failed.emit()
		
	SignalBus.clear_unmatched_cards.emit()
	
func _on_game_over() -> void:
	# Carrega a cena na memória e cria uma instância dela (como um Modal)
	var game_over_modal = preload("res://scenes/GameOver.tscn").instantiate()
	
	# Adiciona essa instância por cima de tudo no tabuleiro atual
	add_child(game_over_modal)
