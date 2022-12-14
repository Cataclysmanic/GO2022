extends Area2D


var NPC


# Called when the node enters the scene tree for the first time.
func _ready():
	NPC = get_parent()
	if Global.user_preferences["debug"]:
		$Polygon2D.set_color(Color(1.0,1.0,1.0,0.3))
	else:
		$Polygon2D.set_color(Color(1.0,1.0,0.5,0.15))

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
	$CollisionPolygon2D.set_polygon(polygon)


func is_near_player(distance):
	if Global.player != null:
		if global_position.distance_squared_to(Global.player.position) < pow(distance, 2):
			return true
		else:
			return false
	else:
		return false

func is_patrolling():
	if NPC.State == NPC.States.PATROLLING:
		return true
	else:
		return false
	
func _on_ShapeUpdateTimer_timeout():
	if is_near_player(1000.0) and is_patrolling():
		$Polygon2D.show()
		update_polygon_shape()
	else:
		$Polygon2D.hide()


func _on_VisionCone_body_entered(body):
	if not NPC.State in [NPC.States.DEAD, NPC.States.AIMING, NPC.States.INITIALIZING ]:
		if body.has_method("is_player") and body.is_player():
			# found the detective.
			if NPC.has_method("_on_VisionCone_saw_detective"):
				NPC._on_VisionCone_saw_detective(body.get_global_position())
