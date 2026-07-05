extends Node

var current_player: PlayerData = null
var current_player_hp: int = 0
var current_floor: int = 1

# Banco de dados de inimigos para a run. 
# Adicione os caminhos corretos dos seus arquivos .tres de inimigos.
var _enemy_pool: Array[Resource] = [
	preload("res://data/slime_data.tres"),
	preload("res://data/goblin_data.tres")
	# preload("res://data/goblin_data.tres"), etc...
]

func _ready() -> void:
	# Escuta quando o combate atual terminar
	SignalBus.enemy_defeated.connect(_on_enemy_defeated)

# Método chamado pela tela de seleção para inicializar a sessão
func start_new_run(player_data: PlayerData) -> void:
	current_player = player_data
	current_player_hp = player_data.max_hp
	CombatManager.reset_combat_state()
	current_floor = 1
	
	get_tree().change_scene_to_file("res://scenes/PreparationScreen.tscn")

# Retorna o inimigo do andar atual (faz um loop na lista se chegarmos ao fim)
func get_current_enemy() -> EnemyData:
	if _enemy_pool.size() == 0:
		return null
	
	var index = (current_floor - 1) % _enemy_pool.size()
	return _enemy_pool[index] as EnemyData

func _on_enemy_defeated() -> void:
	current_floor += 1
	print("Inimigo derrotado! Avançando para o andar ", current_floor)
	
	# Aguarda um breve momento para o jogador ver o inimigo morrer, depois recarrega a sala
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()
	
func reset_run() -> void:
	current_floor = 1
	current_player = null
	current_player_hp = 0
	print("Estado da Run resetado para uma nova jornada.")
