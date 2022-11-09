extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player()
	play_bg_music()
	
	spawn_buildings()
	

func spawn_buildings():
	
	# we'll add procedural code later, maybe someday, if we have multiple buildings.
	# for now, just initialize the buildings you have.
	for building in find_node("Buildings").get_children():
		if building.has_method("init"):
			building.init(self) # mainly so they know who to tell about music changes.
	
	
func play_bg_music():
	$Audio/BGMusicCalm.play()


func spawn_player():
	var playerScene = $ResourcePreloader.get_resource("Player").instance()
	var startPos = find_node("PlayerSpawnPoint").get_global_position()
	playerScene.set_global_position(startPos)
	playerScene.init(self)
	$Player.add_child(playerScene)


func _on_projectile_ready(projectile):

	$Outdoor/Projectiles.add_child(projectile)


func _on_shit_got_real():
	$Audio/BGMusicCalm.stop()
	$Audio/BGMusicTense.play()
	

func _on_shit_calmed_down():
	$Audio/BGMusicCalm.play()
	$Audio/BGMusicTense.stop()
	
