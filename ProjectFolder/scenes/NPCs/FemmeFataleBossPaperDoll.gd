extends Node2D


var npc
var nav_agent

func _ready():
	pass

func init(myNPC):
	npc = myNPC
	$corpse.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if npc != null and npc.nav_agent != null:
		if npc.get_state() == 6:
			$AnimationPlayer.play("shoot")


func hit():
	$AnimationPlayer.play("hit")
	
func die():
	$AnimationPlayer.play("die")

func aim_toward(dirVector):
	# Just point the gun at the player.
	# should be easy
	
	if dirVector.x > 0:
		$Body/GunArm.rotation = dirVector.angle()
	else:
		$Body/GunArm.rotation = PI - dirVector.angle()
