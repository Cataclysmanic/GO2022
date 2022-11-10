extends Node2D

var occlusionPolygons # unnavigable
var nav_mesh



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func generate_light_occluders_from_bitmap():
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
	
	nav_mesh = spawn_navmesh(rectPos, rectSize)
	for polygon in occlusionPolygons:
		spawn_light_occluder(polygon)
		spawn_static_body(polygon)
		
	$StaticBodyWalls.position = Vector2.ZERO - ( (rectSize ) / 2)
	$LightOccluders.position = $StaticBodyWalls.position
	

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
	
func spawnNavmesh(position, size):
	# make a simple navmesh at extents,
	# then use Geometry to clip the occlusionPolygons out
	# the result should be a navigable navmesh
	
	
