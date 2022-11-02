extends KinematicBody2D



#The speed multiplier for all movement
var speed = 2
#The last direction moved, used for animation (Can be used for accelleration as well)
var lastDir = 0
#Determines which view mode we are in. Currently tied to input.
var topDown = true
#While in full topdown mode, this is where the viewpoint is
var point = 0
#Determines whether during full topdown mode, if we follow the mouse or controller input 
#for direction info
var mouse = true
#during topdown mode, multiply the speed by this number
var tDpwnMul = 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Zero out the vector for controlling direction.
	var dir = Vector2.ZERO
	#Get inputs here. dir, being a vector, has an x and y axis. 
	#This maps inputs for movement onto those axis'
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	#If the 'accept' button is pressed, this changes the view mode to topdown
	if Input.is_action_just_pressed("ui_accept"):
		topDown = !topDown
		$AnimatedSprite.animation = "wiSide"
	#if the 'select' button is pressed, change between mouse use and controller use.
	if Input.is_action_just_pressed("ui_select"):
		mouse = !mouse
		print(mouse)
	
	#if mouse is controlling the direction, get and point towards the current mouse position on screen
	if mouse:
		point = get_viewport().get_mouse_position()
	else: #otherwise, get the input vector on the controller for looking.
		point = $AnimatedSprite.global_position + Input.get_vector("lookLeft", "lookRight", "lookUp", "lookDown")
	
	if topDown:
		$AnimatedSprite.look_at(point)
		if dir.x == 0 and dir.y == 0:
			$AnimatedSprite.animation = "tIdle"
		else:
			$AnimatedSprite.animation = "tWalk"
		dir = dir * tDpwnMul
	else:
		$AnimatedSprite.rotation = 0
		if dir.x != 0:
			if dir.x == 1:
				$AnimatedSprite.animation = "wSide"
				$AnimatedSprite.flip_h = true
				lastDir = 1
			if dir.x == -1:
				$AnimatedSprite.animation = "wSide"
				$AnimatedSprite.flip_h = false
				lastDir = 2
		elif dir.y == 1:
			$AnimatedSprite.animation = "wDown"
			lastDir = 3
		elif dir.y == -1:
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
	
	var vel = dir * speed
	move_and_collide(vel)
