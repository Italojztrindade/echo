class_name EnemyData
extends Resource

@export var id: String
@export var enemy_name: String
@export var is_boss: bool = false

@export_category("Combat Attributes")
@export var hp: int
@export var damage: int

# Skill pode referenciar o id de uma habilidade ou um tipo enumerado para o EnemyManager processar
@export var skill: String
