extends Node

class State:
	var connected_states = {}
	var transitions = {}
	var parent = null
	
	func add_connection(to_state, trans_name, transition_value = false):
		connected_states[to_state] = transition_value
		transitions[trans_name] = to_state
		
	func set_transition(trans_name, value):
		if transitions.has(trans_name):
			connected_states[transitions[trans_name]] = value

	func reset_transitions():
		for state in connected_states.keys():
			connected_states[state] = false
		
	func check_transitions():
		for state in connected_states.keys():
			var val = connected_states[state]
			if val:
				return state

class_name StateMachine

signal state_entered(current_state)
signal state_exited(current_state)
signal state_changed(current_state)

var states = {}

var current_state

func _ready():
	_stop()

func _run():
	set_process(true)
	
func _stop():
	set_process(false)

func add_state(_name):
	states[_name] = State.new()

func add_transition(from_state, to_state, trans_name, trans_value = false):
	assert (states.has(from_state))
	assert (states.has(to_state))
	
	states[from_state].add_connection(to_state, trans_name, trans_value)

func change_state(to_state):
	if to_state == current_state:
		return
	emit_signal("state_exited", current_state)
	set_current_state(to_state)
	
func set_current_state(state):
	if state != current_state and state != null:
		if states.has(current_state):
			states[current_state].reset_transitions()
		emit_signal("state_changed", current_state)
		current_state = state
		emit_signal("state_entered", current_state)
	
func _process(delta):
	if states.has(current_state):
		change_state(states[current_state].check_transitions())
	
func set_transition(trans_name, value):
	states[current_state].set_transition(trans_name, value)
