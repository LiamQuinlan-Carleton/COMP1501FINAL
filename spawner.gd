extends Node2D

@onready var bullet = preload("res://bullet.tscn")
var bullet_instance
@onready var enemy_bullet = preload("res://enemy_bullet.tscn")
var enemy_bullet_instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.shoot.connect(_on_shoot)
	Global.enemy_shoot.connect(_on_enemy_shoot)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Called when shoot signal emitted
func _on_shoot():
	bullet_instance = bullet.instantiate()
	add_child(bullet_instance)

#Called when enemy shoot signal emitted
func _on_enemy_shoot(enemy: RigidBody2D):
	enemy_bullet_instance = enemy_bullet.instantiate()
	add_child(enemy_bullet_instance)
	enemy_bullet_instance.get_child(0).start_position(enemy)
