extends Node

var BulletScenePath = "res://Scenes/Weapons/Bullet.tscn"
@onready var Bullet = load(BulletScenePath)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func spawnBullet(shooter_translation: Vector3):
	var b = Bullet.instance()
	add_child(b)
	b.transform.origin = shooter_translation
	b.velocity = -b.transform.basis.z * b.muzzle_velocity


func _on_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/ui_end.tscn")
