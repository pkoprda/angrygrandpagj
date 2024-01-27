extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var p_dir = get_parent().velocity
	if p_dir != Vector3.ZERO:
		look_at(get_parent().global_position-p_dir)
