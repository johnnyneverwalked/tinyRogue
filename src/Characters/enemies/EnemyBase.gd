extends "res://src/Characters/CharacterBase.gd"

class_name EnemyBase

var CHASE = "chase"

onready var vision: RayCast2D = $vision

var gameScene: Node
var player: KinematicBody2D

func _ready() -> void:
	set_process(false)
	set_meta("enemy", true)
	
	speed /= 2
	acceleration
	
	state_machine.add_state(CHASE)
	
	state_machine.add_transition(CHASE, MOVE, MOVE)
	state_machine.add_transition(CHASE, IDLE, IDLE)
	
	state_machine.add_transition(MOVE, CHASE, CHASE)
	
	state_machine.add_transition(IDLE, CHASE, CHASE)

func _physics_process(delta: float) -> void:
	chase(delta * speed)
#	if state_machine.current_state == CHASE:
		
	handleRelativePosition()
	handleMovement(delta)

	self.velocity = move_and_slide(velocity)

func _process(_delta: float) -> void:
	match state_machine.current_state:
		MOVE:
			if dir == Vector2.ZERO:
				state_machine.change_state(IDLE)
		IDLE:
			if dir != Vector2.ZERO:
				state_machine.change_state(MOVE)	

func handleRelativePosition():
	sprite.set_z_index(int(gameScene.player.position.y < position.y))

func chase(distance: float):
	var chasing = false
	
	look(player.position)
	
	# chase if visible
	if !vision.is_colliding():
		dir = vision.cast_to.normalized()
		chasing = true
	else:
		for scent in gameScene.player.scentTrail:
			look(scent.position)
			
			if !vision.is_colliding():	
				dir = vision.cast_to.normalized()
				chasing = true
				break
	
	if chasing:
		if [IDLE, MOVE].has(state_machine.current_state):
			state_machine.change_state(CHASE)
	else: 
		state_machine.change_state(IDLE)
		dir = Vector2.ZERO	
	
	sprite.set_flip_h(gameScene.player.position.x < position.x)
	
	
func look(target: Vector2):
	vision.cast_to = target - position
	vision.force_raycast_update()

func setData(ref: Node):
	self.gameScene = ref
	self.player = ref.player
	set_process(true)
