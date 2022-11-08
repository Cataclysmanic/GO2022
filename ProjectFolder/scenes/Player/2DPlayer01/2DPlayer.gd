extends KinematicBody2D


var last_movement_vector = Vector2.ZERO
var sprint_velocity_multiple = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$PaperDoll.relax()
	

func _process(delta):
	move(delta)
	$Flashlight.look_at(get_global_mouse_position())


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
	if Input.is_action_pressed("sprint"):
		speed *= sprint_velocity_multiple

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
	play_animations(directional_vector)
	last_movement_vector = directional_vector
	
	
func play_animations(movement_vector):
	var currentSpeedSq = movement_vector.length_squared()
	var previousSpeedSq = last_movement_vector.length_squared()
	
	var faster_than_before = currentSpeedSq > previousSpeedSq
	var slower_than_before = previousSpeedSq > currentSpeedSq
	
	if faster_than_before:
		if Input.is_action_pressed("sprint"):
			$PaperDoll.start_running()
		else:
			$PaperDoll.start_walking()
	elif slower_than_before:
		
		if movement_vector != Vector2.ZERO:
			$PaperDoll.start_walking()
		else:
			$PaperDoll.relax()
	
func _on_collectible_picked_up(pickupObj):
	pass # don't really care yet. Inventory and IO can hash this out between them.
	

	
	
