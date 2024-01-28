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
	b.connect("exploded", _on_explosion_signal)
	
func _on_weapon_shooting_signal(bullet_type:String, transform, spawning_point:Node3D):
	spawnBullet(spawning_point.global_position, transform, bullet_type)

func _on_explosion_signal(transform, bullet_type, body):
	if body is PhysicalBone3D : 
		# Could only be of our two grandpas
		var player = body
		while player != self and player != $"Player 1" and player != $"Player 2" :
			player = player.get_parent()
		
		player.get_hit(bullet_type, body, transform)
		
