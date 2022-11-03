extends Control

onready var ammo_container = find_node("Ammo")
onready var inventory_container = find_node("InventoryItems")
var iconSize = Vector2(32,32)

var stored_items = []

var time_elapsed : float
var last_polling_time : float
var polling_interval : float = 2.0 # seconds between checking with IO about inventory

var trigger_events = { # a few things we can test for, to see if the user already had the feedback event, so we don't repeat ourselves
	"missing_gun_reported":false,
	"found_gun":false,
}

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
		for _i in range(6):
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


func pickup_gun():
	if trigger_events["missing_gun_reported"] == false:
		$AudioClips/FoundGun.play()
		trigger_events["missing_gun_reported"] = true

func _on_collectible_picked_up(pickupObj):
	var itemResource = pickupObj.item_details
	
	#Global.pause() # why isn't this firing the second time we pick something up?

	call_deferred('rebuild_inventory') # give IO a chance to get the item first.

	stored_items.push_back(pickupObj.item_info) # store the resource with just the text strings
	
	var debugText = ""
	for item in stored_items:
		debugText += item.item_name + ", "
	find_node("DebugInfo").text = debugText

	play_specific_audio_events(itemResource.item_name)


func play_specific_audio_events(itemName:String):
	if itemName.to_lower() == "gun" and trigger_events["found_gun"] == false:
			$AudioEvents/FoundGun.play()
			trigger_events["gun_found"] = true


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
		var _err = connect("reloaded", gunObj, "_on_HUD_reloaded")
	emit_signal("reloaded", ammo_container.get_child_count())


func _on_player_gun_missing():
	if trigger_events["missing_gun_reported"] == false:
		$AudioEvents/MissingGun.play()
		trigger_events["missing_gun_reported"] = true
		
	
	