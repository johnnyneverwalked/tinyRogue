extends "res://src/Characters/CharacterBase.gd"

class_name Enemy

var gameScene: Node
var nav: Navigation2D


func _ready() -> void:
	speed = speed / 2
	set_process(false)

func _physics_process(delta: float) -> void:
	chase(delta * speed)
	handleRelativePosition()
	
	if dir == Vector2.ZERO:
		state_machine.change_state(IDLE)
	else:
		state_machine.change_state(MOVE)
			
	var velocity = dir.normalized() * speed
	self.velocity = move_and_slide(velocity)
	

func handleRelativePosition():
	sprite.set_z_index(int(gameScene.player.position.y < position.y))

func chase(distance: float):
	
	var path = nav.get_simple_path(position, gameScene.player.position)
	var start = position
	for i in path.size():
		var distToNext = start.distance_to(path[0])
		if distance <= distToNext && distance > 0.0:
			dir = start.direction_to(path[0])
			break
		elif distance <= 0.0:
			dir = Vector2.ZERO
			break
		distance -= distToNext
		start = path[0]
		path.remove(0)
	
	sprite.set_flip_h(gameScene.player.position.x < position.x)

func setData(ref: Node):
	self.gameScene = ref
	self.nav = ref.nav
	set_process(true)
