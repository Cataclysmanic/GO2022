extends Sprite


const SPEED = 1500.0

func _process(delta):
#	var vec = get_viewport().get_mouse_position() - self.position # getting the vector from self to the mouse
#	vec = vec.normalized() * delta * SPEED # normalize it and multiply by time and speed
#	position += vec # move by that vector
	var mousePos = get_viewport().get_mouse_position()
	var myPos = get_position()
	#var normalVec = myPos.direction_to(mousePos)
	set_position(lerp(myPos, mousePos, 0.8))


func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		$Camera2D.zoom -= Vector2(0.1, 0.1)
	elif event.is_action_pressed("zoom_out"):
		$Camera2D.zoom += Vector2(0.1, 0.1)
		
