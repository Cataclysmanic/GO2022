extends Node2D

# Intentions:
# Patrol route should move a path-follow target around the map,
# NPCs should be given a route when they spawn.
# NPCs will then try and follow the path target, to the best of their ability.
# Note, npcs are not locked on the path. 
# They can either head directly toward the target, or pathfind their way there.

# The target moves around the track at variable rates.
# when it encounters a HustleZone, it should speed up.
# when it encounters a LingerZone, it should slow down.

# the zones may not necessarily affect NPC behaviour, except insofar as they choose to follow the target.

# note: multiple NPCs could be assigned to this path. 
# each one should get their own PathFollow2D node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var home_building
var city_map
var Patrolling_NPCs = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func spawn_path_follower():
	var newPathFollow = $ResourcePreloader.get_resource("follower").instance()
	$Path2D.add_child(newPathFollow)
	return newPathFollow

func terminate_path_follower(pathFollowObj):
	pathFollowObj.die()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass	

