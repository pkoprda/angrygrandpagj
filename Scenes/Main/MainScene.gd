extends Node

var BulletScenePath = "res://Scenes/Weapons/Bullet.tscn"
@onready var Bullet = load(BulletScenePath)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawnBullet(shooter_origin: Vector3):
	var b = Bullet.instance()
	$Bullets.add_child(b)
	b.transform.origin = shooter_origin
	b.velocity = -b.transform.basis.z * b.muzzle_velocity
