extends Control

@export var level_name: String = ""
@export_file("*.tscn") var level_path: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = level_name
	add_to_group("levelIcons")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
