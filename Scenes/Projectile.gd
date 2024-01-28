extends Area3D

signal exploded

@export var muzzle_velocity:int = 20
@export var g:Vector3 = -Vector3.DOWN * 9

var velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	emit_signal("exploded", transform, "BasicBullet", body)
	queue_free()

func _physics_process(delta):
	#look_at(global_position + velocity.normalized(), Vector3.UP)
	position += transform.basis * Vector3(0,0,muzzle_velocity) *delta

func _on_life_time_timeout():
	queue_free()
