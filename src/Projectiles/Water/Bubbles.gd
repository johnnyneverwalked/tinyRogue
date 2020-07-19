extends "res://src/Projectiles/Bullet.gd"

var lifetime = 3

func _init() -> void:
	spread = 0.5
	speed /= 2
	knockback = 0
	bulletsPerShot = 3

func _process(delta: float) -> void:
	lifetime -= delta
	velocity -= velocity * delta
	if lifetime < 0:
		queue_free()
	

func explode():
	$trail.emitting = false
	.explode()
