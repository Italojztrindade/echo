extends Control

@onready var inventory_button = %InventoryButton
@onready var start_combat_button = %StartCombatButton

func _ready() -> void:
	# Conecta os botões ao fluxo
	inventory_button.pressed.connect(_on_open_inventory)
	start_combat_button.pressed.connect(_on_start_combat)

func _on_open_inventory() -> void:
	# Carrega a cena da mochila
	get_tree().change_scene_to_file("res://scenes/InventoryScreen.tscn")

func _on_start_combat() -> void:
	# Carrega a cena do tabuleiro
	get_tree().change_scene_to_file("res://scenes/Board.tscn")
