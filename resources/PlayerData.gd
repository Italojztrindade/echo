class_name PlayerData
extends Resource

@export var id: String
@export var character_name: String
@export_multiline var description: String

@export_category("Base Stats")
@export var stats: CharacterStats
@export var current_level: int = 1
@export var current_xp: int = 0
@export var xp_required_for_next_level: int = 100
@export var unspent_stat_points: int = 5
@export var current_gold: int = 0

@export_category("Passive Skill")
# Identificador único. Ex: "explorer", "arcanist", "hunter"
@export var passive_id: String 
@export_multiline var passive_description: String


func add_xp(amount: int) -> void:
	current_xp += amount
	print("Recebeu %d de XP! (Total: %d/%d)" % [amount, current_xp, xp_required_for_next_level])
	
	# Usa um 'while' caso o jogador ganhe muita XP de uma vez e suba 2 níveis seguidos
	while current_xp >= xp_required_for_next_level:
		_level_up()

func add_gold(amount: int) -> void:
	current_gold += amount
	print("Encontrou %d de Ouro! (Total: %d)" % [amount, current_gold])
	
func _level_up() -> void:
	current_level += 1
	current_xp -= xp_required_for_next_level
	unspent_stat_points += 3 # O jogador ganha 3 pontos por nível (ajuste como quiser!)
	
	# Aumenta a dificuldade do próximo nível em 20%
	xp_required_for_next_level = int(xp_required_for_next_level * 1.2)
	
	print("\n*** LEVEL UP! ***")
	print("Herói alcançou o Nível %d!" % current_level)
	print("Pontos disponíveis para distribuir: %d\n" % unspent_stat_points)
