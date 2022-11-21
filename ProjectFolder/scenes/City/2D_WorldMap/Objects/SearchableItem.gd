extends Node2D

var player_present : bool = false

enum States { READY, EMPTY }
var State = States.READY

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_node("InteractionLabel"):
		$InteractionLabel.set_global_rotation(0)
		$InteractionLabel.hide()

	disable_possible_items()


func _unhandled_input(event):
	if player_present and State != States.EMPTY:
		if event.is_action_pressed("interact"):
			$AudioStreamPlayer2D.play()
			spawn_loot()
			State = States.EMPTY


func disable_possible_items():
	for itemTemplate in $PossibleItems.get_children():
		if itemTemplate.has_method("disable_pickup"):
			itemTemplate.disable_pickup()
				

func spawn_loot():
	var possibleItems = $PossibleItems.get_children()
	var item = possibleItems[randi()%possibleItems.size()].duplicate()

	get_parent().add_child(item)
	item.set_global_position(get_global_position())
	item.set_global_scale(Vector2(1.5,1.5))
	item.visible = true
	item.enable_pickup()
	




func _on_InteractionArea_body_entered(body):
	if body.has_method("is_player") and body.is_player():
		player_present = true
		if has_node("InteractionLabel") and State != States.EMPTY:
			$InteractionLabel.show()
	


func _on_InteractionArea_body_exited(body):
	if body.has_method("is_player") and body.is_player():
		player_present = false
		if has_node("InteractionLabel"):
			$InteractionLabel.hide()
		
