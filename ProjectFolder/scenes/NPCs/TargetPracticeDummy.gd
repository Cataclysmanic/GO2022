extends KinematicBody2D

var health = 20.0
var map_scene


signal loot_ready(lootObj)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func init(mapScene):
	map_scene = mapScene
	var _err = connect("loot_ready", mapScene, "_on_loot_ready")

func flash_hit():
	$AnimationPlayer.play("hit")
	$HitNoise.play()

func die():
	$DieNoise.play()
	$AnimationPlayer.play("die")
	$CollisionShape2D.call_deferred("set_disabled", true)
	spawn_loot()


func spawn_loot():
	var loader = $SpawnOnDeath
	var options = loader.get_resource_list()
	var randOptionName = options[randi()%len(options)]
	var lootObject = loader.get_resource(randOptionName).instance()
	lootObject.set_global_position(get_global_position())
	emit_signal("loot_ready", lootObject)


func _on_hit(damage):
	health -= damage
	if health <= 0:
		die()
	else:
		flash_hit()
		


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		set_visible(false)
		queue_free()
