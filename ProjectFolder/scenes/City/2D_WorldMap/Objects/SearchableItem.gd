extends Node2D
tool # just to allow the configuration warning about child nodes

var player_present : bool = false

var collectables = []


enum States { READY, EMPTY }
var State = States.READY

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): # running in inspector
		return
	else: # running in-game
		if has_node("InteractionLabel"):
			$InteractionLabel.set_global_rotation(0)
			$InteractionLabel.hide()
		
		build_collectibles_list_from_children()
		
func build_collectibles_list_from_children():
		for child in get_children():
			if child.has_method("enable_pickup") and child.has_method("disable_pickup"):
				child.disable_pickup()
				child.hide()
				collectables.push_back(child)
				
		if collectables.size() == 0:
			var defaultLoot = $ResourcePreloader.get_resource("Bandage").instance()
			defaultLoot.disable_pickup()
			collectables.push_back(defaultLoot)
			
		#disable_possible_items()
	
	

func _get_configuration_warning():
	var found = false
	for child in get_children():
		if child.has_method("enable_pickup") and child.has_method("disable_pickup"):
			found = true
	if found:
		return ""
	else:
		return "Add 2DCollectablePickup.tscn instances as children"


func _unhandled_input(event):
	if Engine.is_editor_hint(): # running in inspector
		return
	if Global.controller:
		$InteractionLabel/PressF.text = "[Triangle/Y/X]"
	else:
		$InteractionLabel/PressF.text = "[F]"

	if player_present and State != States.EMPTY:
		if event.is_action_pressed("interact"):
			$AudioStreamPlayer2D.play()
			$InteractionLabel.hide()
			spawn_loot()
			State = States.EMPTY


#func disable_possible_items():
#	#for itemTemplate in $PossibleItems.get_children():
#	for itemTemplate in collectables:
#		if itemTemplate.has_method("disable_pickup"):
#			itemTemplate.disable_pickup()
				

func spawn_loot():
	var item = collectables[randi()%collectables.size()].duplicate()

	get_parent().add_child(item)
	item.set_global_position(get_global_position())
	item.set_global_scale(Vector2(1.5,1.5))
	item.visible = true
	item.enable_pickup()
	




func _on_InteractionArea_body_entered(body):
	if Engine.is_editor_hint(): # running in inspector
		return

	if body.has_method("is_player") and body.is_player():
		player_present = true
		if has_node("InteractionLabel") and State != States.EMPTY:
			$InteractionLabel.show()
	


func _on_InteractionArea_body_exited(body):
	if Engine.is_editor_hint(): # running in inspector
		return
	if body.has_method("is_player") and body.is_player():
		player_present = false
		if has_node("InteractionLabel"):
			$InteractionLabel.hide()
		
