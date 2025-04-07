extends Control

@onready var levels = get_tree().get_nodes_in_group("levelIcons")
@onready var sfx = $SFX

var can_navigate = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.next_level.connect(_on_next_level)
	$PlayerIcon.global_position = levels[Global.current_level].global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Left") and Global.current_level > 0 and can_navigate:
		Global.current_level -= 1
		
		$PlayerIcon.global_position = levels[Global.current_level].global_position
	
	if Input.is_action_just_pressed("Right") and Global.current_level < levels.size() - 1 and can_navigate:
		Global.current_level += 1
		$PlayerIcon.global_position = levels[Global.current_level].global_position
	
	if Input.is_action_just_pressed("Jump") and can_navigate:
		if levels[Global.current_level].level_path:
			Global.attempts_taken = 1
			sfx.play()
			can_navigate = false
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file(levels[Global.current_level].level_path)

func _on_next_level():
	print("next lvl signal")
	if Global.current_level < levels.size() - 1:
		Global.attempts_taken = 1
		Global.current_level += 1
		get_tree().change_scene_to_file(levels[Global.current_level].level_path)
	


func _on_quit_pressed() -> void:
	get_tree().quit()
