extends Node2D

var player

func _ready():
	$Timer.connect("timeout", self, "remove_scent")
	
	#debug
	$Debug.set_process(false)

func remove_scent():
	player.scentTrail.erase(self)
	queue_free()
