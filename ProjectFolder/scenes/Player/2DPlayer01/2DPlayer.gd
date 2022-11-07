extends KinematicBody2D





# Called when the node enters the scene tree for the first time.
func _ready():
	$PaperDoll.relax()
	

func _process(delta):
	move(delta)


func _unhandled_input(event):
	if event.is_action_pressed("flashlight"):
		toggle_flashlight()

func toggle_flashlight():
	var is_enabled = !$Flashlight.enabled
	$Flashlight.enabled = is_enabled
	if is_enabled:
		$PaperDoll.point_gun()
	else:
		$PaperDoll.relax()


func move(delta):
	var style = "ortho"
	
	var speed = 150.0
	
	var move_vector = Vector2.ZERO
	var directional_vector = Vector2.ZERO
	
	if style == "orbit":
		if Input.is_action_pressed("ui_up"):
			move_vector += Vector2.RIGHT * speed * delta
		if Input.is_action_pressed("ui_left"):
			move_vector += Vector2.UP * speed * delta
		if Input.is_action_pressed("ui_right"):
			move_vector += Vector2.DOWN * speed * delta
		if Input.is_action_pressed("ui_down"):
			move_vector += Vector2.LEFT * speed * delta
		directional_vector = move_vector.rotated(rotation)
	elif style == "ortho":
		if Input.is_action_pressed("ui_up"):
			move_vector += Vector2.UP * speed * delta
		if Input.is_action_pressed("ui_left"):
			move_vector += Vector2.LEFT * speed * delta
		if Input.is_action_pressed("ui_right"):
			move_vector += Vector2.RIGHT * speed * delta
		if Input.is_action_pressed("ui_down"):
			move_vector += Vector2.DOWN * speed * delta
		directional_vector = move_vector

	var _collision = move_and_collide(directional_vector)
	

