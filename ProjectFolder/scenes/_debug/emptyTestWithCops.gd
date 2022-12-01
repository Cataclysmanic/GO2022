extends Node2D

var city_map
var npc_to_spawn

# Called when the node enters the scene tree for the first time.
func _ready():
	city_map = self
	npc_to_spawn = $ResourcePreloader.get_resource("CopNPC")
	var patrolRoute = spawn_patrol_route()
	spawn_npc(patrolRoute)
	
	


func spawn_patrol_route():
	var routeNames = $AvailablePatrolRoutes.get_resource_list()
	var routeScene = $AvailablePatrolRoutes.get_resource(routeNames[randi()%routeNames.size()]).instance()

	add_child(routeScene)
	routeScene.set_global_position(self.get_global_position())
	return routeScene

func spawn_path_follower(routeScene):
	var follower = routeScene.spawn_path_follower()
	follower.set_speed(80.0)
	return follower

func spawn_npc(patrolRoute):
	# Generate cops that roam around on a simple path
	var npcScene = npc_to_spawn.instance()
	npcScene.set_global_position($NPCSpawnPosition.get_global_position())
	var pathFollower = spawn_path_follower(patrolRoute)
	var home_building = null
	npcScene.init(city_map, home_building, pathFollower)
	#npcScene.set_scale((Vector2(1/home_building.scale.x, 1/home_building.scale.y)))	
	#home_building.get_node("NPCs").add_child(npcScene)
	npcScene.set_scale(Vector2(1.0, 1.0))
	# don't need the blue color anymore, we have actual cop npcs
	#npcScene.set_modulate(Color.aqua)
	get_node("NPCs").add_child(npcScene)

func _on_projectile_ready(projectile):
	add_child(projectile)
	
