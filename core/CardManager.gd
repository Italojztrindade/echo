extends Node

# Armazena os dados da primeira carta virada na rodada
var _first_card_data: CardData = null
var _is_processing: bool = false

func _ready() -> void:
	# O Manager escuta passivamente as ações do jogador
	SignalBus.card_flipped.connect(_on_card_flipped)

func _on_card_flipped(card_data: CardData) -> void:
	if _is_processing:
		return
		
	if _first_card_data == null:
		# É a primeira carta do par
		_first_card_data = card_data
	else:
		# É a segunda carta, precisamos validar
		_validate_pair(card_data)

func _validate_pair(second_card_data: CardData) -> void:
	_is_processing = true
	
	# Usamos um Timer nativo da SceneTree para criar um delay de 1 segundo.
	# Isso garante que o jogador veja a segunda carta antes do resultado.
	await get_tree().create_timer(1.0).timeout
	
	# Regra de Negócio: Paridade exata pelo ID
	if _first_card_data.id == second_card_data.id:
		SignalBus.pair_matched.emit(_first_card_data)
	else:
		SignalBus.pair_failed.emit()
		
	# Reseta o estado para a próxima tentativa
	_first_card_data = null
	_is_processing = false
