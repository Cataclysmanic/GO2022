extends Camera2D


var player
var hud


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(myPlayer, myHud):
	player = myPlayer
	hud = myHud

func _unhandled_input(event):
	var zoom_rate = 1.2
	if event.is_action_pressed("zoom_out"):
		set_zoom(get_zoom()*zoom_rate)
	elif event.is_action_pressed("zoom_in"):
		set_zoom(get_zoom()*(1/zoom_rate))
		
func shake():
	if Global.user_preferences["shake_and_flash"]:
		var tween = get_node("Tween")
		var currentPos = position
		var jitter = 15.0
		var jitterVec = Vector2(rand_range(-jitter, jitter), rand_range(-jitter, jitter))
		tween.interpolate_property(self, "position",
				currentPos+jitterVec, currentPos, .2,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()


func look_ahead(delta):
	var damping = 35.0 # higher numbers give snappier camera movement
	var mousePos = get_global_mouse_position()
	var playerPos = global_position
	var window_height = OS.get_window_size().y
	var inventory_offset = 0
	if hud != null:
		inventory_offset = hud.inventory_offset
	var offset = Vector2(0,(window_height - inventory_offset) / 4)
	if hud.is_inventory_open() == false:
		offset = (mousePos - playerPos) / 2
	position = lerp(position, offset, delta * damping)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.State != player.States.DEAD:
		look_ahead(delta)
