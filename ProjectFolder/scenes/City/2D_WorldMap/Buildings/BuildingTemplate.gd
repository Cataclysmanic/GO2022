extends Node2D


var ticks = 0
var occlusionPolygons = []
export var num_npcs = 6
var map_scene
var player_currently_present = false


signal shit_got_real() # for music
signal shit_calmed_down() # for music


# Called when the node enters the scene tree for the first time.
func _ready():
	generate_occluders_from_bitmap()
	$DebugInfo.set_visible(Global.user_preferences["debug"])

func init(mapObj):

	map_scene = mapObj
	
	spawn_npcs(int(num_npcs) * Global.user_preferences["difficulty"])

func spawn_npcs(num):
	
	for _i in range(num):
		spawn_npc()

func spawn_npc():
	var spawnJitter = 15
	var spawnLocationRouteTuple = get_random_spawn_location(spawnJitter)
	var pos = spawnLocationRouteTuple[0]
	var pathFollowObj = spawnLocationRouteTuple[1]
	
	var npcList = $AvailableNPCs.get_resource_list()
	var randomNPCName = npcList[randi()%len(npcList)]
	var npcScene = $AvailableNPCs.get_resource(randomNPCName).instance()
	npcScene.set_scale(Vector2(1/scale.x, 1/scale.y))
	npcScene.set_position(pos)
	npcScene.name = "NPC Target Dummy"

	npcScene.init(map_scene, self, pathFollowObj)
#	if "Residential" in self.name:
#		# What's this for?
#		npcScene.active = true
	$NPCs.add_child(npcScene)

	
func get_random_spawn_location(spread:int) -> Array:
	# returns position (Vector2) and pathFollowObject (PathFollow2D)
	
	# spread is random jitter to apply, within number of pixels
	
	var pos = Vector2.ZERO
	var pathFollowObj = null
	var spawnLocations = $PossibleSpawnPoints.get_children()
	var chosenLocation = spawnLocations[randi()%len(spawnLocations)]
	if "PatrolRoute" in chosenLocation.name:
		pathFollowObj = chosenLocation.spawn_path_follower()
		pos = chosenLocation.get_position()
	else:
		pathFollowObj = null
		pos = chosenLocation.get_position() #local coords

	var jitterX = rand_range(-spread, spread)
	var jitterY = rand_range(-spread, spread)
	pos += Vector2(jitterX, jitterY)
	
	return [ pos, pathFollowObj ]

func get_random_quest_target_location() -> Position2D:
	# it's important that we provide the full Position2D, not just the Vector2 location.
	# the quest targets contain info about their locations.
	var locations = $PossibleQuestTargetLocations.get_children()
	var randIdx = randi()%len(locations)
	return locations[randIdx]


func generate_occluders_from_bitmap():
	var wallSprite = $Walls
	var wallTex :Texture = wallSprite.get_texture()
	var wallImage : Image = wallTex.get_data()
	var rectSize = wallImage.get_size()
	var rectPos = Vector2.ZERO
	var wallRect = Rect2(rectPos, rectSize)
	var wallBitmap = BitMap.new()
	#var xForm = get_transform() # what do I do with this???
	wallBitmap.create_from_image_alpha(wallImage)
	
	occlusionPolygons = wallBitmap.opaque_to_polygons(wallRect)
	var navPolygon = NavigationPolygon.new()
	#var navPolygonInstance = NavigationPolygonInstance.new()
	
	navPolygon.add_outline(rect_to_outline(wallRect))
		
	for polygon in occlusionPolygons:
		spawn_light_occluder(polygon)
		spawn_static_body(polygon)
		var margin_for_navigation_around_static_bodies = 7.0
		navPolygon.add_outline(Geometry.offset_polygon_2d(polygon, margin_for_navigation_around_static_bodies)[0])
		#navPolygon.add_outline(polygon)
		
	$StaticBodyWalls.position = Vector2.ZERO - ( (rectSize ) / 2)
	$LightOccluders.position = $StaticBodyWalls.position
	
#	navPolygon.make_polygons_from_outlines()
#	navPolygonInstance.navpoly = navPolygon
#	navPolygonInstance.position = $StaticBodyWalls.position
#	$NPCs.add_child(navPolygonInstance)


func rect_to_outline(rect : Rect2):
	var outline = []
	outline.push_back(rect.position)
	outline.push_back(rect.position+Vector2(0, rect.size.y))
	outline.push_back(rect.position+rect.size)
	outline.push_back(rect.position+Vector2(rect.size.x, 0))
	return outline


func translate_polygon(polygon, translation : Vector2):
	#I'm sure there's a number of built-in functions to do this with xForms, but I'm not sure how yet.
	var newPolygon = []
	for point in polygon:
		newPolygon.push_back(point + translation)
	return newPolygon
	

func spawn_light_occluder(polygon):
	var newOccluder = LightOccluder2D.new()
	var newOccPoly = OccluderPolygon2D.new()
	newOccPoly.set_polygon(polygon)
	newOccluder.occluder = newOccPoly
	$LightOccluders.add_child(newOccluder)

func spawn_static_body(myPolygon):
	var newStatic = StaticBody2D.new()
	var collisionPolygon = CollisionPolygon2D.new()
	collisionPolygon.set_polygon(myPolygon)
	newStatic.add_child(collisionPolygon)
	newStatic.name = "static_wall_" + str($StaticBodyWalls.get_child_count()).pad_zeros(2)
	newStatic.set_collision_layer_bit(5, true) # bit 5 is walls (watch out for off-by-one errors, it's called layer 6 in the inspector)
	$StaticBodyWalls.add_child(newStatic)
	
	var newPolyDraw = Polygon2D.new()
	newPolyDraw.set_polygon(myPolygon)
	newPolyDraw.set_color(Color.violet)
	$StaticBodyWalls.add_child(newPolyDraw)
	

	


func _on_Area2D_body_entered(body):
	if "detective" in body.name.to_lower():
		$Roof.hide()
		if not is_connected("shit_got_real", map_scene, "_on_shit_got_real"):
			var _err = connect("shit_got_real", map_scene, "_on_shit_got_real")
		emit_signal("shit_got_real")
		player_currently_present = true
		if find_node("DebugInfo"):
			$DebugInfo.text = "Player Present: " + str(player_currently_present)
		#Global.in_danger = str(self.name)


func is_player_present():
	return player_currently_present
	

func _on_Area2D_body_exited(body):
	if "detective" in body.name.to_lower():
		#$Roof.show()
		if not is_connected("shit_calmed_down", map_scene, "_on_shit_calmed_down"):
			var _err = connect("shit_calmed_down", map_scene, "_on_shit_calmed_down")
		emit_signal("shit_calmed_down")
		#Global.in_danger = "no"
		player_currently_present = false
		if find_node("DebugInfo"):
			$DebugInfo.text = "Player Present: " + str(player_currently_present)
		


