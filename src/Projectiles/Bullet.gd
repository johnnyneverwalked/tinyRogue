extends Area2D

const UNIT: = 16

onready var particles: Particles2D = $Particles2D
onready var sprite: Sprite = $Sprite
onready var collider: CollisionShape2D = $CollisionShape2D

export var speed: = 16 * UNIT
export var knockback: = UNIT * UNIT
export var damage: = 0
export var spread = 0.2
export var status: int

var velocity: = Vector2.ZERO

var target: String = "enemy"

func _ready() -> void:
	pass

func setup(_damage = 0, _status = -1, _target = "enemy"):
	target = _target
	damage = _damage
	status = _status
	return self

func start(_position, _direction):
	position = _position
	randomize()
	_direction += Vector2(randf() * spread, randf() * spread)
	rotation = _direction.angle()
	velocity = _direction * speed
	$Audio/shoot.play()
		
func _process(delta: float) -> void:
	position += velocity * delta

func explode():
	collider.queue_free()
	sprite.visible = false
	particles.emitting = true
	yield(get_tree().create_timer(particles.lifetime * 2),"timeout")
	queue_free()		


func _on_body_entered(body: Node) -> void:
	explode()
	if body.name == "hitbox" && body.get_parent().get_meta(target):
		body.get_parent().take_damage(damage, knockback * velocity.normalized())
