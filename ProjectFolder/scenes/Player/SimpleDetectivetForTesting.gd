extends KinematicBody


var speed = 1.5
var sprint_multiple = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	var movement_vector = Vector3.ZERO
	if Input.is_action_pressed("ui_down"):
		movement_vector += Vector3.BACK
	if Input.is_action_pressed("ui_up"):
		movement_vector += Vector3.FORWARD
	if Input.is_action_pressed("ui_right"):
		movement_vector += Vector3.RIGHT
	if Input.is_action_pressed("ui_left"):
		movement_vector += Vector3.LEFT

	var sprint = sprint_multiple
	if not Input.is_action_pressed("sprint"):
		sprint = 1.0

	var _collision = move_and_collide(movement_vector * speed * sprint * delta)
	
