extends KinematicBody2D

export var path_to_player := NodePath()
export var has_gun = false # melee or shoot?
var velocity = Vector2.ZERO
onready var nav_agent = $NavigationAgent2D
onready var timer = $Timer
onready var sprite = $Sprite
export var active : bool = false
var health = 20.0
var map_scene
var home_building
var current_path = []
onready var player # map_scene will provide this on init now
var ready = false

enum States { INITIALIZING, READY, CHASING, FIGHTING, DEAD }
var State = States.INITIALIZING

onready var character = self

signal loot_ready(lootObj)

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout", self, "update")
	if active:
		$Label.text = "active"
	State = States.READY

func _physics_process(delta):
	
	if (
		State == States.DEAD
		or !home_building.is_player_present() # was !(Global.in_danger==str(self.get_parent().get_parent().name)):
	):
		return
	elif nav_agent.is_navigation_finished():
		return
		

	var target_global_position = nav_agent.get_next_location()
	var direction = global_position.direction_to(target_global_position)

	var desiredvelocity = direction * nav_agent.max_speed
	var steering = (desiredvelocity - velocity) * delta * 4.0
	velocity += steering

	velocity = move_and_slide(velocity)
	sprite.rotation = lerp_angle(sprite.rotation, velocity.angle(), 10.0 * delta)
	

func update():
	nav_agent.set_target_location(player.global_position)


func init(mapScene, homeBuilding):
	map_scene = mapScene
	home_building = homeBuilding
	var _err = connect("loot_ready", mapScene, "_on_loot_ready")
	player = mapScene.get_player()

func flash_hit():
	$AnimationPlayer.play("hit")
	$HitNoise.play()

func die():
	State = States.DEAD
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

func _on_damage_area_body_entered(body):
	if State == States.DEAD:
		return
	if body.name == "PlayerDetective":
		body._on_hit(1)


func _on_PunchingArea_body_entered(body):
	if State == States.DEAD:
		return

	if body.name == "PlayerDetective":
		$AnimationPlayer.play("punch")
	

func _on_PunchingArea_body_exited(body):
	if State == States.DEAD:
		return

	if body.name == "PlayerDetective":
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("relax")
		