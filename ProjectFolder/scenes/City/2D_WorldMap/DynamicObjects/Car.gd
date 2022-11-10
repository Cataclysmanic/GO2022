extends PathFollow2D

var speed = 200.0
var health = 100.0
# maybe player should be able to shoot cars.. or they take damage from collisions. later


export var damage = 40.0
signal hit(damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_offset(get_offset()+speed * delta)


func _on_Area2D_body_entered(body):
	if body.has_method("_on_hit"):
		var _err = connect("hit", body, "_on_hit")
	elif body.has_method("hit"):
		var _err = connect("hit", body, "hit")
	emit_signal("hit", damage)
