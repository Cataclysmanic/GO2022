extends Node2D


var npc
var nav_agent

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("walk")

func init(myNPC):
	npc = myNPC
	$corpse.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if npc != null and npc.nav_agent != null:
		if npc.get_state() in [ npc.States.FIGHTING ]:
			aim_toward(Global.player.get_global_position() - npc.get_global_position())

func hit():
	$AnimationPlayer.play("hit")

func aim(syncMuzzle):
	assert(syncMuzzle != null)
	$AnimationPlayer.stop()
	syncMuzzle.set_global_position($GunArm/GunSprite/GunMuzzleLoc.global_position)
	syncMuzzle.set_global_rotation($GunArm/GunSprite/GunMuzzleLoc.global_rotation)
	if has_node("MeriksAnimatedSprite"):
		$MeriksAnimatedSprite.play("default")
	
func die():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("die")

func aim_toward(dirVector):
	# Just point the gun at the player.
	# should be easy
	
	if dirVector.x > 0:
		$GunArm.rotation = dirVector.angle()
	else:
		$GunArm.rotation = PI - dirVector.angle()
		



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hit" and not npc.get_state() in [ npc.States.DEAD, npc.States.FLYING]:
		$AnimationPlayer.play("walk")
	elif anim_name == "die":
		if has_node("MeriksAnimationedSprite") and is_instance_valid($MeriksAnimatedSprite):
			$MeriksAnimatedSprite.hide()
