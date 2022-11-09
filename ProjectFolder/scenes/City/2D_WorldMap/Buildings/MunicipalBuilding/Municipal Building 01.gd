extends Node2D


var ticks = 0
var occlusionPolygons = []

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_light_occluders_from_bitmap()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	#update()
#	if ticks % 100 == 0:
#		update()
#	ticks += 1

func generate_light_occluders_from_bitmap():
	var wallSprite = $Walls
	var wallTex :Texture = wallSprite.get_texture()
	var wallImage : Image = wallTex.get_data()
	var Stupid_Voodoo_Fudge_Factor = 3.0
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
	
	
func _draw():
	
	for polygon in occlusionPolygons:
#		var offsetPoly = []
#		for point in polygon:
#			offsetPoly.push_back(point + position/3) # How did you get 3? Show your work.
#		var colors : PoolColorArray = []
#		for _i in range(len(polygon)):
#			colors.push_back(Color.blueviolet)
#		draw_polygon(polygon, colors)

		#draw_colored_polygon(offsetPoly, Color.goldenrod)
		pass
		#draw_colored_polygon(polygon, Color.crimson)


func _on_Area2D_body_entered(body):
	if "detective" in body.name.to_lower():
		$Roof.hide()
		


func _on_Area2D_body_exited(body):
	if "detective" in body.name.to_lower():
		$Roof.show()
