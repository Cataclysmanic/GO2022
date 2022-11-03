extends Control

onready var ammo_container = find_node("Ammo")
onready var inventory_container = find_node("InventoryItems")
var iconSize = Vector2(32,32)

var stored_items = []

var time_elapsed : float
var last_polling_time : float
var polling_interval : float = 2.0 # seconds between checking with IO about inventory

signal reloaded(count)


# Called when the node enters the scene tree for the first time.
func _ready():
	time_elapsed = 0.0
	last_polling_time = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	if time_elapsed > last_polling_time + polling_interval:
		
		if len(stored_items) != len(Global.IO.stored_items):
			stored_items = Global.IO.stored_items.duplicate() # IO is the ground_truth for item storage. HUD is just the display.
			rebuild_inventory()

func clear_ammo_display():
	for bullet in ammo_container.get_children():
		bullet.queue_free()
	

func _on_player_gun_loaded(ammoRemaining, _ammoType):
	clear_ammo_display()
	for _i in range(ammoRemaining):
		add_bullet_icon()

func _on_player_gun_shot(ammoRemaining):
	if ammoRemaining < ammo_container.get_child_count():
		var diff = ammo_container.get_child_count() - ammoRemaining
		for _i in range(diff):
			remove_bullet_icon()
		#if ammo_container.get_child_count() == 0:
			#reload_if_possible() # let the gun request the reload

func _on_player_gun_reload_requested(gunObj):
	reload_if_possible()
	if not is_connected("reloaded", gunObj, "_on_HUD_reloaded"):
		connect("reloaded", gunObj, "_on_HUD_reloaded")
	emit_signal("reloaded", ammo_container.get_child_count())

func remove_bullet_icon():
	var last_bullet_num = ammo_container.get_child_count()-1
	var last_bullet = ammo_container.get_child(last_bullet_num)
	last_bullet.queue_free()


func add_bullet_icon():
	var bulletTex = $ResourcePreloader.get_resource("Bullet").instance()
	ammo_container.add_child(bulletTex)


func reload_if_possible():
	
	if Global.IO.has_item("magazine"):
		Global.IO._on_collectible_used("magazine")
		for i in range(6):
			add_bullet_icon()


func clear_inventory():
	for item in inventory_container.get_children():
		item.queue_free()
	
func display_inventory_item(_cutsceneImagePath : String):
	pass

func inventory_add(itemResource : Resource):
	var item = itemResource
	var textureRect = TextureRect.new()
	textureRect.rect_size = iconSize
	textureRect.rect_min_size = iconSize
	var iconTexture = load(item.path_to_icon)
	textureRect.expand = true
	textureRect.texture = iconTexture
	textureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	inventory_container.add_child(textureRect)
	
	$PopupItemViewer.init(itemResource)
	
	
func journal_add(_entryName : String, _entryNotes: String):
	pass
	

func rebuild_inventory():
	clear_inventory()
	#var items = Global.IO.get_inventory()
	for item in stored_items:
		inventory_add(item)


func _on_collectible_picked_up(pickupObj):
	
	#Global.pause() # why isn't this firing the second time we pick something up?

	call_deferred('rebuild_inventory') # give IO a chance to get the item first.

	stored_items.push_back(pickupObj.item_info) # store the resource with just the text strings
	
	var debugText = ""
	for item in stored_items:
		debugText += item.item_name + ", "
	find_node("DebugInfo").text = debugText
	
#	var itemResource = pickupObj.item_info
#
#	if pickupObj != null and is_instance_valid(pickupObj):
#		display_inventory_item(itemResource.path_to_popup_display_image)
#		inventory_add(itemResource)
		#journal_add(itemResource.item_name, pickupObj.item_info.notes_for_journal)
	
