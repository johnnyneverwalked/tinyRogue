extends Camera2D

export var DESIRED_RESOLUTION = Vector2(1280, 720)
var vp
var scaling_factor = 1

func _ready():
  vp = get_viewport()
  vp.connect(
	"size_changed", self, "on_vp_size_change"
  )
  on_vp_size_change()

func on_vp_size_change():
	var scale_vector = vp.size / DESIRED_RESOLUTION
	var new_scaling_factor = max(floor(min(scale_vector[0], scale_vector[1])), 1)
	if new_scaling_factor != scaling_factor:
		scaling_factor = new_scaling_factor
		zoom = Vector2(1 / scaling_factor, 1 / scaling_factor)
