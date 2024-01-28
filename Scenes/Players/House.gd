extends Node3D

@export var house_parts_life_amount = 10
@export var house_selected: Node3D

var life_settings = {}
var destruction_sounds = []

signal wall_get_hit(wall)
# Called when the node enters the scene tree for the first time.
func _ready():
	house_selected.show()
	house_selected.scale = Vector3.ONE*2
	for p in house_selected.get_children():
		life_settings[p.name] = house_parts_life_amount
		generate_wall_collisions(p)
		p.get_parent().add_to_group("walls")
	randomize()
	destruction_sounds.append(preload("res://sounds/house_desctruction_01.wav"))
	destruction_sounds.append(preload("res://sounds/house_desctruction_02.wav"))
	destruction_sounds.append(preload("res://sounds/house_desctruction_03.wav"))
	$HouseDestruction.stream=destruction_sounds.front()

func generate_wall_collisions(wall:MeshInstance3D):
	var collision_area = CollisionShape3D.new()
	var new_area = Area3D.new()
	
	#var collision_area = CollisionShape3D.new()
	var shape_area = wall.mesh.create_convex_shape(true, true)
	
	collision_area.scale = wall.scale
	collision_area.shape = shape_area
	var collision_body = collision_area.duplicate()
	collision_body.scale = Vector3.ONE
	collision_body.position = Vector3.ZERO
	
	new_area.add_child(collision_body)
	
	wall.get_parent().add_child(collision_area)
	collision_area.position = wall.position
	collision_area.rotation = wall.rotation
	wall.get_parent().remove_child(wall)
	#collision_area.add_child(collision_body)
	collision_area.add_child(wall)
	collision_area.add_child(new_area)
	wall.position = Vector3.ZERO
	wall.rotation = Vector3.ZERO
	wall.scale = Vector3.ONE
	
	new_area.scale = Vector3.ONE
	new_area.position = Vector3.ZERO
	new_area.monitoring = true;
	new_area.connect("area_entered", func(body): _handle_hit(collision_area, body))

func _handle_hit(wall_hit:CollisionShape3D, body:Node3D):
	if body.is_in_group("bullets") : 
		life_settings[wall_hit.get_child(0).name] = life_settings[wall_hit.get_child(0).name] -10 #To change later to adapt to the different types of bullets
		if life_settings[wall_hit.get_child(0).name] <0 : 
			wall_hit.queue_free()
			$HouseDestruction.play()

func destruction_sound_random(s:Array) -> void:
	s.shuffle()
	$HouseDestruction.stream=destruction_sounds.front()

func _on_house_destruction_finished():
	print("_on_house_destruction_finished()")
	destruction_sound_random(destruction_sounds)
