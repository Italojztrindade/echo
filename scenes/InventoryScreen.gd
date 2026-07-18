extends Control

# Acessa os nós usando % para ignorar a hierarquia
@onready var head_button = %HeadButton
@onready var chest_button = %ChestButton
@onready var amulet_button = %AmuletButton
@onready var weapon_button = %WeaponButton
@onready var ring_button = %RingButton
@onready var bag_grid = %BagGrid
@onready var back_button = %BackButton
@onready var player_stats_label = %PlayerStatsLabel
@onready var item_description_label = %ItemDescriptionLabel


func _ready() -> void:
	# 1. Conecta os cliques dos botões de equipamento
	head_button.pressed.connect(_on_slot_clicked.bind(RelicData.EquipmentSlot.HEAD))
	chest_button.pressed.connect(_on_slot_clicked.bind(RelicData.EquipmentSlot.CHEST))
	amulet_button.pressed.connect(_on_slot_clicked.bind(RelicData.EquipmentSlot.AMULET))
	weapon_button.pressed.connect(_on_slot_clicked.bind(RelicData.EquipmentSlot.WEAPON))
	ring_button.pressed.connect(_on_slot_clicked.bind(RelicData.EquipmentSlot.RING))
	
	# 2. Conecta o botão de voltar
	back_button.pressed.connect(_on_back_button_pressed)
	
	# 3. Conecta o "Passar o mouse" (Hover) nos botões equipados
	head_button.mouse_entered.connect(func(): _on_slot_hovered(RelicData.EquipmentSlot.HEAD))
	chest_button.mouse_entered.connect(func(): _on_slot_hovered(RelicData.EquipmentSlot.CHEST))
	amulet_button.mouse_entered.connect(func(): _on_slot_hovered(RelicData.EquipmentSlot.AMULET))
	weapon_button.mouse_entered.connect(func(): _on_slot_hovered(RelicData.EquipmentSlot.WEAPON))
	ring_button.mouse_entered.connect(func(): _on_slot_hovered(RelicData.EquipmentSlot.RING))
	
	# 4. Conecta o "Tirar o mouse" nos botões equipados
	head_button.mouse_exited.connect(_on_item_unhovered)
	chest_button.mouse_exited.connect(_on_item_unhovered)
	amulet_button.mouse_exited.connect(_on_item_unhovered)
	weapon_button.mouse_exited.connect(_on_item_unhovered)
	ring_button.mouse_exited.connect(_on_item_unhovered)

	_on_item_unhovered() # Define o texto padrão do painel
	refresh_ui()

# --- ATUALIZAÇÃO DA INTERFACE ---
func refresh_ui() -> void:
	_update_equipped_slots()
	_update_bag()
	_update_player_stats() # <--- Agora os status atualizam toda vez que você mexe em um item!

func _update_equipped_slots() -> void:
	_set_slot_button_ui(head_button, RelicData.EquipmentSlot.HEAD, "Cabeça")
	_set_slot_button_ui(chest_button, RelicData.EquipmentSlot.CHEST, "Torso")
	_set_slot_button_ui(amulet_button, RelicData.EquipmentSlot.AMULET, "Amuleto")
	_set_slot_button_ui(weapon_button, RelicData.EquipmentSlot.WEAPON, "Mão")
	_set_slot_button_ui(ring_button, RelicData.EquipmentSlot.RING, "Anel")

func _set_slot_button_ui(btn: Button, slot_type: RelicData.EquipmentSlot, slot_name: String) -> void:
	var item = InventoryManager.equipped_slots.get(slot_type)
	if item != null:
		btn.text = slot_name + ": " + item.relic_name
	else:
		btn.text = slot_name + ": Vazio"

func _update_bag() -> void:
	for child in bag_grid.get_children():
		child.queue_free()
		
	for item in InventoryManager.bag:
		var btn = Button.new()
		btn.text = item.relic_name
		
		btn.pressed.connect(_on_bag_item_clicked.bind(item))
		
		# Adiciona a função de hover para as cartas geradas na mochila!
		btn.mouse_entered.connect(_on_item_hovered.bind(item))
		btn.mouse_exited.connect(_on_item_unhovered)
		
		bag_grid.add_child(btn)

# --- SISTEMA DE STATUS E DESCRIÇÕES ---

func _update_player_stats() -> void:
	var player = RunManager.current_player
	if player == null: return
	
	# Puxa os totais atuais fornecidos pelos equipamentos
	var bonus_atk = InventoryManager.get_total_modifier("damage")
	var bonus_def = InventoryManager.get_total_modifier("defense")
	var bonus_luck = InventoryManager.get_total_modifier("luck") if InventoryManager.has_method("get_total_modifier") else 0

	# Monta o texto mostrando o Base + o Bônus
	var text = "STATUS \n\n"
	
	text += "HP Máx: %d \n" % player.stats.max_hp
	
	text += "\nAtaque: %d " % player.stats.base_attack
	if bonus_atk > 0: text += "(+%d)\n" % bonus_atk
	else: text += "\n"
	
	text += "\nDefesa: %d " % player.stats.base_defense
	if bonus_def > 0: text += "(+%d)\n" % bonus_def
	else: text += "\n"
	
	text += "\nSorte: %d " % player.stats.base_luck
	if bonus_luck > 0: text += "(+%d)\n" % bonus_luck
	else: text += ""
	
	text += "\n\nOuro: %d" % player.current_gold
	
	if player_stats_label != null:
		player_stats_label.text = text

func _on_slot_hovered(slot_type: RelicData.EquipmentSlot) -> void:
	var item = InventoryManager.equipped_slots.get(slot_type)
	if item != null:
		_on_item_hovered(item)
	else:
		_on_item_unhovered()

func _on_item_hovered(item: RelicData) -> void:
	if item_description_label != null:
		# Nota: Se o seu arquivo RelicData.gd tiver nomes de variáveis diferentes,
		# troque o "modifier_value" e "modifier_type" pelos nomes corretos abaixo!
		var desc = item.description if "description" in item else "Uma relíquia misteriosa."
		var mod_val = item.modifier_value if "modifier_value" in item else 0
		var mod_type = item.modifier_type if "modifier_type" in item else "Status"
		
		item_description_label.text = "[ %s ]\n\n%s\n\nBônus: +%d de %s" % [item.relic_name, desc, mod_val, mod_type]

func _on_item_unhovered() -> void:
	if item_description_label != null:
		item_description_label.text = "Passe o mouse sobre um item para ver os detalhes."

# --- REGRAS DE INTERAÇÃO ---

func _on_slot_clicked(slot_type: RelicData.EquipmentSlot) -> void:
	if InventoryManager.equipped_slots.get(slot_type) != null:
		InventoryManager.unequip_slot(slot_type)
		refresh_ui()

func _on_bag_item_clicked(item: RelicData) -> void:
	InventoryManager.equip_item(item)
	refresh_ui()
	
func _on_back_button_pressed() -> void:
	# Agora volta para o Acampamento invés de puxar o combate!
	get_tree().change_scene_to_file("res://scenes/PreparationScreen.tscn")
