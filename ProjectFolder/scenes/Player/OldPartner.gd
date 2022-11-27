extends Node2D
export(int) var health

onready var bullet = preload('res://scenes/Items/Projectiles/BossBullet.tscn')

onready var reload_timer = $ReloadTimer
var shoot = true

var state

var STATES = ['SHOOTING', 'BLOCKING', 'DAMAGABLE', 'AIRSTRIKE', 'TALKING']

func _ready():
	state = 'SHOOTING'



func SHOOTING():
	var target = get_tree().get_nodes_in_group("Player")[0] as KinematicBody2D
	var b = bullet.instance()
	look_at(target.position)
	if shoot == true:
		owner.add_child(b)
		b.transform = $Gun/Position2D.global_transform
		reload_timer.start()
		shoot = false
	
	
	
func _physics_process(delta):
	if state == 'SHOOTING':
		SHOOTING()
	


func _on_ReloadTimer_timeout():
	shoot = true


func _on_HitZone_body_entered(body):
	if body.is_in_group("Bullet"):
		pass
