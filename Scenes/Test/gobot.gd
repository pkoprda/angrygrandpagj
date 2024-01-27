extends CharacterBody3D

var grabbed_object : RigidBody3D = null
var accel = 0.3
var friction = 0.5
var SPEED = 5.0
const MAX_ACCEL = Vector3(1,1,1)
const JUMP_VELOCITY = 4.5
const GRAB_DISTANCE = 1.5
var list_grabbable_obj = []

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var hands : Array[PhysicalBone3D]


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, friction)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, friction)
		if $AnimationPlayer.current_animation != "Run": 
			$AnimationPlayer.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, accel)
		velocity.z = move_toward(velocity.z, 0, accel)
		if $AnimationPlayer.current_animation != "Idle": 
			$AnimationPlayer.play("Idle")
	if grabbed_object != null:
		var result_force = Vector3.ZERO
		if velocity != Vector3.ZERO:
			result_force = velocity - grabbed_object.linear_velocity
		elif abs(position.distance_to(grabbed_object.position)) >= 0.5:
			result_force = -grabbed_object.linear_velocity * 0.4 + (position - grabbed_object.position)
		grabbed_object.apply_central_force(result_force)
		if position.distance_to(grabbed_object.position) <= GRAB_DISTANCE:
			#look_at(global_transform.origin - velocity, Vector3.UP)
			move_and_slide()
	else:
		
		move_and_slide()
	
	# Rotation part
	
func _process(delta):
	if Input.is_action_pressed("grab") and grabbed_object == null:
		grab()
	
	if Input.is_action_just_released("grab") and grabbed_object != null:
		release_grab()
	
func _on_grab_area_body_entered(body):
	if body is RigidBody3D:
		list_grabbable_obj.append(body)
		
func _on_grab_area_body_exited(body):
	if body in list_grabbable_obj:
		list_grabbable_obj.pop_at(list_grabbable_obj.find(body))

# Attempt to grab a RigidBody within the grab distance
func grab():
	if list_grabbable_obj.is_empty() : 
		return
	grabbed_object = list_grabbable_obj.pop_front() 
	accel = accel/2

# Release the currently grabbed RigidBody
func release_grab():
	grabbed_object = null
	accel = accel*2

#func glue_arms():
#	for b in hands : 
#		
