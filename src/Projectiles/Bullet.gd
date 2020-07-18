extends Area2D

const UNIT: = 16

onready var particles: Particles2D = $Particles2D
onready var sprite: Sprite = $Sprite

export var speed: = 16 * UNIT
var velocity: = Vector2.ZERO

var target: String

func _ready() -> void:
	pass

func start(_position, _direction, _target = "enemy"):
	position = _position
	rotation = _direction.angle()
	velocity = _direction * speed
	target = _target
	
func _process(delta: float) -> void:
	position += velocity * delta

func explode():
	sprite.visible = false
	particles.emitting = true
	yield(get_tree().create_timer(particles.lifetime * 2),"timeout")
	queue_free()		


func _on_body_entered(body: Node) -> void:
	explode()
	if body.name == "hitbox" && body.get_parent().get_meta(target):
		body.get_parent().take_damage()
