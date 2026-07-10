@icon("res://assets/Frente.png")
extends Resource
class_name CharacterStats

# Definimos os valores base. O @export permite editar direto no Inspetor!
@export var max_hp: int = 20
@export var base_attack: int = 5
@export var base_defense: int = 0
@export var base_luck: int = 5 # Representa % de chance de crítico
@export var max_mp: int = 5

# Função utilitária para facilitar se precisarmos duplicar/clonar status no futuro
func get_clone() -> CharacterStats:
	var clone = CharacterStats.new()
	clone.max_hp = self.max_hp
	clone.base_attack = self.base_attack
	clone.base_defense = self.base_defense
	clone.base_luck = self.base_luck
	clone.max_mp = self.max_mp
	return clone
