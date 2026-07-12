extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel

var player: Node


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player and player.has_signal("life_changed"):
		player.life_changed.connect(_on_player_life_changed)
		_on_player_life_changed(int(player.get("life")), int(player.get("max_life")))


func _on_player_life_changed(life: int, max_life: int) -> void:
	health_bar.max_value = max_life
	health_bar.value = life
	health_label.text = "Life: %d" % life
