extends "res://src/Characters/enemies/EnemyBase.gd"


func take_damage(_damage = 0, _knockback = Vector2.ZERO, _status = null):
	.take_damage(_damage, _knockback, _status)
	$Audio/hit.play()
