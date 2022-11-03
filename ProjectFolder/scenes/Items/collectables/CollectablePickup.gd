extends Spatial


# All this should be a resource, so we can store it in the 

export var item_details : Dictionary = {
	"path_to_popup_display_image":"",
	"path_to_icon":"",
	"item_name":"",
	"notes_for_journal":"",
	"is_unique":false,
	"path_to_scene_for_PlayerController_Items":"",
}

var item_info : InventoryItemResource

# export var item_info : Resource # removed this because objects were sharing resources

export var use_immediately : bool = false # if use_immediately, won't be held in inventory





signal picked_up(me)


# Called when the node enters the scene tree for the first time.
func _ready():
	item_info = InventoryItemResource.new()
	
	var spritePath = find_node("Sprite").get_texture().get_path()

	for propertyName in item_details.keys():
		if item_details[propertyName]:
			item_info.set(propertyName, item_details[propertyName])

	if not item_details["path_to_icon"]:
		item_info.set("path_to_icon", spritePath)
	
	if not item_details["path_to_popup_display_image"]:
		item_info.set("path_to_popup_display_image", spritePath)
		

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
		var recipients = [body, Global.IO, body.get_hud()]
		
		for recipient in recipients:
			if not is_connected("picked_up", recipient, "_on_collectible_picked_up"):
				var _err = connect("picked_up", recipient, "_on_collectible_picked_up")
			
		emit_signal("picked_up", self)
		disappear()
		$PickupNoise.pitch_scale *= rand_range(0.9, 1.5)
		$PickupNoise.play()


func _on_PickupNoise_finished():
	die()
