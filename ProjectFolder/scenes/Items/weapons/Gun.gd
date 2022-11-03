extends Spatial


var ammo = 6
var player_object
var HUD

signal loaded(initAmmo)
signal shot(ammoRemaining)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(playerObj, initAmmo):
	ammo = initAmmo
	player_object = playerObj
	connect_hud()
	load_gun(6, "22 cal")
	
func connect_hud():
	HUD = player_object.get_hud()
	var _err
	if HUD != null and HUD.has_method("_on_player_gun_shot"):
		_err = connect("shot", HUD, "_on_player_gun_shot")
	if HUD != null and HUD.has_method("_on_player_gun_loaded"):
		_err = connect("loaded", HUD, "_on_player_gun_loaded")
		

func load_gun(num, ammoType):
	emit_signal("loaded", num, ammoType)


func shoot():
	if ammo > 0:
		$Bang.play()
		ammo -= 1
		emit_signal("shot", ammo)
	else:
		$Click.play()

