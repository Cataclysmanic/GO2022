extends KinematicBody

#The speed multiplier for all movement
var speed = .05
#The last direction moved, used for animation (Can be used for accelleration as well)
var lastDir = 1
#Determines which view mode we are in. Currently tied to input.
var topDown = true
#While in full topdown mode, this is where the viewpoint is
var point = 0
var lastPoint = 0
#Determines whether during full topdown mode, if we follow the mouse or controller input 
#for direction info
var mouse = true
#during topdown mode, multiply the speed by this number
var tDpwnMul = 1.5

var flashlight = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var gun = find_node("Gun")
	if is_instance_valid(gun):
		gun.init(self, 6)

	if get_parent().is_in_group("Indoor"):
		$Camera.set_projection(Camera.PROJECTION_ORTHOGONAL)
		$Camera.size = 3
	if get_parent().is_in_group("Outdoor"):
		$Camera.set_projection(Camera.PROJECTION_PERSPECTIVE)
		$Camera.fov = 50
func get_hud():
	return find_node("HUD")


func _unhandled_input(event):
	if event.is_action("shoot") and event.is_action_pressed("shoot"):
	#if Input.is_action_just_pressed("shoot"):
		for item in $AnimatedSprite/Items.get_children():
			if item.has_method("shoot"):
				item.shoot()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !topDown:
		mouse = true
	#Zero out the vector for controlling direction.
	var dir = Vector3.ZERO
	#Get inputs here. dir, being a vector, has an x and y axis. 
	#This maps inputs for movement onto those axis'
	if mouse:
		if Input.is_action_pressed("ui_down"):
			dir.z += 1
		if Input.is_action_pressed("ui_up"):
			dir.z -= 1
		if Input.is_action_pressed("ui_right"):
			dir.x += 1
		if Input.is_action_pressed("ui_left"):
			dir.x -= 1
	else:
		dir.z = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").y
		dir.x = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").x
	#If the 'accept' button is pressed, this changes the view mode to topdown
	if Input.is_action_just_pressed("ui_accept"):
		topDown = !topDown
		$AnimatedSprite.animation = "wiSide"
	#if the 'select' button is pressed, change between mouse use and controller use.
	if Input.is_action_just_pressed("ui_select"):
		mouse = !mouse

	if Input.is_action_just_pressed("flashlight"):
		flashlight = !flashlight
	
	
	$AnimatedSprite/Items/Flashlight.visible = flashlight	
	#if mouse is controlling the direction, get and point towards the current mouse position on screen
	if mouse:
		point = -$Camera.unproject_position(self.transform.origin).angle_to_point(get_viewport().get_mouse_position())
	else: #otherwise, get the input vector on the controller for looking.
		point = -Input.get_vector("lookLeft", "lookRight", "lookUp", "lookDown").angle()
		point = point - PI
	if topDown:
		$AnimatedSprite.scale.x = .5
		$AnimatedSprite.scale.y = .5
		self.rotation_degrees.x = -90
		if point != -PI:
			$AnimatedSprite.rotation.z = point
			lastPoint = point
		else:
			$AnimatedSprite.rotation.z = lastPoint
		if dir.x == 0 and dir.y == 0:
			$AnimatedSprite.animation = "tIdle"
		else:
			$AnimatedSprite.animation = "tWalk"
		dir = dir * tDpwnMul
	else:
		self.rotation_degrees.x = -70
		$AnimatedSprite.scale.x = 1
		$AnimatedSprite.scale.y = 1
		$AnimatedSprite.rotation.z = 0
		if dir.x != 0:
			if dir.x == 1:
				$AnimatedSprite.animation = "wSide"
				$AnimatedSprite.flip_h = true
				lastDir = 1
			if dir.x == -1:
				$AnimatedSprite.animation = "wSide"
				$AnimatedSprite.flip_h = false
				lastDir = 2
		elif dir.z == 1:
			$AnimatedSprite.animation = "wDown"
			lastDir = 3
		elif dir.z == -1:
			$AnimatedSprite.animation = "wUp"
			lastDir = 4
		else:
			match lastDir:
				1:
					$AnimatedSprite.animation = "wiSide"
					$AnimatedSprite.flip_h = true
				2:
					$AnimatedSprite.animation = "wiSide"
					$AnimatedSprite.flip_h = false
				3:
					$AnimatedSprite.animation = "wiDown"
				4:
					$AnimatedSprite.animation = "wiUp"
				_:
					print('Something went wrong with animation')
	
	var vel = dir.normalized() * speed
	var _collision = move_and_collide(vel)


func _on_collectible_picked_up(_collectibleObj):
	# player avatar has little interest in items, 
		# unless we want to give then a sprite
		# or put some new functionality inside $Items
	# otherwise Let Global.world_controller.IO and HUD figure this out
	pass
	
	
