extends Control

# Acessa os nós usando % para ignorar a hierarquia
@onready var head_button = %HeadButton
@onready var chest_button = %ChestButton
@onready var amulet_button = %AmuletButton
@onready var weapon_button = %WeaponButton
@onready var ring_button = %RingButton
@onready var bag_grid = %BagGrid
@onready var go_to_combat_button = %GoToCombatButton


func _ready() -> void:
	# Conecta os cliques dos botões do corpo
	head_button.pressed.connect(_on_slot_clicked.bind(RelicData.EquipmentSlot.HEAD))
	chest_button.pressed.connect(_on_slot_clicked.bind(RelicData.EquipmentSlot.CHEST))
	amulet_button.pressed.connect(_on_slot_clicked.bind(RelicData.EquipmentSlot.AMULET))
	weapon_button.pressed.connect(_on_slot_clicked.bind(RelicData.EquipmentSlot.WEAPON))
	ring_button.pressed.connect(_on_slot_clicked.bind(RelicData.EquipmentSlot.RING))
	
	go_to_combat_button.pressed.connect(_on_go_to_combat_pressed)
	refresh_ui()

# Atualiza toda a tela (chamamos isso sempre que um item for movido)
func refresh_ui() -> void:
	_update_equipped_slots()
	_update_bag()

func _update_equipped_slots() -> void:
	# Atualiza o texto dos botões dependendo se há algo equipado
	_set_slot_button_ui(head_button, RelicData.EquipmentSlot.HEAD, "Cabeça")
	_set_slot_button_ui(chest_button, RelicData.EquipmentSlot.CHEST, "Torso")
	_set_slot_button_ui(amulet_button, RelicData.EquipmentSlot.AMULET, "Amuleto")
	_set_slot_button_ui(weapon_button, RelicData.EquipmentSlot.WEAPON, "Mão")
	_set_slot_button_ui(ring_button, RelicData.EquipmentSlot.RING, "Anel")

func _set_slot_button_ui(btn: Button, slot_type: RelicData.EquipmentSlot, slot_name: String) -> void:
	var item = InventoryManager.equipped_slots.get(slot_type)
	if item != null:
		btn.text = slot_name + ": " + item.relic_name
		# btn.icon = item.icon # (Descomente se tiver ícones!)
	else:
		btn.text = slot_name + ": Vazio"
		# btn.icon = null

func _update_bag() -> void:
	# 1. Limpa o grid da mochila
	for child in bag_grid.get_children():
		child.queue_free()
		
	# 2. Recria os botões baseados na mochila do InventoryManager
	for item in InventoryManager.bag:
		var btn = Button.new()
		btn.text = item.relic_name
		# btn.icon = item.icon
		
		# Conecta o clique desse botão recém-criado à função de equipar
		btn.pressed.connect(_on_bag_item_clicked.bind(item))
		bag_grid.add_child(btn)

# --- REGRAS DE INTERAÇÃO ---

func _on_slot_clicked(slot_type: RelicData.EquipmentSlot) -> void:
	# Se tem algo equipado, tira e joga na mochila
	if InventoryManager.equipped_slots.get(slot_type) != null:
		InventoryManager.unequip_slot(slot_type)
		refresh_ui()

func _on_bag_item_clicked(item: RelicData) -> void:
	# Clicou na mochila, tenta equipar
	InventoryManager.equip_item(item)
	refresh_ui()
	
func _on_go_to_combat_pressed() -> void:
	# Ao fechar a mochila, o jogador é arremessado direto para a batalha!
	get_tree().change_scene_to_file("res://scenes/Board.tscn")
