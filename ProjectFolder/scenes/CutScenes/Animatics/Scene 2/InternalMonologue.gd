extends Control


enum States { PLAYING, DONE }
var State = States.PLAYING

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$BGMusic.play()
	$AnimationPlayer.play("ReadDocument")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var scroll = find_node("ScrollContainer")
	scroll.update()
	$DebugInfo.text = str(scroll.scroll_vertical)
	
	if State == States.DONE:
		$CursorSprite.position = get_local_mouse_position()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ReadDocument":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var to_pos = $CursorSprite.position
		get_viewport().warp_mouse(to_pos)
		$CursorSprite.position = get_local_mouse_position()

		State = States.DONE
