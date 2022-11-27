extends Node


var world_controller = null
var current_city_map = null
var player
var IO = null
var Utils = null
var repetition = false #I dislike abusing autoload but this function didn't work otherwise for some reason
var rockets = false

var game_speed = 1.0 # useful for super-slow-motion events, and pseudo-pause when dialogs are open
# but, requires us to multiply it in for anything that otherwise would require delta.
var normal_game_speed = 1.0
var paused_speed = 0.001


var user_preferences = {
	"difficulty": 1.0, #0.5 to 3.0
	"gore": true,
	"shake_and_flash":true,
	"debug":false,
}


enum STATES { INITIALIZING, READY, ACTIVE, PAUSED }
var game_state = STATES.INITIALIZING

var topdown = true
#While in full topdown mode, this is where the viewpoint is

var trigger_events = { # a few things we can test for, to see if the user already had the feedback event, so we don't repeat ourselves
	"missing_gun_reported":false,
	"found_gun":false,
	"missing_tutorial_key_reported":false,
}

func pause():
	game_state = STATES.PAUSED
	game_speed = paused_speed
	#recursive_pause_timers(world_controller, true) # not working as intended
	
	
func resume():
	game_state = STATES.ACTIVE
	game_speed = normal_game_speed
	#recursive_pause_timers(world_controller, false) # not working.. boo


func recursive_pause_timers(node, pauseTimers : bool): # true to pause them
	# Nov 26, 2022: not working as intended.
	# was supposed to slow down all timers by the same factor as Global.game_speed
	assert(false) # method is currently broken.
	# to pause: 
		# need to check for timers currently stopped and set_wait_time
		# then check for timers currently running and invoke start(new_longer_wait_time)
	# then unwind it all when you unpause.
	
	for childNode in node.get_children():
		if childNode is Timer:
			var factor = 1.0
			if pauseTimers == false: # resume speed
				factor = paused_speed / normal_game_speed
			else: # slow down
				factor = normal_game_speed / paused_speed
			#childNode.set_time_remaining( childNode.get_time_remaining() * factor )
			childNode.set_paused(pauseTimers)
		if childNode.get_child_count() > 0:
			recursive_pause_timers(childNode, pauseTimers)



func is_paused():
	if game_state == STATES.ACTIVE:
		return false
	else:
		return true

