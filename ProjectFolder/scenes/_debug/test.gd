extends Node2D

var level_navigation_map :RID
var regionID : RID
onready var actor = find_node("KinematicBody2D")
var nav_agent : RID

var current_path = []

func _process(delta):
	$Sprite.set_global_position(get_global_mouse_position())
	

func _ready():
	level_navigation_map = get_world_2d().get_navigation_map()
	regionID = Navigation2DServer.region_create()
	nav_agent = Navigation2DServer.agent_create()
	Navigation2DServer.agent_set_map(nav_agent, level_navigation_map)	
	Navigation2DServer.agent_set_radius(nav_agent, 50)

func update_nav():
	#$Line2D.points = [actor.global_position, get_global_mouse_position()]
	$Line2D.points = current_path
	var optimize = true
	current_path = Navigation2DServer.map_get_path(level_navigation_map, actor.get_global_position(), $Sprite.get_global_position(), optimize)
	#nav_agent.set_target_location($Sprite.get_global_position())
	print(current_path)

func _on_NavUpdateTimer_timeout():
	update_nav()
