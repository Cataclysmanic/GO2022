extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func update_polygon_shape():
	var polygon = []
	polygon.push_back(Vector2(0,0))
	for ray in $Polygon2D.get_children():
		if ray.is_colliding():
			var collisionPoint = self.to_local(ray.get_collision_point())
			polygon.push_back(collisionPoint)
		else:
			polygon.push_back(ray.get_cast_to())
	$Polygon2D.set_polygon(polygon)
	


func _on_ShapeUpdateTimer_timeout():
	var distance_to_show_flashlights = 1000.0
	if global_position.distance_squared_to(Global.player.position) < pow(distance_to_show_flashlights, 2):
		$Polygon2D.show()
		update_polygon_shape()
	else:
		$Polygon2D.hide()
