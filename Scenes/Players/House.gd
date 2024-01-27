extends Node3D

@export var house_parts_life_amount = 10
@export var house_selected: Node3D

var life_left = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	house_selected.show()
	for p in house_selected.get_children():
		life_left[p.name] = [
			house_parts_life_amount
			]
		(p as MeshInstance3D).create_convex_collision(true, true)
		var p_static_body:StaticBody3D = p.get_child(0)
		p_static_body.add_to_group("walls")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
