extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
    if body.is_in_group("Player"):
        print("You die")
        timer.start()

func _on_timer_timeout() -> void:
    get_tree().reload_current_scene()