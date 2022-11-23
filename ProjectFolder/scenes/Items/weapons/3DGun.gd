extends Spatial


var ammo = 6
var player_object
var HUD

signal loaded(initAmmo)
signal shot(ammoRemaining)
signal reload_requested(me)

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
	if HUD != null:
		if HUD.has_method("_on_player_gun_shot"):
			_err = connect("shot", HUD, "_on_player_gun_shot")
		if HUD.has_method("_on_player_gun_loaded"):
			_err = connect("loaded", HUD, "_on_player_gun_loaded")
		if HUD.has_method("_on_player_gun_reload_requested"):
			_err = connect("reload_requested", HUD, "_on_player_gun_reload_requested")


func load_gun(num, ammoType):
	emit_signal("loaded", num, ammoType)


func shoot():
	if ammo > 0:
		$Bang.play()
		ammo -= 1
		emit_signal("shot", ammo) # the HUD will keep track of spare magazines. They'll provide automatic reloads
	else:
		$Click.play()
		emit_signal("reload_requested", self)
		

func _on_HUD_reloaded(ammoCount):
	ammo = ammoCount
	
