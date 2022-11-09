# Work in progress.
# - trying to create prefabs we can use as volume triggers.
# - eg: cross a threshold and NPCs become hostile
# need to figure out what kind of trigger events should exist, and how best to handle them. 


extends Spatial


export var requires_item: bool # need a key? or a specific paper? or something else?
export var item_name : String
export var requires_faction : bool # only opens for goodPeople, or badPeople, or someOtherFaction?
export var faction_name : String

export var broadcast_to_group : bool # if trigger volumes should trigger each other, you can put them in the same group
export var group_name : String
export var group_broadcast_args : Array

export var area_currently_enabled : bool = true



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):

	var conditions_met = true
	if requires_faction:
		if not body.is_in_group(faction_name):
			conditions_met = false
			
	if requires_item:
		if not body.has_method("is_carrying") or body.is_carrying(item_name) == false:
			conditions_met = false
			
	if conditions_met:
		if broadcast_to_group:
			get_tree().call_group(group_name, "_on_broadcast_received", group_broadcast_args)
			

func _on_broadcast_received():
	pass
	#Now what?
	
	# sample ideas:
	# light switch activates a light.  -- why not just make a switched_light object with a common root?
	# some event triggers NPCs.
		# player crosses a threshold, if conditions_met, nearby NPCs turn hostile.
	
