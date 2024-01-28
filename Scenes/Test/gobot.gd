extends CharacterBody3D

@export var app_event_left = ''
@export var app_event_right = ''
@export var app_event_up = ''
@export var app_event_down = ''
@export var app_event_jump = ''
@export var app_event_grab = ''
@export var app_event_throw = ''

@export var color:Color

var stamina = 100
var stamine_charge_rate = 2
var MIN_STAMINA = 0
var MAX_STAMINA = 100

var grabbed_object = null
var accel = 0.3
var friction = 0.5
var SPEED = 5.0
const MAX_ACCEL = Vector3(1,1,1)
const JUMP_VELOCITY = 4.5
const GRAB_DISTANCE = 1
var list_grabbable_obj = []

signal findChair(player)

var resting = false
var gotochairstate = false
var closest_chair = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	var mat = ($Collision/Skeleton3D/Cube_010 as MeshInstance3D).mesh.surface_get_material(0)
	(mat as BaseMaterial3D).albedo_color = color
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction = null
	if ! gotochairstate: 
		#print("One")
		# Handle jump.
		if Input.is_action_just_pressed(app_event_jump) and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector(app_event_left, app_event_right, app_event_up, app_event_down)
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	else:
		direction =( transform.basis * (closest_chair.position - position)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, friction)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, friction)
		if $AnimationPlayer.current_animation != "walking": 
			$AnimationPlayer.play("walking")
	else:
		velocity.x = move_toward(velocity.x, 0, accel)
		velocity.z = move_toward(velocity.z, 0, accel)
		if $AnimationPlayer.current_animation != "idle": 
			$AnimationPlayer.play("idle")
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
	
	# Stamina
	if stamina <= MIN_STAMINA and !gotochairstate:
		stamina = MIN_STAMINA
		emit_signal("findChair", self)
	if character_is_moving():
		lower_stamina()
	if resting:
		if gotochairstate : 
			gotochairstate = false 
		stamina += 25*delta
		if stamina >= MAX_STAMINA:
			stamina = MAX_STAMINA
		$"SubViewport/StaminaBar3D".value = stamina

func _process(delta):
	if Input.is_action_just_released(app_event_grab) and $Collision/WpSlot.get_child_count() != 0:
		drop_weapon()
		return
	
	elif Input.is_action_pressed(app_event_grab) and grabbed_object == null:
		grab()
	
	elif Input.is_action_just_released(app_event_grab) and grabbed_object != null:
		release_grab()
	
	if Input.is_action_just_released(app_event_throw) and $Collision/WpSlot.get_child_count() != 0:
		shoot()
	
func _on_grab_area_body_entered(body):
	if body is RigidBody3D or body.is_in_group("weapons"):
		list_grabbable_obj.append(body)
		
func _on_grab_area_lbody_exited(body):
	if body in list_grabbable_obj:
		list_grabbable_obj.pop_at(list_grabbable_obj.find(body))

func drop_weapon():
	var wp = $Collision/WpSlot.get_child(0)
	var gp = wp.global_position
	
	$Collision/WpSlot.remove_child(wp)
	
	wp.queue_free()
	
func shoot():
	$Collision/WpSlot.get_child(0).shooting()

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

func add_weapon(wp):
	wp.get_parent().remove_child(wp)
	$Collision/WpSlot.add_child(wp)
	wp.transform.origin = Vector3.ZERO
	wp.rotation = Vector3.ZERO
	$ItemPickUp.play()

func lower_stamina():
	if Input.is_action_just_pressed(app_event_left) \
	or Input.is_action_just_pressed(app_event_right) \
	or Input.is_action_just_pressed(app_event_up) \
	or Input.is_action_just_pressed(app_event_down):
		stamina -= 1
	if Input.is_action_just_pressed(app_event_jump) and is_on_floor():
		stamina -= 3
	if Input.is_action_just_pressed(app_event_grab) \
	or Input.is_action_just_pressed(app_event_throw):
		#stamina -= 5
		pass
	$"SubViewport/StaminaBar3D".value = stamina

func character_is_moving():
	return  Input.is_action_just_pressed(app_event_left) \
	or		Input.is_action_just_pressed(app_event_right) \
	or		Input.is_action_just_pressed(app_event_up) \
	or		Input.is_action_just_pressed(app_event_down) \
	or		Input.is_action_just_pressed(app_event_jump) \
	or		Input.is_action_just_pressed(app_event_grab) \
	or		Input.is_action_just_pressed(app_event_throw)

func get_hit(bullet_type, impact_part, bullet_transform):
	stamina -= $"/root/Global".bullet_types[bullet_type]["damage"]
	$"SubViewport/StaminaBar3D".value = stamina
	
	impact_part.apply_impulse(bullet_transform.basis.z.normalized()*100,bullet_transform.origin - impact_part.transform.origin)
	$HitSound.play()

func rest():
	resting = true
	if gotochairstate : 
		gotochairstate = false
	#enable_collisions()

func stop_resting():
	resting = false

func gotoChair(chair):
	gotochairstate = true
	closest_chair = chair
	#disable_collisions()

func has_weapon(wp):
	return $Collision/WpSlot.get_child_count() != 0 and $Collision/WpSlot.get_child(0) != wp

#func disable_collisions():
#	for b in $"Collision/Skeleton3D".get_children():
#		if b is PhysicalBone3D:
#			b.set_collision_layer_value(3,false)
#			b.set_collision_layer_value(4,false)
#			b.set_collision_mask_value(1,false)
#	set_collision_layer_value(1,false)
#	set_collision_mask_value(1,false)
#	set_collision_layer_value(9,true)
#	set_collision_mask_value(9,true)
#	
#func enable_collisions():
#	for b in $"Collision/Skeleton3D".get_children():
#		if b is PhysicalBone3D:
#			b.set_collision_layer_value(3,true)
#			b.set_collision_layer_value(4,true)
#			b.set_collision_mask_value(1,true)
#			print(b)
#	set_collision_layer_value(9,false)
#	set_collision_mask_value(9,false)
#	set_collision_layer_value(1,true)
#	set_collision_mask_value(1,true)
	
