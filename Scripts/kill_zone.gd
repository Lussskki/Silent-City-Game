extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	if not body.is_in_group("Player"):
		return
	if body.get("local_player") == false:
		return

	if body.has_method("take_damage"):
		body.take_damage(9999)
	else:
		timer.start()

func _on_timer_timeout() -> void:
	if multiplayer.has_multiplayer_peer():
		return
	get_tree().reload_current_scene()
