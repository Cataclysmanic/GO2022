extends Node2D


var player


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player()
	play_bg_music()
	
	spawn_buildings()
	generate_navmesh()
	
	
	Global.current_city_map = self



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
	navPolygonInstance.name = "city_nav_polygon_instance"
	$NavPolygons.add_child(navPolygonInstance)
	#add_doors(navPolygon)

func add_doors(_big_nav_poly):
	pass
	# place some static bodies on the map.
	# we'll enable/disable their collision shape as required to let the player through
	# we'll use their outline to modify the big city_nav_polygon_instance
	# we'll create new NavigationPolygonInstance for the door
	# we'll enable and disable that as required for NPCs.
	
	#  add manual NavPolygonInstances for doors.
#	var doorOutlines = []
#	for navPolygonInstance in $NavPolygons.get_children():
#		if "door" in navPolygonInstance.name.to_lower():
#			doorOutlines.push_back(navPolygonInstance.get_navigation_polygon())
#
#	for doorOutline in doorOutlines:
#		big_nav_poly.add_poly(doorOutline)
#	var big_nav_poly_instance = big_nav_poly.get_navigation_polygon()
#	big_nav_poly_instance.make_polygons_from_outlines()
	
		

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
		var margin_for_navigation_around_static_bodies = 25.0
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
	#$Audio/BGMusicCalm.play()
	$Audio/BGCityNoise.play()

func spawn_player():
	var playerScene = $ResourcePreloader.get_resource("Player").instance()
	var startPos = find_node("PlayerSpawnPoint").get_global_position()
	playerScene.set_global_position(startPos)
	playerScene.init(self)
	$Player.add_child(playerScene)
	player = playerScene

func get_player():
	return player




func _on_loot_ready(itemObj, lootPosition:Vector2 = Vector2.ZERO):
		
	$Collectibles.call_deferred("add_child", itemObj)
	if lootPosition != Vector2.ZERO:
		itemObj.set_global_position(lootPosition)


func _on_loud_noise_made(pos):
	var noiseScene = $ResourcePreloader.get_resource("LoudNoise").instance()
	noiseScene.set_global_position(pos)
	$Noises.add_child(noiseScene)

func _on_projectile_ready(projectile):
	$Projectiles.add_child(projectile)


func _on_shit_got_real(): # probably inside
	$Audio/BGCityNoise.stop()
	$Audio/BGMusicCalm.stop()
	$Audio/BGMusicTense.play()
	

func _on_shit_calmed_down(): # probably outside
	$Audio/BGMusicCalm.play()
	$Audio/BGMusicTense.stop()
	$Audio/BGCityNoise.play()
	
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
	
