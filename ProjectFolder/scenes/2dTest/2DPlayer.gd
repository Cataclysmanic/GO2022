extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(get_global_mouse_position())
	move(delta)


func _unhandled_input(event):
	if event.is_action_pressed("flashlight"):
		toggle_flashlight()

func toggle_flashlight():
	$Flashlight.enabled = !$Flashlight.enabled
	

func move(delta):
	var speed = 150.0
	
	var move_vector = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		move_vector += Vector2.RIGHT * speed * delta
	if Input.is_action_pressed("ui_left"):
		move_vector += Vector2.UP * speed * delta
	if Input.is_action_pressed("ui_right"):
		move_vector += Vector2.DOWN * speed * delta
	if Input.is_action_pressed("ui_down"):
		move_vector += Vector2.LEFT * speed * delta
		
	var directional_vector = move_vector.rotated(rotation)
	var _collision = move_and_collide(directional_vector)
	

