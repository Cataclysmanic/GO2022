extends Node2D

export var bullet_speed : float
var velocity : Vector2
var damage = 10.0
var originator

signal hit(damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(source, pos : Vector2, rot : float, speed : float):
	originator = source
	set_global_position(pos)
	set_global_rotation(rot)
	if speed != null:
		bullet_speed = speed
	velocity = (bullet_speed * Vector2.RIGHT.rotated(rot))


func _process(delta):
	set_global_position(get_global_position()+velocity*delta)


func die():
	set_visible(false)
	$Area2D/CollisionShape2D.call_deferred("set_disabled", true)
	call_deferred("queue_free")


func _on_Area2D_body_entered(body):
	if body == originator:
		return
	elif body.has_method("hit"):
		var _err = connect("hit", body, "_on_hit")
		emit_signal("hit", damage)
	elif body.has_method("_on_hit"):
		var _err = connect("hit", body, "_on_hit")
		emit_signal("hit", damage)
	self.die()
