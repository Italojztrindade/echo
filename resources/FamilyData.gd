class_name FamilyData
extends Resource

@export var family_name: String

# Dicionário de recompensas. 
# Chave (int): Pontos necessários. Valor (String): ID do efeito.
# Exemplo no Inspector: { 3: "gold_5", 5: "reveal_card", 8: "damage_buff_20" }
@export var affinity_thresholds: Dictionary
