extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	var zoom_rate = 1.2
	if event.is_action_pressed("zoom_out"):
		set_zoom(get_zoom()*zoom_rate)
	elif event.is_action_pressed("zoom_in"):
		set_zoom(get_zoom()*(1/zoom_rate))
		
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
