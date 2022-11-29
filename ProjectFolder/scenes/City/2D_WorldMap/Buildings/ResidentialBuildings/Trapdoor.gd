extends Sprite

var in_area
var MidBossScene = preload("res://scenes/City/Indoors/MidBossRoom.tscn")


func _ready():
	pass
	
func _process(_delta):
	if in_area and Input.is_action_just_pressed("interact"):
		#get_tree().change_scene('res://scenes/City/Indoors/MidBossRoom.tscn')
		Global.world_controller.change_scene("res://scenes/City/Indoors/MidBossRoom.tscn")
	
func _on_Area2D_body_entered(body):
	if "Detective" in body.name:
		in_area = true

func _on_Area2D_body_exited(body):
	if "Detective" in body.name:
		in_area = false

