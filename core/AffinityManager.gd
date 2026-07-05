extends Node

# Banco de dados de todas as famílias disponíveis no jogo
# (Isso será injetado ou carregado dinamicamente no futuro)
var _active_families: Dictionary = {}

# Mantém o estado dos pontos atuais na run. Ex: {"Goblin": 5}
var _current_affinity_points: Dictionary = {}

func _ready() -> void:
	SignalBus.pair_matched.connect(_on_pair_matched)
	# Em um cenário real, você carregaria os .tres da pasta data/ aqui
	# Para testes, vamos carregar sob demanda ou via injeção no RunManager futuramente.

func _on_pair_matched(card_data: CardData) -> void:
	var family: String = card_data.family
	
	if family.is_empty():
		return
		
	# Inicializa os pontos se for a primeira vez
	if not _current_affinity_points.has(family):
		_current_affinity_points[family] = 0
		
	# Incrementa 1 ponto por par encontrado
	_current_affinity_points[family] += 1
	var points: int = _current_affinity_points[family]
	
	print("Afinidade [", family, "] -> ", points, " pontos.")
	
	_evaluate_thresholds(family, points)

func _evaluate_thresholds(family_name: String, points: int) -> void:
	# Previne erros caso a família não esteja registrada no banco de dados
	if not _active_families.has(family_name):
		return
		
	var family_data: FamilyData = _active_families[family_name]
	
	# Verifica se os pontos atuais atingiram alguma meta no Dicionário da família
	if family_data.affinity_thresholds.has(points):
		var reward_id: String = family_data.affinity_thresholds[points]
		print(">> META ATINGIDA! Família ", family_name, " ativou recompensa: ", reward_id)
		SignalBus.affinity_threshold_reached.emit(family_name, points)
		_process_reward(reward_id)

func _process_reward(reward_id: String) -> void:
	# Aqui no futuro criaremos um RewardManager ou faremos o parse da String
	match reward_id:
		"gold_5":
			print("Efeito: +5 de Ouro")
		"reveal_card":
			print("Efeito: Revelando uma carta")
		"damage_buff_20":
			print("Efeito: +20% de Dano")
		_:
			print("Efeito desconhecido: ", reward_id)

# Método utilitário para registrar as famílias (O GameManager usará isso)
func register_family(data: FamilyData) -> void:
	if data and not data.family_name.is_empty():
		_active_families[data.family_name] = data
