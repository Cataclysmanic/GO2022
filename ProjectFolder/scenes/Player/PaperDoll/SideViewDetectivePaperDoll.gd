extends Node2D

var melee_damage = 15
var player


func _ready():
	player = get_parent()
	
func start_running():
	$AnimationPlayer.play("Run")


func start_walking():
	$AnimationPlayer.play("Walk")
	
	
func relax():
	start_idling()
	
func start_idling():
	$AnimationPlayer.play("Relax")
	
func point_gun():
	$AnimationPlayer.play("PointGun")

func melee_attack():
	if randf() < 0.5:
		$AnimationPlayer.play("melee attack 1")
	elif randf() < 0.95:
		$AnimationPlayer.play("melee attack 2")


func dash():
	$AnimationPlayer.play("dash")


func get_animation():
	var anim_queue = $AnimationPlayer.get_queue()
	if len(anim_queue) > 0:
		return anim_queue[0]

func point_torso_at(_targetPos:Vector2):
	pass
	
func point_legs_at(_targetPos:Vector2):
	pass


func _process(_delta):
	pass	


func _on_DamageArea_body_entered(body):
	if body != Global.player and body.has_method("_on_hit"):
		if body.has_method("extreme_knock_back"):
			body.extreme_knock_back(self.global_position.direction_to(body.global_position))
		#body._on_hit(melee_damage)
		$Upper/Fist.hide()
		var collisionShape = $Upper/Fist/DamageArea/CollisionShape2D
		collisionShape.set_deferred("disabled", true)
