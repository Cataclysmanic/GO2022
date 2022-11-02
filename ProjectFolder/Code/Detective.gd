extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 2
var lastDir = 0
var topDown = "w"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dir = Vector2.ZERO
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_just_pressed("ui_accept"):
		if topDown == "w":
			topDown = "t"
		elif topDown == "t":
			topDown = "w"
	
	if dir.x != 0:
		if dir.x == 1:
			$AnimatedSprite.animation = topDown + "Side"
			$AnimatedSprite.flip_h = true
			lastDir = 1
		if dir.x == -1:
			$AnimatedSprite.animation = topDown + "Side"
			$AnimatedSprite.flip_h = false
			lastDir = 2
	elif dir.y == 1:
		$AnimatedSprite.animation = topDown + "Down"
		lastDir = 3
	elif dir.y == -1:
		$AnimatedSprite.animation = topDown + "Up"
		lastDir = 4
	else:
		match lastDir:
			1:
				$AnimatedSprite.animation = topDown + "iSide"
				$AnimatedSprite.flip_h = true
			2:
				$AnimatedSprite.animation = topDown + "iSide"
				$AnimatedSprite.flip_h = false
			3:
				$AnimatedSprite.animation = topDown + "iDown"
			4:
				$AnimatedSprite.animation = topDown + "iUp"
			_:
				print('Something went wrong with animation')
	
	var vel = dir * speed
	move_and_collide(vel)
