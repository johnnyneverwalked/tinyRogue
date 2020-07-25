extends "res://src/Characters/CharacterBase.gd"


# States
const ROLL = "roll"

#refs
onready var scentTimer:= $ScentTimer
const scent_scene = preload("Scent.tscn")

# data
var fireCooldown = 0
var rolling: bool = false
var scentTrail = []

#signals
signal drop_scent

# --- METHODS

func _ready() -> void:
	rolling = false
	scentTimer.connect("timeout", self, "add_scent")
	
	
	state_machine.add_state(ROLL)
	
	state_machine.add_transition(ROLL, MOVE, MOVE)
	state_machine.add_transition(ROLL, IDLE, IDLE)
	
	state_machine.add_transition(MOVE, ROLL, ROLL)
	
	state_machine.add_transition(IDLE, ROLL, ROLL)
	
	

func _physics_process(delta: float) -> void:		
	handleInput()
	handleMovement(delta)
	velocity = move_and_slide(velocity)	

func _process(delta: float) -> void:	
	var mousePos = get_global_mouse_position()
	sprite.set_flip_h(mousePos.x < position.x)
	
	fireCooldown = fireCooldown - delta * 60 if fireCooldown > 0 else 0

	

func handleInput():
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
		
	# fire
	if Input.is_action_pressed("attack"):
		fireBullet()

func fireBullet():
	if fireCooldown	> 0 || state_machine.current_state == ROLL:
		return
	
	var bulletType = Global.BULLETS["base"]
	fireCooldown = bulletType.cooldown

	var bullet = bulletType.node.instance().setup(dmg)
	for i in range(bullet.bulletsPerShot):
		emit_signal("shoot", bullet, position, position.direction_to(get_global_mouse_position()))
		if i == bullet.bulletsPerShot - 1:
			break
		yield(get_tree().create_timer(0.05), "timeout")
		bullet = bulletType.node.instance().setup(dmg)


func add_scent():
	var scent      = scent_scene.instance()
	scent.player   = self
	scent.position = position
	
	emit_signal("drop_scent", scent)
	scentTrail.push_front(scent)


func _on_AnimatedSprite_animation_finished() -> void:
	rolling = false


func _on_state_entered(current_state) -> void:
#	state_entered(current_state)
	match current_state:
		ROLL:	
			animPlayer.play(current_state)
