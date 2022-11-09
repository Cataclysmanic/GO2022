extends Node


var world_controller = null
var current_scene = null
var IO = null
var Utils = null


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
	
func resume():
	game_state = STATES.ACTIVE

func is_paused():
	if game_state == STATES.ACTIVE:
		return false
	else:
		return true

