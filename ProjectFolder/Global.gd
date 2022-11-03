extends Node


var world_controller
var current_scene
var IO

enum STATES { INITIALIZING, READY, ACTIVE, PAUSED }
var game_state = STATES.INITIALIZING



func pause():
	game_state = STATES.PAUSED
	
func resume():
	game_state = STATES.ACTIVE

func is_paused():
	if game_state == STATES.ACTIVE:
		return false
	else:
		return true

