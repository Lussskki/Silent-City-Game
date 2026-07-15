extends Area2D

@export var damage: int = 9999


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	if body.get("local_player") == false:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)
	else:
		get_tree().reload_current_scene()
