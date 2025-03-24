extends RigidBody2D

@export var health : int = 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	if health <= 0:
		queue_free()

#Called when player deals damage to this enemy
func deal_damage(amount):
	health -= amount
