extends Line2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func near_player():
	var proximity_sq = 1000 * 1000
	var npcPos = get_parent().global_position
	var playerPos = Global.player.global_position
	if npcPos.distance_squared_to(playerPos) < proximity_sq:
		return true
	else:
		return false
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not near_player():
		hide()
	else:
		show()
		set_global_rotation(0)
		set_global_position(Vector2.ZERO)
