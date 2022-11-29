extends Control

onready var ammo_container = find_node("Ammo")
onready var inventory_container = find_node("InventoryItems")

var iconSize = Vector2(32,32)

var stored_items = []

var time_elapsed : float
var last_polling_time : float
var polling_interval : float = 2.0 # seconds between checking with IO about inventory

enum InventoryStates { CLOSED, OPEN }
var InventoryState = InventoryStates.CLOSED
var inventory_offset = 200
var inventory_leave_showing = 25

var death_time_remaining = 30.0

signal reloaded(count)


# Called when the node enters the scene tree for the first time.
func _ready():
	time_elapsed = 0.0
	last_polling_time = 0.0
	hide_blood_vignette()
	$ProgressBar.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.IO == null:
		return
		
	time_elapsed += delta
#	This breaks scene changes as inventory is not totally global, needs work
#	if time_elapsed > last_polling_time + polling_interval:
#
#
#		if len(stored_items) != len(Global.IO.stored_items):
#			stored_items = Global.IO.stored_items.duplicate() # IO is the ground_truth for item storage. HUD is just the display.
#			rebuild_inventory()
	if Global.controller:
		$Top/Header/HelpButton.text = "Journal[R2]"
		$Top/Header/QuitButton.text = "Quit[L2]"
		$PopupInventoryContainer/VBoxContainer/CenterContainer/InventoryButton.text = "Inventory[D-Pad Up]"
	else:
		$Top/Header/HelpButton.text = "Journal[J]"
		$Top/Header/QuitButton.text = "Quit[Q]"
		$PopupInventoryContainer/VBoxContainer/CenterContainer/InventoryButton.text = "Inventory[I]"

func _unhandled_key_input(_event):
	pass # moved to shortcut key on button
	
#	if event.is_action_pressed("open_inventory"):
#		toggle_inventory_display()
		


func remove_boss_health(amount):
	$ProgressBar.value -= amount

func toggle_inventory_display():
	if InventoryState == InventoryStates.CLOSED:
		show_inventory()
	else:
		hide_inventory()

func show_blood_vignette():
	$BloodSpatterVignette.show()
	$BloodSpatterVignette/ImminentDeathWarningLabel.hide()
func hide_blood_vignette():
	$BloodSpatterVignette.hide()

func show_inventory():
	Global.pause()
	
	$AudioEvents/BoxOpenNoise.play()
	var hidden_bottom_margin = -inventory_leave_showing
	var revealed_bottom_margin = -(inventory_offset-inventory_leave_showing)
	var tween = get_node("Tween")
	tween.interpolate_property($PopupInventoryContainer, "rect_position", Vector2(0, revealed_bottom_margin), Vector2(0,hidden_bottom_margin), 0.25, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	tween.interpolate_property($PopupInventoryContainer, "margin_bottom", revealed_bottom_margin, hidden_bottom_margin, 0.25, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	tween.interpolate_property($PopupInventoryContainer, "margin_top", hidden_bottom_margin, revealed_bottom_margin, 0.25, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)

	tween.start()
	InventoryState = InventoryStates.OPEN
	
func hide_inventory():
	Global.resume()
	
	$AudioEvents/BoxCloseNoise.play()
	var hidden_bottom_margin = -inventory_leave_showing
	var revealed_bottom_margin = -(inventory_offset-inventory_leave_showing)
	var tween = get_node("Tween")
	tween.interpolate_property($PopupInventoryContainer, "rect_position", Vector2(0,hidden_bottom_margin), Vector2(0,revealed_bottom_margin), 0.25, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	tween.interpolate_property($PopupInventoryContainer, "margin_bottom",  hidden_bottom_margin, revealed_bottom_margin, 0.25, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	tween.interpolate_property($PopupInventoryContainer, "margin_top", revealed_bottom_margin, hidden_bottom_margin, 0.25, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	tween.start()
	InventoryState = InventoryStates.CLOSED


func is_inventory_open():
	if InventoryState == InventoryStates.CLOSED:
		return false
	else:
		return true


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
	pass

	#if Global.IO.player_has_item("magazine"):
	#	Global.IO._on_collectible_used("magazine")
	#	for _i in range(6):
	#		add_bullet_icon()


func clear_inventory():
	for item in inventory_container.get_children():
		item.queue_free()
	
func display_inventory_item(itemResource : Resource):
	assert(itemResource != null)
	$PopupItemViewer.init(itemResource)

func inventory_add(itemResource : Resource):
	var iconButton = $ResourcePreloader.get_resource("InventoryIconButton").instance()
	
	iconButton.init(itemResource, self)
	iconButton.focus_mode = Control.FOCUS_NONE
	inventory_container.add_child(iconButton)
	
	#display_inventory_item(itemResource)
	
	
func journal_add(_entryName : String, _entryNotes: String):
	pass
	

func rebuild_inventory():
	clear_inventory()
	#var items = Global.IO.get_inventory()
	for item in stored_items:
		inventory_add(item)


#func pickup_gun():
#	if Global.trigger_events["missing_gun_reported"] == false:
#		$AudioClips/FoundGun.play()
#		Global.trigger_events["missing_gun_reported"] = true

func _on_collectible_picked_up(pickupObj):
	var itemResource = pickupObj.item_info
	
	#Global.pause() # why isn't this firing the second time we pick something up?

	call_deferred('rebuild_inventory') # give IO a chance to get the item first.

	stored_items.push_back(pickupObj.item_info) # store the resource with just the text strings
	
	var debugText = ""
	for item in stored_items:
		debugText += item.item_name + ", "
	find_node("DebugInfo").text = debugText

	play_specific_audio_events(itemResource.item_name)
	if itemResource["display_immediately"] == true:

		display_inventory_item(itemResource)


func play_specific_audio_events(itemName:String):
	if "gun" in itemName.to_lower() and Global.trigger_events["found_gun"] == false:
			$AudioEvents/FoundGun.play()
			Global.trigger_events["gun_found"] = true


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
	if Global.trigger_events["missing_gun_reported"] == false:
		$AudioEvents/MissingGun.play()
		Global.trigger_events["missing_gun_reported"] = true
		
func _on_missing_key():
	if Global.trigger_events["missing_tutorial_key_reported"] == false:
		$AudioEvents/MissingKey.play()
		Global.trigger_events["missing_tutorial_key_reported"] = true




func _on_boss_spawned(boss_health, boss_name):
	$ProgressBar.visible = true
	$ProgressBar.max_value = boss_health
	$ProgressBar.value = boss_health
	$ProgressBar/Label.text = boss_name



	
func _on_inventory_icon_clicked(itemRes):

	display_inventory_item(itemRes)
	

func _on_InventoryButton_toggled(_button_pressed):
	toggle_inventory_display()

#func _on_player_dying(time):
#	$BloodSpatterVignette/DeathCountdownTimer.start()

func show_dire_countdown(time_left):
	var bigCounter = $BloodSpatterVignette/ImminentDeathWarningLabel
	if time_left < 3 and time_left > 0:
		bigCounter.show()
		bigCounter.text = str(time_left)
	else:
		bigCounter.hide()


func _on_player_recovered():
	$BloodSpatterVignette/ImminentDeathWarningLabel.hide()
	$BloodSpatterVignette.hide()
	
