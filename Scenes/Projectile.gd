extends Area3D

signal exploded

@export var muzzle_velocity:int = 25
@export var g:Vector3 = Vector3.DOWN * 20

var velocity = Vector3.ZERO

@export var Bullet : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	emit_signal("exploded", transform.origin)
	queue_free()
	print("Bullet collision")
	pass # Replace with function body.

func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta 
	pass


