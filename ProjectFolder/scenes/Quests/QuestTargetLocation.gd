# Should be able to:

# provide it's address and some tips about locating it.
# Actual quest objects will be provided by the NPC (at this time)
	# so the location doesn't know what the object will be.

# quest objects will carry their own area2d collision shape for detection/discovery

extends Position2D


# export var location_name : String = "Blue Residence, kitchen" # don't really need this
export var location_address : String = "123 Main St"
export var location_details : String = "The blue building on the southwest corner of the block."



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#func get_name():
#	return location_name
	
func get_address():
	return location_address
	
func get_details():
	return location_details
	
func spawn_quest_object(questObject):
	questObject.position = Vector2.ZERO
	add_child(questObject)
	# ^ does this make sense? Should it be a child of the city map instead?
	
	
