extends Node2D


var ticks = 0
var occlusionPolygons = []
export var num_npcs = 6
var map_scene

signal shit_got_real() # for music
signal shit_calmed_down() # for music


# Called when the node enters the scene tree for the first time.
func _ready():
	generate_light_occluders_from_bitmap()
	spawn_npcs(num_npcs)


func init(map):
	map_scene = map

func spawn_npcs(num):
	
	for _i in range(num):
		spawn_npc()

func spawn_npc():
	var pos = get_random_spawn_location(50)
	var npcList = $AvailableNPCs.get_resource_list()
	var randomNPCName = npcList[randi()%len(npcList)]
	var npcScene = $AvailableNPCs.get_resource(randomNPCName).instance()
	npcScene.set_position(pos) # local coords
	npcScene.name = "NPC Target Dummy"
	$NPCs.add_child(npcScene)

	
func get_random_spawn_location(spread:int) -> Vector2:
	# spread is random jitter to apply, within number of pixels
	var pos = Vector2.ZERO
	var spawnPoints = $PossibleSpawnPoints.get_children()
	var chosenPoint = spawnPoints[randi()%len(spawnPoints)]
	pos = chosenPoint.get_position() #local coords

	var jitterX = rand_range(-spread, spread)
	var jitterY = rand_range(-spread, spread)
	pos += Vector2(jitterX, jitterY)

	return pos




func generate_light_occluders_from_bitmap():
	var wallSprite = $Walls
	var wallTex :Texture = wallSprite.get_texture()
	var wallImage : Image = wallTex.get_data()
	var Stupid_Voodoo_Fudge_Factor = 3.0 # WHY?!?!?
	var rectSize = wallImage.get_size() * scale.x * Stupid_Voodoo_Fudge_Factor
	var rectPos = get_position()-(rectSize/2)
	var wallRect = Rect2(rectPos, rectSize)
	var wallBitmap = BitMap.new()
	var xForm = get_transform() # what do I do with this???
	wallBitmap.create_from_image_alpha(wallImage)
	
	occlusionPolygons = wallBitmap.opaque_to_polygons(wallRect)
#	var offsetPolygons = []
#	for polygon in occlusionPolygons:
#		var offsetPoly = translate_polygon(polygon, position)
#		offsetPolygons.push_back(offsetPoly)
	
	
	for polygon in occlusionPolygons:
		spawn_light_occluder(polygon)
		spawn_static_body(polygon)
		
	$StaticBodyWalls.position = position/3 # I don't know where the 3 came from
	$LightOccluders.position = position/3
	

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
	$StaticBodyWalls.add_child(newStatic)
	
	var newPolyDraw = Polygon2D.new()
	newPolyDraw.set_polygon(myPolygon)
	newPolyDraw.set_color(Color.violet)
	$StaticBodyWalls.add_child(newPolyDraw)
	
	


func _on_Area2D_body_entered(body):
	if "detective" in body.name.to_lower():
		$Roof.hide()
		if not is_connected("shit_got_real", map_scene, "_on_shit_got_real"):
			connect("shit_got_real", map_scene, "_on_shit_got_real")
		emit_signal("shit_got_real")


func _on_Area2D_body_exited(body):
	if "detective" in body.name.to_lower():
		$Roof.show()
		if not is_connected("shit_calmed_down", map_scene, "_on_shit_calmed_down"):
			connect("shit_calmed_down", map_scene, "_on_shit_calmed_down")
		emit_signal("shit_calmed_down")
