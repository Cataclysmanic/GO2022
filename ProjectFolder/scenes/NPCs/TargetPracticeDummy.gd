extends KinematicBody2D

export var active : bool = false
var health = 20.0
var map_scene
var current_path = []
onready var player # map_scene will provide this on init now

onready var nav_agent = $NavigationAgent2D


onready var character = self

signal loot_ready(lootObj)


# Called when the node enters the scene tree for the first time.
func _ready():
	if active:
		$Label.text = "active"


func init(mapScene):
	map_scene = mapScene
	var _err = connect("loot_ready", mapScene, "_on_loot_ready")
	player = mapScene.get_player()

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




func _process(_delta):
	if not active:
		return
	elif not nav_agent.is_target_reached():
		move_along_path()
	update()


func _unhandled_input(event):
	if event.is_action_pressed("PathfindingTest"):
		_update_navigation_path(character.position, get_local_mouse_position())


func move_along_path():
#	current_path = nav_agent.get_path_to()
	var dest = nav_agent.get_next_location()
	look_at(dest)
	var speed = 80.0
	var velocity = (Vector2.RIGHT*speed).rotated(rotation)
	var _result = move_and_slide(velocity, Vector2(0, 0))

func _update_navigation_path(_start_position, end_position):
	
	nav_agent.set_target_location(end_position)
	current_path = nav_agent.get_nav_path()

func draw():
	var last_point = current_path[0]
	for point in current_path:
		if point != last_point:
			pass
		else:
			draw_line(last_point, point, Color.red)
			last_point = point





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
