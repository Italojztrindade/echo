class_name CardData
extends Resource

@export var id: String
@export var card_name: String
@export var stats: CharacterStats

# Para maior segurança futuramente, "family" e "rarity" podem virar Enums
@export_category("Card Attributes")
@export var family: String 
@export var rarity: String
@export var image: Texture2D
