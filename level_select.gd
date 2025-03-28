extends Control

@onready var levels = get_tree().get_nodes_in_group("levelIcons")
var current_level: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PlayerIcon.global_position = levels[current_level].global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Left") and current_level > 0:
		current_level -= 1
		$PlayerIcon.global_position = levels[current_level].global_position
	
	if Input.is_action_just_pressed("Right") and current_level < levels.size() - 1:
		current_level += 1
		$PlayerIcon.global_position = levels[current_level].global_position
	
	if Input.is_action_just_pressed("Jump"):
		if levels[current_level].level_path:
			get_tree().change_scene_to_file(levels[current_level].level_path)
