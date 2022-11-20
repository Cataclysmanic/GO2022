extends Node2D

var melee_damage = 15

func _ready():
	pass
	
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
	
func get_animation():
	var anim_queue = $AnimationPlayer.get_queue()
	if len(anim_queue) > 0:
		return anim_queue[0]

func point_torso_at(targetPos:Vector2):
	$Upper.look_at(targetPos)

	
func point_legs_at(targetPos:Vector2):
	$Lower.look_at(targetPos)


func _process(_delta):
	point_torso_at(get_global_mouse_position())
	


func _on_DamageArea_body_entered(body):
	if body != Global.player and body.has_method("_on_hit"):
		body._on_hit(melee_damage)
		$Upper/Fist.hide()
		var collisionShape = $Upper/Fist/DamageArea/CollisionShape2D
		collisionShape.set_deferred("disabled", true)
