extends Area2D

#Bullet move speed
@export var move_speed = 2000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = Global.player_position
	var target_position = get_global_mouse_position()
	var angle = (target_position - global_position).normalized().angle()
	rotation = angle


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += Vector2(cos(rotation), sin(rotation)) * move_speed * delta

#Deal damage to enemy
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("deal_damage"):
		body.deal_damage(1)
		queue_free()
	else:
		queue_free()
