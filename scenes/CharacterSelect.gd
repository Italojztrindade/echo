class_name CharacterSelect
extends Control

# Injeção dos DTOs via Inspector
@export var characters: Array[PlayerData]

@onready var btn_explorer: Button = $HBoxContainer/BtnExplorer
@onready var btn_arcanist: Button = $HBoxContainer/BtnArcanist
@onready var btn_hunter: Button = $HBoxContainer/BtnHunter

func _ready() -> void:
	# Conecta os botões via código. Assumindo a ordem: [0] Explorer, [1] Arcanist, [2] Hunter
	btn_explorer.pressed.connect(func(): _select_character(characters[0]))
	btn_arcanist.pressed.connect(func(): _select_character(characters[1]))
	btn_hunter.pressed.connect(func(): _select_character(characters[2]))
	
	# Preenche o texto dos botões com base nos dados reais
	btn_explorer.text = characters[0].character_name + "\n" + characters[0].passive_description
	btn_arcanist.text = characters[1].character_name + "\n" + characters[1].passive_description
	btn_hunter.text = characters[2].character_name + "\n" + characters[2].passive_description

func _select_character(selected_data: PlayerData) -> void:
	print("Iniciando Run com: ", selected_data.character_name)
	# O RunManager agora cuida de setar as variáveis e trocar de cena
	RunManager.start_new_run(selected_data)
