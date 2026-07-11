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


@export_category("Passive Skill")
# Identificador único. Ex: "explorer", "arcanist", "hunter"
@export var passive_id: String 
@export_multiline var passive_description: String
