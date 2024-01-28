extends Node

var BulletScenePath = "res://Scenes/Weapons/Bullet.tscn"
@onready var Bullet = load(BulletScenePath)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawnBullet(shooter_origin: Vector3,transform_b, bullet_type:String):
	var b = Bullet.instantiate()
	$Bullets.add_child(b)
	b.global_transform.basis = transform_b.basis
	b.position = shooter_origin

func _on_weapon_shooting_signal(bullet_type:String, transform, spawning_point:Node3D):
	spawnBullet(spawning_point.global_position, transform, bullet_type)
