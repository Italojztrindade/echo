class_name CardView
extends TextureButton

@export var data: CardData
@export var card_back_texture: Texture2D  # Imagem das costas da carta
@export var card_front_texture: Texture2D # Imagem da frente (A moldura vazia)

@onready var icon: TextureRect = $Icon # Referência ao nó filho que criamos

var is_flipped: bool = false
var is_matched: bool = false

func _ready() -> void:
	# Nasce mostrando a moldura frontal e o ícone do monstro
	texture_normal = card_front_texture
	is_flipped = true # Começa marcada como virada para cima
	
	if data != null:
		icon.texture = data.image
		icon.show()
	
	SignalBus.clear_unmatched_cards.connect(_on_clear_unmatched_cards)
	SignalBus.pair_matched.connect(_on_pair_matched)
	pressed.connect(_on_pressed)
	
func hide_card() -> void:
	is_flipped = false
	texture_normal = card_back_texture
	icon.hide()
	
func _on_pressed() -> void:
	# 1. Checagens básicas de estado
	if is_flipped or is_matched or SignalBus.is_board_locked:
		return
	if SignalBus.current_flips >= SignalBus.flips_allowed_this_turn:
		return
		
	# 3. Passou na catraca? Registra o clique!
	SignalBus.current_flips += 1
	
	# 4. Vira visualmente
	is_flipped = true
	# (mantenha os nomes das variáveis de textura que você já usa no seu projeto)
	texture_normal = card_front_texture 
	icon.show()
	
	# 5. Avisa o tabuleiro
	SignalBus.card_flipped.emit(self)
	SignalBus.card_flipped.emit(self)

func _on_pair_failed() -> void:
	if is_flipped and not is_matched:
		is_flipped = false
		# Esconde o monstro e volta a textura para as costas
		texture_normal = card_back_texture 
		icon.hide()

func _on_pair_matched(matched_data: CardData) -> void:
	if data != null and data.id == matched_data.id:
		is_matched = true

func _on_clear_unmatched_cards() -> void:
	# Fecha apenas se estiver virada para cima, mas NÃO for um par válido
	if is_flipped and not is_matched:
		is_flipped = false
		texture_normal = card_back_texture 
		icon.hide()
