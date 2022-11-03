extends Spatial


export var path_to_scene : String = "res://Main.tscn"
export var location_in_scene : Vector3 = Vector3.ZERO

signal missing_key()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_Area_body_entered(body):

	if "Detective" in body.name:


		if Global.IO.has_item("key"):
			Global.world_controller.change_scene(path_to_scene)
		elif Global.trigger_events["missing_tutorial_key_reported"] == false:
			Global.Utils.oneshot_emit(self, "missing_key", body.get_hud())
