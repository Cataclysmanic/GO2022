extends Node2D


var player


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player()
	play_bg_music()
	
	spawn_buildings()
	Global.current_city_map = self

	initialize_quest_givers()
	



func spawn_buildings():
	
	# we'll add procedural code later, maybe someday, if we have multiple buildings.
	# for now, just initialize the buildings you have.
	for building in $Outdoor/Buildings.get_children():
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
	player = playerScene

func get_player():
	return player


func initialize_quest_givers():
	for questGiver in $QuestGivers.get_children():
		questGiver.init(self)


func _on_loot_ready(itemObj):
	$Collectibles.call_deferred("add_child", itemObj)


func _on_projectile_ready(projectile):

	$Outdoor/Projectiles.add_child(projectile)


func _on_shit_got_real():
	$Audio/BGMusicCalm.stop()
	$Audio/BGMusicTense.play()
	

func _on_shit_calmed_down():
	$Audio/BGMusicCalm.play()
	$Audio/BGMusicTense.stop()
	
func get_random_building():
	var building
	var buildingList = $Outdoor/Buildings.get_children()
	building = buildingList[randi()%len(buildingList)]
	return building
	
	
func get_random_quest_target_location():
	var quest_target_location
	var building = get_random_building()

	if building.has_method("get_random_quest_target_location"):
		quest_target_location = building.get_random_quest_target_location()
	else:
		printerr("building doesn't have method: get_random_quest_target_location")
	return quest_target_location	
	
