extends Node

var current_player: PlayerData = null
var current_player_hp: int = 0
var has_special_stored: bool = false
var current_floor: int = 0

# --- POOLS DE INIMIGOS POR DIFICULDADE ---
# Preload garante que o arquivo já esteja carregado na memória para evitar travamentos na hora de instanciar

var tier_1_enemies: Array[Resource] = [
	preload("res://data/slime_card.tres"),
	preload("res://data/morcego_card.tres")
]

var tier_2_enemies: Array[Resource] = [
	preload("res://data/aranha_card.tres"),
	preload("res://data/goblin_card.tres"),
	preload("res://data/zumbi_card.tres")
]

var tier_3_enemies: Array[Resource] = [
	preload("res://data/lobo_card.tres"),
	preload("res://data/esqueleto_card.tres")
]

var tier_4_enemies: Array[Resource] = [
	preload("res://data/orc_card.tres"),
	preload("res://data/troll_card.tres")
]

var boss_enemy: Resource = preload("res://data/ogro_card.tres")

func _ready() -> void:
	# Escuta quando o combate atual terminar
	SignalBus.enemy_defeated.connect(_on_enemy_defeated)

# Método chamado pela tela de seleção para inicializar a sessão
func start_new_run(player_data: PlayerData) -> void:
	current_player = player_data.duplicate(true)
	current_player_hp = player_data.stats.max_hp
	CombatManager.reset_combat_state()
	current_floor = 0
	
	get_tree().change_scene_to_file("res://scenes/PreparationScreen.tscn")

func get_next_enemy() -> Resource:
	var pool_to_use: Array[Resource] = []
	
	# Mapeamento dos andares para a dificuldade correspondente
	if current_floor <= 2:
		pool_to_use = tier_1_enemies
	elif current_floor <= 4:
		pool_to_use = tier_2_enemies
	elif current_floor <= 6:
		pool_to_use = tier_3_enemies
	elif current_floor == 7:
		pool_to_use = tier_4_enemies
	else:
		# Andar 8 (ou maior) é o Boss garantido!
		print("Andar final alcançado! Invocando o Boss.")
		return boss_enemy 
		
	# Sorteia um índice aleatório dentro do tamanho da pool escolhida
	var random_index = randi() % pool_to_use.size()
	var sorted_enemy = pool_to_use[random_index]
	
	print("Andar ", current_floor, " gerado. Inimigo sorteado: ", sorted_enemy.resource_path)
	
	return sorted_enemy
# Retorna o inimigo do andar atual (faz um loop na lista se chegarmos ao fim)

func _on_enemy_defeated() -> void:
	print("Inimigo derrotado! Retornando ao Acampamento...")
	
	# Retorna o jogador para a Sala de Preparação (onde ele escolhe se avança ou repete)
	get_tree().change_scene_to_file("res://scenes/PreparationScreen.tscn")
	
func reset_run() -> void:
	current_floor = 1
	current_player = null
	current_player_hp = 0
	print("Estado da Run resetado para uma nova jornada.")
