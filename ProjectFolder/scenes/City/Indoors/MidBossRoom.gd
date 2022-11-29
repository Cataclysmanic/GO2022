extends Node2D

var player
onready var playerScene = $ResourcePreloader.get_resource("Player").instance()
var in_area = false

func _ready():
	Global.current_city_map = self
	var startPos = find_node("PlayerSpawn").get_global_position()
	playerScene.set_global_position(startPos)
	playerScene.init(self)
	$Player.add_child(playerScene)
	player = playerScene
	if !Global.minibossdead:
		$MookNPC.map_scene = self
		$MookNPC.player = player
		$MookNPC.spawn_sprite('snakey')
		$MookNPC.set_state(8)
		$MookNPC.health = 250
		$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar.visible = true
		$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar.max_value = 250
		$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar/Label.text = "Veronica"
	else:
		$Sprite/Area2D/CollisionShape2D.disabled = false
	
func _process(delta):
	$Player/PlayerDetective/CanvasLayer/HUD/ProgressBar.value = $MookNPC.health
	if $MookNPC.health <= 0:
		$Sprite/Area2D/CollisionShape2D.disabled = false
		Global.minibossdead = true
	if in_area and Input.is_action_just_pressed("interact"):
		get_tree().change_scene("res://scenes/City/2D_WorldMap/2D_CItyMap.tscn")
	
func _on_projectile_ready(projectile):
	$Projectiles.add_child(projectile)

func _on_Area2D_body_entered(body):
	if "Detective" in body.name:
		in_area = true

func _on_Area2D_body_exited(body):
	if "Detective" in body.name:
		in_area = false
