extends Control

@onready var floor_label: Label = %FloorLabel
@onready var restart_button: Button = %RestartButton

func _ready() -> void:
	# Exibe até onde o jogador chegou usando o estado global
	floor_label.text = "Você sucumbiu no Andar: " + str(RunManager.current_floor)
	
	# Conecta o clique do botão
	restart_button.pressed.connect(_on_restart_button_pressed)

func _on_restart_button_pressed() -> void:
	# 1. Reseta o estado global da Run
	RunManager.reset_run()
	
	# 2. Reseta o estado do Combate (Energia, escudos, etc.)
	CombatManager.reset_combat_state()
	
	# 3. Volta para a tela de Seleção de Personagem
	get_tree().change_scene_to_file("res://scenes/CharacterSelect.tscn")
