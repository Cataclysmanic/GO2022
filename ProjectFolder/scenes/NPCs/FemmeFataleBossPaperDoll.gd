extends Node2D


var npc
var nav_agent
var reward = preload("res://scenes/Items/collectables/2D/RocketLauncherPickup.tscn")
var reward2 = preload("res://scenes/Items/collectables/2D/Bandage2DPickup.tscn")

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
	self.add_child(reward2.instance())
	self.add_child(reward.instance())
	
