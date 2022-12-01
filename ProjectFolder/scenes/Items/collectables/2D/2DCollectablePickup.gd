#2D Collectible Pickup.
#- Instance this if you want clues or items for the detective to discover.
#- Fill in the Item Details dictionary in the inspector

extends Node2D

enum States { INITIALIZING, READY, DISABLED }
var State = States.INITIALIZING

# All this should be a resource, so we can store it in the 

export var item_details : Dictionary = {
	"path_to_popup_display_image":"",
	"path_to_icon":"",
	"item_name":"",
	"notes_for_journal":"",
	"is_unique":false,
	"display_immediately":false,
	"path_to_scene_for_PlayerController_Items":"",
}

var item_info : InventoryItemResource
var line_to_player : Line2D # for debugging

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
	#print("2DCollectablePickup.gd item_info[path_to_popup_display_image] == " + item_info["path_to_popup_display_image"])

	if not item_details["path_to_icon"]:
		item_info.set("path_to_icon", spritePath)
	
	if item_details["path_to_popup_display_image"] != "":
		item_info.set("path_to_popup_display_image", item_details["path_to_popup_display_image"])
	else:
		item_info.set("path_to_popup_display_image", spritePath)
	
	spawn_debug_conspiracy_yarn()
	
	State = States.READY


func spawn_debug_conspiracy_yarn():
	if visible == true and Global.user_preferences["debug"]:
		# spawn a line and draw from position to player.
		# useful for figuring out where quest items might be.
		var myLine = Line2D.new()
		myLine.name = "PointToPlayer"
		myLine.default_color = Color(1.0, 0.0, 0.0, 0.25)

		add_child(myLine)
		myLine.set_global_position(Vector2.ZERO)
		myLine.set_global_scale(Vector2(1,1))
		myLine.width = 1.0
		self.set_global_scale(Vector2(1,1))
		line_to_player = myLine
	

func _process(_delta):
	if State != States.READY:
		return
	elif line_to_player != null and Global.user_preferences["debug"]:
		line_to_player.set_global_position(Vector2.ZERO)
		#self.set_global_scale(Vector2(1.0, 1.0))
		line_to_player.set_global_scale(Vector2(1.0,1.0))
		line_to_player.clear_points()
		line_to_player.add_point(self.get_global_position())
		line_to_player.add_point(Global.player.get_global_position())



func disappear():
	set_visible(false)
	$Area2D/CollisionShape2D.call_deferred("set_disabled", true)


func die():
	queue_free()

func disable_pickup():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	State = States.DISABLED
	
	
func enable_pickup():
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	State = States.READY	
	


func _on_Area_body_entered(body):
	
	if State != States.READY:
		return
	
	if body.has_method("is_player") and body.is_player() == true:
		var recipients = [body]
		if body.has_method("get_hud"):
			recipients.push_back(body.get_hud())
		if Global.IO != null:
			recipients.push_back(Global.IO)
		for recipient in recipients:
			if not is_connected("picked_up", recipient, "_on_collectible_picked_up"):
				var _err = connect("picked_up", recipient, "_on_collectible_picked_up")
			
		emit_signal("picked_up", self)
		if !("Magazine" in self.name):
			if ("Clue" in self.name):
				if ("Circumstantial" in self.name and Global.repetition == false):
					body.update_item(item_details.notes_for_journal, true)
					Global.repetition = true
				elif !("Circumstantial" in self.name):
					body.update_item(item_details.notes_for_journal, true)
			else:
				body.update_item(item_details.item_name, false)
		disappear()
		$PickupNoise.pitch_scale *= rand_range(0.9, 1.5)
		$PickupNoise.play()


func _on_PickupNoise_finished():
	die()
