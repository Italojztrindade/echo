class_name PlayerData
extends Resource

@export var id: String
@export var character_name: String
@export_multiline var description: String


@export_category("Base Stats")
@export var max_hp: int
@export var max_energy: int

@export_category("Passive Skill")
# Identificador único. Ex: "explorer", "arcanist", "hunter"
@export var passive_id: String 
@export_multiline var passive_description: String
