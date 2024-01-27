extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Skeleton3D.rotation_degrees.x = 90
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var p_dir = get_parent().velocity
	if p_dir != Vector3.ZERO:
		if get_parent().grabbed_object != null :
			var ve = get_parent().grabbed_object.global_position - get_parent().global_position
			look_at(get_parent().global_position - ve)
		else : 
			look_at(get_parent().position - p_dir)
