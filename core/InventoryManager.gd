class_name IntentoryManager

extends Node

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

var bag: Array[RelicData] = []

var equipped_slots: Dictionary = {
	RelicData.EquipmentSlot.HEAD: null,
	RelicData.EquipmentSlot.CHEST: null,
	RelicData.EquipmentSlot.AMULET: null,
	RelicData.EquipmentSlot.RING: null,
	RelicData.EquipmentSlot.WEAPON: null
}

func _ready() -> void:
	# ATENÇÃO: Apague esta chamada quando for lançar o jogo!
	_inject_debug_items() 

func _inject_debug_items() -> void:
	# Criando um Anel
	var ring1 = RelicData.new()
	ring1.id = "anel_fogo_01"
	ring1.relic_name = "Anel de Fogo"
	ring1.slot_type = RelicData.EquipmentSlot.RING
	ring1.status_modifiers = {"damage": 5}
	bag.append(ring1)

	# Criando outro Anel (para testarmos a troca)
	var ring2 = RelicData.new()
	ring2.id = "anel_gelo_01"
	ring2.relic_name = "Anel de Gelo"
	ring2.slot_type = RelicData.EquipmentSlot.RING
	bag.append(ring2)

	# Criando um Elmo
	var head1 = RelicData.new()
	head1.id = "elmo_ferro_01"
	head1.relic_name = "Elmo de Ferro"
	head1.slot_type = RelicData.EquipmentSlot.HEAD
	bag.append(head1)

	# Criando uma Arma
	var weapon1 = RelicData.new()
	weapon1.id = "espada_enferrujada"
	weapon1.relic_name = "Espada Enferrujada"
	weapon1.slot_type = RelicData.EquipmentSlot.WEAPON
	bag.append(weapon1)
	
	print("Itens de debug injetados na mochila!")

func equip_item(item: RelicData) -> void:
	if item == null: return
	
	# Blindado com .get()
	var old_item = equipped_slots.get(item.slot_type)
	
	if old_item != null:
		bag.append(old_item)
		print("Item desequipado: ", old_item.relic_name)
		
	if bag.has(item):
		bag.erase(item)
		
	equipped_slots[item.slot_type] = item
	print("Item equipado: ", item.relic_name)

func unequip_slot(slot: RelicData.EquipmentSlot) -> void:
	# Blindado com .get()
	var item = equipped_slots.get(slot)
	
	if item != null:
		bag.append(item)
		equipped_slots[slot] = null
		print("Slot esvaziado.")
		
# Função para pegar o bônus total acumulado de um atributo específico
func get_total_modifier(modifier_name: String) -> int:
	var total = 0
	for slot in equipped_slots:
		# Pega o item usando o .get() para evitar erros
		var item: RelicData = equipped_slots.get(slot)
		
		# Se tem item e ele possui o modificador procurado, soma!
		if item != null and item.status_modifiers.has(modifier_name):
			total += item.status_modifiers[modifier_name]
			
	return total
