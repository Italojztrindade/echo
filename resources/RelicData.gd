class_name RelicData
extends Resource

enum EquipmentSlot {
	HEAD,      # Cabeça
	CHEST,     # Torso
	AMULET,    # Pescoço
	RING,      # Dedos
	WEAPON     # Mãos
}

@export_category("Basic Info")
@export var id: String
@export var relic_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var slot_type: EquipmentSlot = EquipmentSlot.RING

@export_category("Attribute Modifiers")
# Para buffs de status acumulativos (ex: {"damage": 5, "max_hp": 20})
@export var status_modifiers: Dictionary = {}

@export_category("Effect Configuration (RN)")
# Para regras de negócio complexas e habilidades passivas
@export var effect_type: String 
@export var effect_value: float

# A mágica da meta-progressão acontece aqui:
@export var is_permanent: bool = false
