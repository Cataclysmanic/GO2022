extends Node2D

var player



func _ready():
	spawn_player()
	
	Global.current_city_map = self
	
	
func spawn_player():
	var playerScene = $ResourcePreloader.get_resource("Player").instance()
	var startPos = find_node("PlayerSpawn").get_global_position()
	playerScene.set_global_position(startPos)
	playerScene.init(self)
	$Player.add_child(playerScene)
	player = playerScene
	player.manual_spawn_gun()


func _on_projectile_ready(projectile):

	$Projectiles.add_child(projectile)



############OLD PARTNER#############################################

func _remove_pillar(pillar_number):
	if pillar_number == 1:
		$Walls/Barrier.visible = false
		$Walls/Barrier/CollisionPolygon2D.disabled = true
	if pillar_number == 2:
		$Walls/Barrier3.visible = false
		$Walls/Barrier3/CollisionPolygon2D.disabled = true
	if pillar_number == 3:
		$Walls/Barrier2.visible = false
		$Walls/Barrier2/CollisionPolygon2D.disabled = true
