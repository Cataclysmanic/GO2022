extends KinematicBody

#The speed multiplier for all movement
var speed = 2.0 # added delta to movement code, for consistent speeds across different framerates
#The last direction moved, used for animation (Can be used for accelleration as well)
var lastDir = 1
#Determines which view mode we are in. Currently tied to input.
var point = 0
var lastPoint = 0
#Determines whether during full Global.topdown mode, if we follow the mouse or controller input 
#for direction info
var mouse = true
#during Global.topdown mode, multiply the speed by this number
var tDpwnMul = 1.5

var flashlight = false

var HUD : Control

signal gun_missing()



# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_gun_if_carried()
	

	if get_parent().is_in_group("Indoor"):
		$Camera.set_projection(Camera.PROJECTION_ORTHOGONAL)
		$Camera.size = 3
	if get_parent().is_in_group("Outdoor"):
		$Camera.set_projection(Camera.PROJECTION_PERSPECTIVE)
		$Camera.fov = 50

	HUD = get_hud()


func spawn_gun_if_carried():
	if Global.IO == null: # escape in case we're testing detective without the full game
		return
	elif Global.IO.has_item("gun"): # gun already in inventory. spawn a gun object on the player avatar
		spawn_item(Global.IO.get_item("Gun"))
	
	var gun = find_node("Gun")
	if is_instance_valid(gun):
		gun.init(self, 6)

	

func get_hud():
	return find_node("HUD")



		
		
func toggle_disguise():
	#currently just an input in future triggered by an item or doable only in specific locations(?)
	if self.is_in_group("goodPeople"):
		self.remove_from_group("goodPeople")
		self.add_to_group("badPeople")
		$AnimatedSprite.modulate = Color(1,0,0,1)
	else:
		self.remove_from_group("badPeople")
		self.add_to_group("goodPeople")
		$AnimatedSprite.modulate = Color(0,1,0,1)


func shoot_gun():
	if carrying_item_already("Gun"):
		var gun = locate_item("gun")
		if gun != null and gun.has_method("shoot"):
			gun.shoot()
		else:
			printerr("something's wrong in Detective3d, related to shooting the gun in _unhandled_input()")
	else:
		if not is_connected("gun_missing", HUD, "_on_player_gun_missing"):
			var _err = connect("gun_missing", HUD, "_on_player_gun_missing")
		emit_signal("gun_missing")


func toggle_flashlight():
	
	flashlight = !flashlight
	$AnimatedSprite/Items/Flashlight.visible = flashlight	


func locate_item(itemName):
	var gun = null
	for item in $AnimatedSprite/Items.get_children():
		if itemName.to_lower() in item.name.to_lower():
			gun = item
	return gun


func carrying_item_already(itemName):
	var found = false
	var itemContainer = find_node("Items")
	for item in itemContainer.get_children():
		if itemName.to_lower() in item.name.to_lower():
			found = true
	return found


func _unhandled_input(event): # ie: clicking anywhere but on the GUI
	if Global.is_paused():
		return
	
	if event.is_action("shoot") and event.is_action_pressed("shoot"):
		shoot_gun()


	if event.is_action_pressed("ui_disguise"):
		toggle_disguise()

	if event.is_action_pressed("flashlight") and carrying_item_already("flashlight"):
		toggle_flashlight()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Global.world_controller != null:
		if Global.is_paused():
			return
	
	
	if !Global.topdown:
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
	#If the 'accept' button is pressed, this changes the view mode to Global.topdown
	if Input.is_action_just_pressed("ui_accept"):
		Global.topdown = !Global.topdown
		$AnimatedSprite.animation = "wiSide"
	#if the 'select' button is pressed, change between mouse use and controller use.
	if Input.is_action_just_pressed("ui_select"):
		mouse = !mouse


	#if mouse is controlling the direction, get and point towards the current mouse position on screen
	if mouse:
		point = -$Camera.unproject_position(self.transform.origin).angle_to_point(get_viewport().get_mouse_position())
	else: #otherwise, get the input vector on the controller for looking.
		point = -Input.get_vector("lookLeft", "lookRight", "lookUp", "lookDown").angle()
		point = point - PI
	if Global.topdown:
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
	
	var vel = dir.normalized() * speed * delta
	var _collision = move_and_collide(vel)

func _on_collectible_picked_up(itemObj):
	var itemResource = itemObj.item_details
	var itemName = itemResource.item_name
	if itemResource.is_unique and carrying_item_already(itemResource.item_name):
		return
	else:
		spawn_item(itemResource)


func spawn_item(itemResource): # This method doesn't care if you ought to have the item or not.
	var itemName = itemResource.item_name
	var loader = $ResourcePreloader	
	if loader.get_resource_list().has(itemResource.item_name):			
		var itemScene = loader.get_resource(itemResource.item_name).instance()
		if itemName == "Gun":
			itemScene.init(self, 6)
			itemScene.name = "Gun"
		if itemName == "Flashlight":
			itemScene.name = "Flashlight"
		var itemsContainer = find_node("Items")
		itemsContainer.add_child(itemScene)
		
