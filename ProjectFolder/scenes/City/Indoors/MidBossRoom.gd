extends Node2D

var player
onready var playerScene = $ResourcePreloader.get_resource("Player").instance()

func _ready():
	Global.current_city_map = self
	var startPos = find_node("PlayerSpawn").get_global_position()
	playerScene.set_global_position(startPos)
	playerScene.init(self)
	$Player.add_child(playerScene)
	player = playerScene
	$MookNPC.map_scene = self
	$MookNPC.player = player
	$MookNPC.spawn_sprite('snakey')
	$MookNPC.set_state(8)
	$MookNPC.health = 250
	$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar.visible = true
	$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar.max_value = 250
	$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar/Label.text = "Veronica"
	
func _process(delta):
	$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar.value = $MookNPC.health
	
func _on_projectile_ready(projectile):
	$Projectiles.add_child(projectile)
