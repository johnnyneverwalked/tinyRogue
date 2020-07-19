extends KinematicBody2D

class_name CharacterBase

signal died
# warning-ignore:unused_signal
signal shoot

# Consts
const UNIT = 16

# States:
const IDLE = "idle"
const MOVE = "move"
const DIE = "die"
const HIT = "hit"

export var velocity: = Vector2.ZERO
export var dir: = Vector2.ZERO
export var speed: = 8 * UNIT
export var acceleration:= 16 * 8 * UNIT

export var hp: = 1
export var dmg: = 1
export var weight: = 1

onready var state_machine = $StateMachine
onready var sprite: AnimatedSprite = $AnimatedSprite
onready var animPlayer: AnimationPlayer = $AnimationPlayer

onready var debug: Label = $Label

func _ready() -> void:
	state_machine.connect("state_entered", self, "state_entered")
	state_machine.connect("state_exited", self, "state_exited")
	state_machine.add_state(IDLE)
	state_machine.add_state(MOVE)
	state_machine.add_state(DIE)
	state_machine.add_state(HIT)
	
	state_machine.add_transition(IDLE, MOVE, MOVE)
	state_machine.add_transition(IDLE, DIE, DIE)
	state_machine.add_transition(IDLE, HIT, HIT)
	
	state_machine.add_transition(MOVE, IDLE, IDLE)
	state_machine.add_transition(MOVE, DIE, DIE)
	state_machine.add_transition(MOVE, HIT, HIT)
	
	state_machine.add_transition(HIT, DIE, DIE)
	state_machine.add_transition(HIT, IDLE, IDLE)
	
	state_machine.set_current_state(IDLE)
	state_machine._run()
	
	
func state_exited(_state):
	pass
	
func state_entered(state):
	debug.text = state if state else ""
	if state:
		sprite.play(state)
		
	match state:
		HIT:
			yield(get_tree().create_timer(0.5),"timeout")
			state_machine.change_state(IDLE)
		IDLE:
			pass		
					

func handleMovement(delta: float):
	if dir != Vector2.ZERO && (state_machine.current_state != HIT || velocity == Vector2.ZERO):
		velocity += dir * acceleration * delta
		velocity = velocity.clamped(speed)
		return
	
	var friction: float = acceleration * delta
	if velocity.length() > friction:
		velocity -= velocity.normalized() * friction
	else:
		velocity = Vector2.ZERO

func handle_knockback(_knockback: Vector2):
	velocity += _knockback / weight

func die():
	emit_signal("died", self)
	queue_free()

func take_damage(_damage = 0, _knockback = Vector2.ZERO, _status = null):
	state_machine.change_state(HIT)
	print_debug([_damage, _knockback, _status])
	handle_knockback(_knockback)
