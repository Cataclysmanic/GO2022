extends RigidBody2D

enum States { READY, KICKED }
var State = States.READY

# Called when the node enters the scene tree for the first time.
func _ready():
	State = States.READY
	set_global_scale(Vector2(1,1))

func spawn_single_fruit():
	var fruitScene = $ResourcePreloader.get_resource("SingleFruit").instance()
	var rand_offset = Vector2.RIGHT.rotated(rand_range(-PI, PI))*rand_range(12.0, 25.0)
	fruitScene.position = self.position + rand_offset # so they don't spawn directly on top of each other
	get_parent().call_deferred("add_child", fruitScene)
	
	#var randVector = Vector2.ONE.rotated(rand_range(-PI,PI))*rand_range(0.0, 1.0)
	#fruitScene.move_and_slide(randVector)


func tip_the_cart():
	$AnimatedSprite.play("kick")
	State = States.KICKED
	$Area2D/CollisionShape2D.call_deferred("set_disabled", true)
	if Global.user_preferences["shake_and_flash"] == true:
		$CPUParticles2D.emitting = true
		for _i in range(randi()%8 + 3):
			spawn_single_fruit()
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite.visible = false

func _on_Body_entered(body):
	if State == States.READY and body.has_method("is_player") and body.is_player():
		tip_the_cart()
		


