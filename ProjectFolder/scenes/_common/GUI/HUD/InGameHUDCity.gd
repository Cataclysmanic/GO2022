extends Control

onready var ammo_container = find_node("Ammo")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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


func remove_bullet_icon():
	var last_bullet_num = ammo_container.get_child_count()-1
	var last_bullet = ammo_container.get_child(last_bullet_num)
	last_bullet.queue_free()


func add_bullet_icon():
	var bulletTex = $ResourcePreloader.get_resource("Bullet").instance()
	ammo_container.add_child(bulletTex)

func display_inventory_item(_image : Texture):
	pass

func inventory_add(_image: Texture, _name: String):
	pass
	
func journal_add(_entryName : String, _entryNotes: String):
	pass
	
	
func _on_collectible_picked_up(pickupObj):
	

	if pickupObj != null and is_instance_valid(pickupObj):
	
		display_inventory_item(pickupObj.image_to_display_on_pickup)
		inventory_add(pickupObj.icon_for_inventory, pickupObj.item_name)
		journal_add(pickupObj.item_name, pickupObj.notes_for_journal)
	
