extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var round_label: Label = $RoundLabel
@onready var menu_button: Button = $MenuButton
@onready var pause_menu: Panel = $PauseMenu
@onready var lan_ip_label: Label = $PauseMenu/Box/LanIPLabel
@onready var return_button: Button = $PauseMenu/Box/ReturnButton
@onready var main_menu_button: Button = $PauseMenu/Box/MainMenuButton

var player: Node


func _ready() -> void:
	menu_button.pressed.connect(_open_pause_menu)
	return_button.pressed.connect(_return_to_game)
	main_menu_button.pressed.connect(_go_to_main_menu)
	pause_menu.visible = false
	_connect_round_counter()
	_connect_local_player()


func _process(_delta: float) -> void:
	var local_player := get_tree().get_first_node_in_group("LocalPlayer")
	if local_player and local_player != player:
		_connect_local_player()


func _connect_local_player() -> void:
	if player and player.has_signal("life_changed"):
		if player.life_changed.is_connected(_on_player_life_changed):
			player.life_changed.disconnect(_on_player_life_changed)

	player = get_tree().get_first_node_in_group("LocalPlayer")
	if not player:
		player = get_tree().get_first_node_in_group("Player")
	if player and player.has_signal("life_changed"):
		player.life_changed.connect(_on_player_life_changed)
		_on_player_life_changed(int(player.get("life")), int(player.get("max_life")))


func _on_player_life_changed(life: int, max_life: int) -> void:
	health_bar.max_value = max_life
	health_bar.value = life
	health_label.text = "Life: %d" % life


func _connect_round_counter() -> void:
	var settings := get_node_or_null("/root/GameSettings")
	if not settings:
		round_label.visible = false
		return

	round_label.visible = multiplayer.has_multiplayer_peer()
	if settings.has_signal("lan_rounds_changed") and not settings.lan_rounds_changed.is_connected(_on_lan_rounds_changed):
		settings.lan_rounds_changed.connect(_on_lan_rounds_changed)
	_on_lan_rounds_changed(int(settings.get("lan_rounds_played")), int(settings.get("lan_max_rounds")))


func _on_lan_rounds_changed(rounds_played: int, max_rounds: int) -> void:
	round_label.text = "%d/%d" % [rounds_played, max_rounds]


func _open_pause_menu() -> void:
	lan_ip_label.text = "WIFI Room: connected" if multiplayer.has_multiplayer_peer() else "WIFI Room: offline"
	pause_menu.visible = true


func _return_to_game() -> void:
	pause_menu.visible = false


func _go_to_main_menu() -> void:
	var peer := multiplayer.multiplayer_peer
	if peer:
		peer.close()
	multiplayer.multiplayer_peer = null

	var settings := get_node_or_null("/root/GameSettings")
	if settings:
		settings.call("reset_lan")

	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
