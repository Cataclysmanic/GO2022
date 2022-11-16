extends Node2D


var player


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player()
	play_bg_music()
	
	spawn_buildings()
	generate_navmesh()
	Global.current_city_map = self

	initialize_quest_givers()
	



func spawn_buildings():
	
	# we'll add procedural code later, maybe someday, if we have multiple buildings.
	# for now, just initialize the buildings you have.
	for building in $Outdoor/Buildings.get_children():
		if building.has_method("init"):
			building.init(self) # mainly so they know who to tell about music changes.
	
func generate_navmesh():
	var navPolygon = NavigationPolygon.new()
	var navPolygonInstance = NavigationPolygonInstance.new()
	var extents = 3500
	var cityOutline = []
	for vector in [ Vector2(-1, -1), Vector2(-1, 1), Vector2(1,1), Vector2(1,-1)]:
		cityOutline.push_back(vector*extents)
	navPolygon.add_outline(cityOutline)

	for building in $Outdoor/Buildings.get_children():
		for outline in generate_nav_outlines(building):
			navPolygon.add_outline(outline)
	
	navPolygon.make_polygons_from_outlines()
	navPolygonInstance.navpoly = navPolygon
	$NavPolygons.add_child(navPolygonInstance)


func generate_nav_outlines(building):
	var outlines = []
	var wallSprite = building.get_node("Walls")
	var wallTex :Texture = wallSprite.get_texture()
	var wallImage : Image = wallTex.get_data()
	var rectSize = wallImage.get_size()
	var rectPos = Vector2.ZERO
	var wallRect = Rect2(rectPos, rectSize)
	var wallBitmap = BitMap.new()
	#var xForm = get_transform() # what do I do with this???
	wallBitmap.create_from_image_alpha(wallImage)
	
	var occlusionPolygons = wallBitmap.opaque_to_polygons(wallRect)
	
	for outline in occlusionPolygons:
		var margin_for_navigation_around_static_bodies = 10.0
		var scaledOutline = scale_outline(outline, building.scale)
		var translatedOutline = translate_outline(scaledOutline, building.position - (Vector2(rectSize.x * building.scale.x, rectSize.y * building.scale.y)/2))
		
		var erodedOutline = Geometry.offset_polygon_2d(translatedOutline, margin_for_navigation_around_static_bodies)[0]
		
		outlines.push_back(erodedOutline)
#	print(building.name)
#	print(outlines)
	return outlines


func scale_outline(outline : PoolVector2Array, scale : Vector2):
	var scaledOutline = []
	for point in outline:
		scaledOutline.push_back(Vector2(point.x * scale.x, point.y * scale.y))
	return scaledOutline
	

func translate_outline(polygon, translation : Vector2):
	#I'm sure there's a number of built-in functions to do this with xForms, but I'm not sure how yet.
	var newPolygon = []
	for point in polygon:
		newPolygon.push_back(point + translation)
	return newPolygon
######
	
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
	
