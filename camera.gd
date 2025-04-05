extends Camera2D

@export var distance : float
@export var max_distance : float
@export var snap : float

func _process(delta: float) -> void:
	position.x = lerp(position.x, distance * get_parent().velocity.x, snap)
	if sign(position.x) * position.x > max_distance:
		position.x = sign(position.x) * max_distance
	#zoom = Vector2(1/get_parent().velocity.length(), 1/get_parent().velocity.length())
