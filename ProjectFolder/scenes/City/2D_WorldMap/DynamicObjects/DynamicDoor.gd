extends StaticBody2D

# Should be able to

#setup:
# remove it's own outline from an existing NavPolygonInstance
# insert its own NavPolygonInstance

#open/close
# detect player on doorstep
# check for item, if required
# enable and disable its navpolygoninstance depending on open/close status
# enable and disable its static-body collision shape to allow player to pass when open

enum States { INITIALIZING, OPEN, CLOSED }
var State = States.INITIALIZING




# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.CLOSED



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func init(bigmap_nav_container, bigmap_nav_poly_instance):
	cutout_shape(bigmap_nav_poly_instance)
	add_door_to_bigmap_nav(bigmap_nav_container)


func cutout_shape(navPolyInstance):
	var parent_navpoly = navPolyInstance.get_navigation_polygon()
	var myOutline = get_door_outline()
	# when do we translate this to match the city map?
	print("bigmap outline count: " + str(parent_navpoly.get_outline_count()))
	print("bigmap outlines[0]:")
	print(parent_navpoly.get_outline(0))
	print("door outline: ")
	print(myOutline)
	parent_navpoly.add_outline(myOutline)
	parent_navpoly.make_polygons_from_outlines()

func add_door_to_bigmap_nav(nav2D_container):
	var moving_navpolyinstance = $NavigationPolygonInstance
	self.remove_child(moving_navpolyinstance)
	nav2D_container.add_child(moving_navpolyinstance)

func get_door_outline():
	var outline = []
	# get the perimeter vertices for the static body collision shape
	var shape = $ObstacleCollisionShape2D.get_shape()
	var rectSize = shape.get_extents()
	outline.push_back(Vector2(0,0))
	outline.push_back(Vector2(0, rectSize.y))
	outline.push_back(Vector2(rectSize.x, rectSize.y))
	outline.push_back(Vector2(rectSize.x, 0))

	var scaledOutline = scale_outline(outline, global_scale)
	var translatedOutline = translate_outline(scaledOutline, global_position)
	# do we need to translate the points before sending them back?
	
	return translatedOutline
	

func scale_outline(outline, scaleVector):
	var scaled_outline = []
	for point in outline:
		scaled_outline.push_back(Vector2(point.x * scaleVector.x, point.y * scaleVector.y))
	return scaled_outline

func translate_outline(outline, translateVector):
	var translatedOutline = []
	for point in outline:
		translatedOutline.push_back(point + translateVector)
	return translatedOutline


func open():
	# rotate the door sprite, disable the collision shape, enable the navmesh
	$Sprite.set_rotation(PI/2)
	$ObstacleCollisionShape.call_deferred("set_disabled", true)
	State = States.OPEN
	
func close():
	$Sprite.set_rotation(0.0)
	$ObstacleCollisionShape2D.call_deferred("set_disabled", false)
	State = States.CLOSED
	
 


func _on_OpeningZone_body_entered(body):
	
	if body.has_method("is_player") and body.is_player() == true:
		if State == States.CLOSED:
			open()
		else:
			close()
		


func _on_InitDelayTimer_timeout():
	# fudge so we don't start searching for nodes before the map is ready
#	var bigmap_navPolyInstance = get_parent().get_children()[0]
#	print(bigmap_navPolyInstance.name)
#	cutout_shape(bigmap_navPolyInstance)
	pass
