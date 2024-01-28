extends Node

var BulletScenePath = "res://Scenes/Weapons/Bullet.tscn"
@onready var Bullet = load(BulletScenePath)
var ambience_sound_player : AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_sounds()
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

func _on_flash_timer_timeout():
	pass
	
func _on_weapon_shooting_signal(bullet_type:String, transform, spawning_point:Node3D):
	spawnBullet(spawning_point.global_position, transform, bullet_type)

func _on_explosion_signal(transform, bullet_type, body):
	if body is PhysicalBone3D : 
		# Could only be of our two grandpas
		var player = body
		while player != self and player != $"Player 1" and player != $"Player 2" :
			player = player.get_parent()
		
		player.get_hit(bullet_type, body, transform)
		

func find_chair(player):
	var chair = $"Chairs/Chair"
	var p1 = player.position - $"Chairs/Chair".position
	var p2 = player.position - $"Chairs/Chair2".position
	if p1 >= p2 :
		chair = $"Chairs/Chair2"
	player.gotoChair(chair)

func _on_player_1_find_chair(player):
	find_chair(player)

func _on_player_2_find_chair(player):
	find_chair(player)

func _on_chair_want_to_rest(body):
	var player = body
	while player.get_parent() != null and player != $"Player 1" and player != $"Player 2" :
		player = player.get_parent()
	if player.get_parent() == null and player != $"Player 1" and player != $"Player 2":
		return
	
	player.rest()

	
func _on_chair_stop_resting(body):
	var player = body
	while player.get_parent() != null and player != $"Player 1" and player != $"Player 2" :
		player = player.get_parent()
	if player.get_parent() == null and player != $"Player 1" and player != $"Player 2":
		return
	player.stop_resting()

func initialize_sounds():
	ambience_sound_player = $Sounds/WorldAmbienceSound
	ambience_sound_player.connect("finished", _on_ambience_sound_finished)
	ambience_sound_player.play()
	
func _on_ambience_sound_finished():
	ambience_sound_player.play()
