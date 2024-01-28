extends RigidBody3D

signal want_to_rest
signal stop_resting

func _on_area_3d_body_entered(body):
	emit_signal("want_to_rest", body)

func _on_area_3d_body_exited(body):
	print(body.name)
	emit_signal("stop_resting", body)
