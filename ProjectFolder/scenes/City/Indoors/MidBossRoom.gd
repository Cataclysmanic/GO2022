extends Node2D

var player
onready var playerScene = $ResourcePreloader.get_resource("Player").instance()
var in_area = false

func _ready():
	$AnimationPlayer.play()
	Global.current_city_map = self
	var startPos = find_node("PlayerSpawn").get_global_position()
	playerScene.set_global_position(startPos)
	playerScene.init(self)
	$Player.add_child(playerScene)
	player = playerScene
	if !Global.minibossdead:
		$MookNPC.map_scene = self
		$MookNPC.player = player
		$MookNPC.spawn_sprite('snakey')
		$MookNPC.set_state(0)
		$MookNPC.health = 250
		$MookNPC2.map_scene = self
		$MookNPC2.player = player
		$MookNPC2.spawn_sprite('ressurected?')
		$MookNPC2.set_state(0)
		$MookNPC2.health = 250
		$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar.visible = true
		$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar.max_value = 500
		$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar/Label.text = "Crime Couple"
	else:
		$Sprite/Area2D/CollisionShape2D.disabled = false

	$BeatTheBossEnding.disable_pickup()
	$BeatTheBossEnding.hide()
	$MemoryClueVeronica.disable_pickup()
	$MemoryClueVeronica.hide()
	
func _process(_delta):
	$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar.value = $MookNPC.health + $MookNPC2.health
	if $MookNPC.health <= 0 and $MookNPC2.health <= 0:
		if Global.minibossdead == false: # only do this once
			$BeatTheBossEnding.enable_pickup() # this will take the player to an end-game animatic.
			$BeatTheBossEnding.show()
			$MemoryClueVeronica.enable_pickup() 
			$MemoryClueVeronica.show()
#			$LadderSprite/LadderArea/CollisionShape2D.set_deferred("disabled", false) # ladder will take player back to a new instance of the city
		Global.minibossdead = true
#	if in_area and Input.is_action_just_pressed("interact"):
#		#get_tree().change_scene("res://scenes/City/2D_WorldMap/2D_CItyMap.tscn")
#		Global.world_controller.call_deferred("change_scene", "res://scenes/City/2D_WorldMap/2D_CItyMap.tscn")
		# Note, since this is a new instance of the city map, all the quest_givers will be reset to zero.
		# It would be better if we could keep the old city map on ice until we return to it, or at least save the state of the quest givers.
		# but, that's not likely to get fixed for the game jam.
	
	
	
func _on_projectile_ready(projectile):
	$Projectiles.add_child(projectile)

#func _on_Area2D_body_entered(body):
#	if "Detective" in body.name:
#		in_area = true
#
#func _on_Area2D_body_exited(body):
#	if "Detective" in body.name:
#		in_area = false
