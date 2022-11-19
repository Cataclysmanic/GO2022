extends KinematicBody
var type = null 
var navAgent : NavigationAgent
var velocity = Vector3()
var triggered = false
var ready = false

func _ready():
	if self.is_in_group("goodPeople"):
		type = 1
	elif self.is_in_group("badPeople"):
		type = 0
	else:
		type = -1
	#for some reason in godot you cannot fetch the group directly but can only get a boolean of wheater it is in a group or not
	navAgent = $NavigationAgent
	var _err = navAgent.connect("velocity_computed", self, "_on_velocity_computed")
	
func _process(_delta):
	if Global.topdown:
		$Sprite3D.scale.x = .5
		$Sprite3D.scale.y = .5
		$Sprite3D.animation = "tidle"
	else:
		$Sprite3D.scale.x = 1
		$Sprite3D.scale.y = 1
		$Sprite3D.animation = "widle"
	if navAgent.is_navigation_finished():
			return
	if ready:
		var targetPos = navAgent.get_next_location()
		var direction = global_transform.origin.direction_to(targetPos)
		var speed = direction * navAgent.max_speed
		navAgent.set_velocity(speed)
	
func _on_NPCArea_body_entered(body):
	if (type == -1 or (body.is_in_group("goodPeople") and type == 1) or (body.is_in_group("badPeople")) and type == 0) and body.name == "Detective3d":
		$InteractNotice.show()
		print("placeholder for dialogue")
		#innitiate dialogue
	elif (body.is_in_group("goodPeople") and type == 0) or (body.is_in_group("badPeople") and type == 1) :
		triggered = true
		print("placeholder for fightscene")
		#innitiate fightscene
		#Note, with groups it is easy to trigger all enemies in an area since you can trigger a script in all obj in the same group at onceg

func _on_velocity_computed(_velocity):
	var _remaining_vel = move_and_slide(_velocity, Vector3.UP)

func _on_Timer_timeout():
	if triggered:
		ready = true
		match type:
			0:
				navAgent.set_target_location(get_tree().get_nodes_in_group("goodPeople")[0].global_transform.origin)
			1:
				navAgent.set_target_location(get_tree().get_nodes_in_group("badPeople")[0].global_transform.origin)
				
func _on_NPCArea_body_exited(_body):
	$InteractNotice.hide()
