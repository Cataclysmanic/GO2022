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
	
func _physics_process(_delta):
	
	point_flashlight_at_mouse()
	
func point_flashlight_at_mouse():
	var ray_length = 3000

	#gettign the current phyisics state
	var space_state = get_world().direct_space_state
	#getting the current mouse position
	var mouse_position = get_viewport().get_mouse_position()
	var rayOrigin = $Camera.project_ray_origin(mouse_position)
	var rayEnd = rayOrigin + $Camera.project_ray_normal(mouse_position) * ray_length
	var intersection = space_state.intersect_ray(rayOrigin, rayEnd)

	if not intersection.empty():
		var pos = intersection.position
		$Flashlight.look_at(Vector3(pos.x, 0, pos.z), Vector3(0,1,0))
		#mesh.rotate_y(deg2rad(180))
