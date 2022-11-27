extends KinematicBody


var speed = 1.5
var sprint_multiple = 3.0
var last_movement_vector = Vector3.ZERO # to know when to switch animations.. only on transitions

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _unhandled_input(event):
	if event.is_action_pressed("flashlight"):
		toggle_flashlight()


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

	var total_movement = movement_vector * speed * sprint
	var _collision = move_and_collide(total_movement * delta * Global.game_speed)
	play_movement_animations(total_movement)
	last_movement_vector = total_movement

func play_movement_animations(movement_vector:Vector3):
	var paperDoll = $"3DPaperDoll"
	paperDoll.point_legs_at(movement_vector)
	if movement_vector > last_movement_vector:
		if Input.is_action_pressed("shift"):
			paperDoll.start_running()
		else:
			paperDoll.start_walking()
	elif movement_vector < last_movement_vector:
		if movement_vector.length_squared() > 0:
			paperDoll.start_walking()
		else:
			paperDoll.relax()


func toggle_flashlight():
	if $Flashlight.is_visible_in_tree():
		$Flashlight.hide()
		$"3DPaperDoll".relax()
	else:
		$Flashlight.show()
		$"3DPaperDoll".point_gun()
		
	
	
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
		var targetPos = intersection.position
		#$Flashlight.look_at(Vector3(targetPos.x, 0, targetPos.z), Vector3(0,1,0))
		$Flashlight.look_at(targetPos, Vector3(0,1,0))
		
		$"3DPaperDoll".point_torso_at(Vector3(targetPos.x, 0.0, targetPos.z))
