extends Control

@onready var title = $Title
@onready var sfx = $SFX
@onready var label = $Label

var can_start = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.hide()
	sfx.play()
	title.play("Startup")
	await get_tree().create_timer(4.1).timeout
	can_start = true
	while true:
		label.show()
		await get_tree().create_timer(1.2).timeout
		label.hide()
		await get_tree().create_timer(0.8).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Jump") and can_start:
		get_tree().change_scene_to_file("res://level_select.tscn")
