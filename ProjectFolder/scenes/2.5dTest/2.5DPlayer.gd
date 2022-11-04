extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	aim_flashlight()
	flip_player_sprite()
	move(delta)

func aim_flashlight():
	var mousePos = get_global_mouse_position()
	$Flashlight.look_at(mousePos)


func flip_player_sprite():
	var mousePos = get_global_mouse_position()
	var myPos = self.get_global_position()
	var flip = (myPos > mousePos)
	$PlayerSprite.set_flip_h(flip)
	

func _unhandled_input(event):
	if event.is_action_pressed("flashlight"):
		toggle_flashlight()

func toggle_flashlight():
	$Flashlight.enabled = !$Flashlight.enabled
	

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
	

