extends Spatial


export var path_to_scene : String = "res://Main.tscn"
export var location_in_scene : Vector3 = Vector3.ZERO



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_Area_body_entered(body):

	if "Detective" in body.name:


		if Global.IO.has_item("key"):
			Global.world_controller.change_scene(path_to_scene)
