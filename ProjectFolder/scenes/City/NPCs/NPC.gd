extends KinematicBody
var type = null 

func _ready():
	if self.is_in_group("goodPeople"):
		type = 1
	else:
		type = 0
	#for some reason in godot you cannot fetch the group directly but can only get a boolean of wheater it is in a group or not
	
func _process(delta):
	if Global.topdown:
		$Sprite3D.scale.x = .5
		$Sprite3D.scale.y = .5
		$Sprite3D.animation = "tidle"
	else:
		$Sprite3D.scale.x = 1
		$Sprite3D.scale.y = 1
		$Sprite3D.animation = "widle"

func _on_NPCArea_body_entered(body):
	if (body.is_in_group("goodPeople") and type == 1) or (body.is_in_group("badPeople") and type == 0) :
		print("placeholder for dialogue")
		#innitiate dialogue
	elif (body.is_in_group("goodPeople") and type == 0) or (body.is_in_group("badPeople") and type == 1) :
		print("placeholder for fightscene")
		#innitiate fightscene
		#Note, with groups it is easy to trigger all enemies in an area since you can trigger a script in all obj in the same group at onceg
