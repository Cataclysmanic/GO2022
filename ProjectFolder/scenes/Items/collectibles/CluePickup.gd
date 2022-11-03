extends Spatial


export var image_to_display_on_pickup : Texture
export var icon_for_inventory : Texture
export var item_name : String

signal picked_up(me)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func disappear():
	set_visible(false)
	$Area/CollisionShape.set_disabled(true)


func die():
	queue_free()

func _on_Area_body_entered(body):
	if "Detective" in body.name:
		if body.has_method("_on_collectible_picked_up"):
			if not is_connected("picked_up", body, "_on_collectible_picked_up"):
				var _err = connect("picked_up", body, "_on_collectible_picked_up")
				emit_signal("picked_up", self)
				disappear()
				$PickupNoise.play()


func _on_PickupNoise_finished():
	die()
