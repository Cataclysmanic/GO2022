extends Node2D


var npc
var nav_agent

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func anti_knockback():
	pass

func init(myNPC):
	npc = myNPC

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if npc != null and npc.nav_agent != null:
		if npc.get_state() == npc.States.AIMING:
			aim_toward(Global.player.get_global_position() - npc.get_global_position())

func hit():
	$AnimationPlayer.play("hit")

	
func die():
	$Body.hide()
	$corpse.show()

func aim_toward(dirVector):
	# Just point the gun at the player.
	# should be easy
	
	if dirVector.x > 0:
		$Body/GunArm.rotation = dirVector.angle()
	else:
		$Body/GunArm.rotation = PI - dirVector.angle()
		

