extends Node3D
@export var current_weapon:String = "BasicWeapon"

signal shooting_signal(bullet_type:String, spawning_direction:Vector3, spawning_point:Node3D)

@onready var shooting_data = {
	"BasicWeapon":{
		"child": $"BasicWeapon",
		"rate" : 1000, # in ms
		"bullets" : "BasicBullet",
		"impulse_strength" : 10
	}
}

var last_time = Time.get_ticks_msec()

# Called when the node enters the scene tree for the first time.
func _ready():
	shooting_data[current_weapon]["child"].show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shooting()

func shooting():
	if Time.get_ticks_msec() - last_time >= shooting_data[current_weapon]["rate"]:
		emit_signal("shooting_signal",
		shooting_data[current_weapon]["bullets"], 
		global_transform,
		shooting_data[current_weapon]["child"].get_node("SpawningPoint"))
		last_time = Time.get_ticks_msec()
		
