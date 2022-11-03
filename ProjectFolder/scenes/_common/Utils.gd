extends Node




# Called when the node enters the scene tree for the first time.
func _ready():
	Global.Utils = self
	

func safe_connect(originator, signalName, recipient):
	if is_instance_valid(recipient) and recipient.has_method("_on_"+signalName):
		if not originator.is_connected(signalName, recipient, "_on_"+signalName):
			var err = originator.connect(signalName, recipient, "_on_"+signalName)
			if err:
				printerr("Global.Utils.safe_connect. Error connecting signal " + signalName + " to " + recipient.name)
				printerr(err)
	else:
		printerr("Global.Utils.safe_connect. either recipient "+ recipient.name +" isn't valid (instantiated) or they don't have the method: " + "_on_"+signalName)

func safe_disconnect(originator, signalName, recipient):
	if originator.is_connected(signalName, recipient, "_on_"+signalName):
		var err = originator.disconnect(signalName, recipient, "_on_"+signalName)
		if err:
			printerr("Global.Utils.safe_disconnect(). Error disconnecting " + signalName + " from " + originator.name + " to " + recipient.name)

func oneshot_emit(originator, signalName, recipient):
	safe_connect(originator, signalName, recipient)
	originator.emit_signal(signalName)
	safe_disconnect(originator, signalName, recipient)
	
