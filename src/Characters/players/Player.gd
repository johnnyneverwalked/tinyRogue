extends "res://src/Characters/CharacterBase.gd"


# States
const ROLL = "roll"

var rolling: bool = false

func _ready() -> void:
	rolling = false
	state_machine.add_state(ROLL)
	
	state_machine.add_transition(ROLL, MOVE, MOVE)
	state_machine.add_transition(ROLL, IDLE, IDLE)
	
	state_machine.add_transition(MOVE, ROLL, ROLL)
	
	state_machine.add_transition(IDLE, ROLL, ROLL)
	
	

func _physics_process(_delta: float) -> void:
	
	if !rolling:
		dir.x = -Input.get_action_strength("left") + Input.get_action_strength("right")
		dir.y = -Input.get_action_strength("up") + Input.get_action_strength("down")
		dir.normalized()
	
		if dir != Vector2.ZERO:
			state_machine.change_state(MOVE)
		else:
			state_machine.change_state(IDLE)
		
		if Input.is_action_just_pressed("roll"):
			rolling = true
			state_machine.change_state(ROLL)
			
	elif dir == Vector2.ZERO:
		dir = Vector2(1, 0)				
		
	
	var velocity = (dir * speed)		
	
	self.velocity = move_and_slide(velocity)	

func _process(_delta: float) -> void:	
	var mousePos = get_global_mouse_position()
	sprite.set_flip_h(mousePos.x < position.x)
	

func _on_AnimatedSprite_animation_finished() -> void:
	rolling = false


func _on_state_entered(current_state) -> void:
#	state_entered(current_state)
	match current_state:
		ROLL:	
			animPlayer.play(current_state)
