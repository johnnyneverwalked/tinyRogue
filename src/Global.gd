extends Node

# Bullets and statuses
enum ELEMENTS {FIRE, WATER, EARTH, AIR}

#refs
onready var BULLETS = {
	"base": {
		"node": preload("res://src/Projectiles/Bullet.tscn"),
		"elements": [],
		"cooldown": 20
	},
	"bubble": {
		"node": preload("res://src/Projectiles/Water/Bubbles.tscn"),
		"elements": [ELEMENTS.WATER],
		"cooldown": 20
	}
}
