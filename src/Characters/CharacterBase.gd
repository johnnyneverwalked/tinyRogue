extends KinematicBody2D

class_name Character

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
		MOVE:
			pass
		IDLE:
			pass		
					

func die():
	emit_signal("died", self)
	queue_free()

func take_damage():
	print_debug("OUCH")
