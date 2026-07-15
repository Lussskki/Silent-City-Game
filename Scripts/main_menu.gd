extends Control

const MAIN_SCENE := "res://Scenes/Main.tscn"
const MEDIUM_SCENE := "res://Scenes/MainMedium.tscn"
const HARD_SCENE := "res://Scenes/MainHard.tscn"
const LAN_PORT := 8910
const DISCOVERY_PORT := 8911
const DISCOVERY_MESSAGE := "SILENT_CITY_HOST"
const ROOM_NAME := "Silent City Room"
const MAX_ROOM_PLAYERS := 2
const LANG_ENG := "eng"
const LANG_GEO := "geo"
const CHARACTER_DISPLAY_NAMES := {
	"player": "Ash Golem",
	"golem": "Stone Golem"
}
const TEXT := {
	LANG_ENG: {
		"language_button": "GEO",
		"subtitle": "Choose your fight",
		"start": "Start",
		"choose_level": "Choose Level",
		"easy": "Easy",
		"medium": "Medium",
		"hard": "Hard",
		"choose_character": "Choose Character",
		"wifi_room": "WIFI Room",
		"exit": "Exit",
		"select": "Select",
		"choose_first": "Choose a character before starting.",
		"start_game": "Start Game",
		"back": "Back",
		"host_room": "Host Room",
		"join": "Join",
		"start_wifi_room": "Start WIFI Room",
		"tutorial_title": "WIFI Room Tutorial",
		"skip": "Skip",
		"next": "Next",
		"done": "Done",
		"selected_lan": "Selected: %s. Press Start Game to enter room.",
		"selected": "Selected: %s",
		"host_failed": "Host failed: %s",
		"room_open": "Room is open. Other devices can pick it from the list.",
		"hosting_device": "This device is hosting. Use another device to join.",
		"no_room_selected": "No room selected. Host a room or wait for one to appear.",
		"join_failed": "Join failed: %s",
		"joining": "Joining room...",
		"connected_choose": "Connected. Choose your character.",
		"waiting_for_host_start": "Character selected. Waiting for host to start.",
		"waiting_for_player_choice": "Waiting for the other player to choose a character.",
		"player_connected": "Player connected.\nPress Start WIFI Room.",
		"room_waiting": "Room is open. Waiting for players.",
		"connection_failed": "Connection failed",
		"lan_status_default": "Host a room or choose one from the list.",
		"discovery_failed": "Discovery failed: %s",
		"search_failed": "Could not search for rooms.",
		"searching": "Searching for WIFI rooms...",
		"room_found": "Room found. Select it and press Join.",
		"no_rooms": "No rooms found",
		"room_players": "%s - %d/%d players"
	},
	LANG_GEO: {
		"language_button": "ENG",
		"subtitle": "აირჩიე ბრძოლა",
		"start": "დაწყება",
		"choose_character": "პერსონაჟი",
		"wifi_room": "WIFI ოთახი",
		"exit": "გასვლა",
		"select": "არჩევა",
		"choose_first": "ჯერ აირჩიე პერსონაჟი.",
		"start_game": "თამაშის დაწყება",
		"back": "უკან",
		"host_room": "ოთახის გახსნა",
		"join": "შესვლა",
		"start_wifi_room": "WIFI ოთახის დაწყება",
		"tutorial_title": "WIFI ოთახის სწავლება",
		"skip": "გამოტოვება",
		"next": "შემდეგი",
		"done": "მზადაა",
		"selected_lan": "არჩეულია: %s. დააჭირე თამაშის დაწყებას.",
		"selected": "არჩეულია: %s",
		"host_failed": "ოთახი ვერ გაიხსნა: %s",
		"room_open": "ოთახი გახსნილია. სხვა მოწყობილობა სიიდან აირჩევს.",
		"hosting_device": "ეს მოწყობილობა მასპინძლობს. შესასვლელად გამოიყენე მეორე მოწყობილობა.",
		"no_room_selected": "ოთახი არჩეული არ არის. გახსენი ოთახი ან დაელოდე.",
		"join_failed": "შესვლა ვერ მოხერხდა: %s",
		"joining": "ოთახში შესვლა...",
		"connected_choose": "დაკავშირებულია. აირჩიე პერსონაჟი.",
		"player_connected": "მოთამაშე შემოვიდა.\nდააჭირე WIFI ოთახის დაწყებას.",
		"room_waiting": "ოთახი გახსნილია. ველოდებით მოთამაშეებს.",
		"connection_failed": "კავშირი ვერ მოხერხდა",
		"lan_status_default": "გახსენი ოთახი ან აირჩიე სიიდან.",
		"discovery_failed": "ძებნა ვერ ჩაირთო: %s",
		"search_failed": "ოთახების ძებნა ვერ მოხერხდა.",
		"searching": "WIFI ოთახების ძებნა...",
		"room_found": "ოთახი ნაპოვნია. აირჩიე და დააჭირე შესვლას.",
		"no_rooms": "ოთახები არ არის",
		"room_players": "%s - %d/%d მოთამაშე"
	}
}
const LAN_TUTORIAL_STEPS := {
	LANG_ENG: [
		"Host opens a room.",
		"Join picks the room.",
		"Choose character, then start."
	],
	LANG_GEO: [
		"მასპინძელი ხსნის ოთახს.",
		"მეორე მოთამაშე ირჩევს ოთახს.",
		"აირჩიე პერსონაჟი და დაიწყე."
	]
}

@onready var pages: Control = $Content/Root/Pages
@onready var language_button: Button = $LanguageButton
@onready var subtitle_label: Label = $Content/Root/Subtitle
@onready var home_page: VBoxContainer = $Content/Root/Pages/Home
@onready var level_page: VBoxContainer = $Content/Root/Pages/ChooseLevel
@onready var choose_page: VBoxContainer = $Content/Root/Pages/ChooseCharacter
@onready var lan_page: VBoxContainer = $Content/Root/Pages/Lan
@onready var home_start_button: Button = $Content/Root/Pages/Home/StartButton
@onready var home_choose_button: Button = $Content/Root/Pages/Home/ChooseButton
@onready var home_lan_button: Button = $Content/Root/Pages/Home/LanButton
@onready var home_exit_button: Button = $Content/Root/Pages/Home/ExitButton
@onready var level_header: Label = $Content/Root/Pages/ChooseLevel/Header
@onready var easy_button: Button = $Content/Root/Pages/ChooseLevel/EasyButton
@onready var medium_button: Button = $Content/Root/Pages/ChooseLevel/MediumButton
@onready var hard_button: Button = $Content/Root/Pages/ChooseLevel/HardButton
@onready var level_back_button: Button = $Content/Root/Pages/ChooseLevel/BackButton
@onready var choose_header: Label = $Content/Root/Pages/ChooseCharacter/Header
@onready var player_card: PanelContainer = $Content/Root/Pages/ChooseCharacter/Cards/PlayerCard
@onready var golem_card: PanelContainer = $Content/Root/Pages/ChooseCharacter/Cards/GolemCard
@onready var player_select_button: Button = $Content/Root/Pages/ChooseCharacter/Cards/PlayerCard/Box/SelectButton
@onready var golem_select_button: Button = $Content/Root/Pages/ChooseCharacter/Cards/GolemCard/Box/SelectButton
@onready var character_status: Label = $Content/Root/Pages/ChooseCharacter/StatusLabel
@onready var choose_start_button: Button = $Content/Root/Pages/ChooseCharacter/StartButton
@onready var choose_lan_button: Button = $Content/Root/Pages/ChooseCharacter/LanButton
@onready var choose_back_button: Button = $Content/Root/Pages/ChooseCharacter/BackButton
@onready var lan_tutorial_overlay: Control = $Content/Root/Pages/TutorialOverlay
@onready var lan_tutorial_title: Label = $Content/Root/Pages/TutorialOverlay/Card/Box/Title
@onready var lan_tutorial_text: Label = $Content/Root/Pages/TutorialOverlay/Card/Box/Text
@onready var lan_tutorial_next: Button = $Content/Root/Pages/TutorialOverlay/Card/Box/Buttons/NextButton
@onready var lan_tutorial_skip: Button = $Content/Root/Pages/TutorialOverlay/Card/Box/Buttons/SkipButton
@onready var lan_tutorial_back: Button = $Content/Root/Pages/TutorialOverlay/Card/Box/Buttons/BackButton
@onready var room_list: ItemList = $Content/Root/Pages/Lan/RoomBox/RoomList
@onready var lan_header: Label = $Content/Root/Pages/Lan/Header
@onready var lan_status: Label = $Content/Root/Pages/Lan/StatusLabel
@onready var host_button: Button = $Content/Root/Pages/Lan/Buttons/HostButton
@onready var join_button: Button = $Content/Root/Pages/Lan/Buttons/JoinButton
@onready var lan_start_button: Button = $Content/Root/Pages/Lan/StartLanButton
@onready var lan_back_button: Button = $Content/Root/Pages/Lan/BackButton

var discovery_udp: PacketPeerUDP
var broadcast_timer := 0.0
var discovered_rooms := {}
var hosted_player_count := 1
var hosted_room_id := ""
var selected_room_key := ""
var joined_room_waiting_for_character := false
var lan_tutorial_step := 0
var remote_client_character := "golem"
var remote_client_character_chosen := false


func _ready() -> void:
	_setup_language()
	language_button.pressed.connect(_toggle_language)
	home_start_button.pressed.connect(_open_start_flow)
	home_choose_button.pressed.connect(func(): _show_page(choose_page))
	home_lan_button.pressed.connect(_open_lan_page)
	home_exit_button.pressed.connect(_exit_game)
	easy_button.pressed.connect(func(): _select_level("easy"))
	medium_button.pressed.connect(func(): _select_level("medium"))
	hard_button.pressed.connect(func(): _select_level("hard"))
	level_back_button.pressed.connect(func(): _show_page(home_page))
	player_select_button.pressed.connect(func(): _select_character("player"))
	golem_select_button.pressed.connect(func(): _select_character("golem"))
	_make_character_card_tappable(player_card, "player")
	_make_character_card_tappable(golem_card, "golem")
	player_select_button.visible = true
	golem_select_button.visible = true
	choose_start_button.pressed.connect(_start_game)
	choose_lan_button.pressed.connect(_open_lan_page)
	choose_back_button.pressed.connect(_back_from_character_page)
	host_button.pressed.connect(_host_lan_game)
	join_button.pressed.connect(_join_lan_game)
	room_list.item_selected.connect(_select_room_from_list)
	room_list.item_activated.connect(_activate_room_from_list)
	lan_start_button.pressed.connect(_start_lan_host_game)
	lan_tutorial_next.pressed.connect(_advance_lan_tutorial)
	lan_tutorial_skip.pressed.connect(_finish_lan_tutorial)
	lan_tutorial_back.pressed.connect(_back_from_lan)
	lan_back_button.pressed.connect(_back_from_lan)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	_apply_language()
	_update_character_cards()
	_update_wifi_room_text()
	lan_start_button.visible = false
	_update_room_buttons()
	_show_page(home_page)


func _process(delta: float) -> void:
	_poll_lan_discovery(delta)


func _setup_language() -> void:
	var settings := _settings()
	if settings and not [LANG_ENG, LANG_GEO].has(String(settings.get("language"))):
		settings.set("language", LANG_ENG)


func _language() -> String:
	var settings := _settings()
	if settings:
		var language := String(settings.get("language"))
		if [LANG_ENG, LANG_GEO].has(language):
			return language
	return LANG_ENG


func _t(key: String) -> String:
	var language := _language()
	var table: Dictionary = TEXT.get(language, TEXT[LANG_ENG])
	return String(table.get(key, TEXT[LANG_ENG].get(key, key)))


func _toggle_language() -> void:
	var settings := _settings()
	if settings:
		var next_language := LANG_GEO
		if _language() == LANG_GEO:
			next_language = LANG_ENG
		settings.set("language", next_language)
	_apply_language()
	_update_character_cards()
	_refresh_room_list()


func _apply_language() -> void:
	language_button.text = _t("language_button")
	subtitle_label.text = _t("subtitle")
	home_start_button.text = _t("start")
	home_choose_button.text = _t("choose_character")
	home_lan_button.text = _t("wifi_room")
	home_exit_button.text = _t("exit")
	level_header.text = _t("choose_level")
	easy_button.text = _t("easy")
	medium_button.text = _t("medium")
	hard_button.text = _t("hard")
	level_back_button.text = _t("back")
	choose_header.text = _t("choose_character")
	player_select_button.text = _t("select")
	golem_select_button.text = _t("select")
	choose_start_button.text = _t("start_game")
	choose_lan_button.text = _t("wifi_room")
	choose_back_button.text = _t("back")
	lan_header.text = _t("wifi_room")
	host_button.text = _t("host_room")
	join_button.text = _t("join")
	lan_start_button.text = _t("start_wifi_room")
	lan_back_button.text = _t("back")
	lan_tutorial_title.text = _t("tutorial_title")
	lan_tutorial_back.text = _t("back")
	lan_tutorial_skip.text = _t("skip")
	_update_lan_tutorial()


func _show_page(page: Control) -> void:
	for child in pages.get_children():
		if child is Control:
			child.visible = child == page


func _exit_game() -> void:
	_stop_lan_discovery()
	_clear_peer()
	get_tree().quit()


func _open_lan_page() -> void:
	_update_wifi_room_text()
	_start_discovery_listener()
	_show_page(lan_page)
	_show_lan_tutorial_once()


func _open_start_flow() -> void:
	_show_page(level_page)


func _select_level(level: String) -> void:
	var settings := _settings()
	if settings:
		settings.set("selected_level", level)
		settings.set("level_chosen", true)
	_show_page(choose_page)


func _show_lan_tutorial_once() -> void:
	var settings := _settings()
	if settings and settings.get("lan_tutorial_seen") == true:
		lan_tutorial_overlay.visible = false
		return

	lan_tutorial_step = 0
	lan_tutorial_overlay.visible = true
	_update_lan_tutorial()


func _update_lan_tutorial() -> void:
	var steps: Array = LAN_TUTORIAL_STEPS.get(_language(), LAN_TUTORIAL_STEPS[LANG_ENG])
	lan_tutorial_text.text = String(steps[lan_tutorial_step])
	lan_tutorial_next.text = _t("done") if lan_tutorial_step >= steps.size() - 1 else _t("next")


func _advance_lan_tutorial() -> void:
	var steps: Array = LAN_TUTORIAL_STEPS.get(_language(), LAN_TUTORIAL_STEPS[LANG_ENG])
	if lan_tutorial_step >= steps.size() - 1:
		_finish_lan_tutorial()
		return

	lan_tutorial_step += 1
	_update_lan_tutorial()


func _finish_lan_tutorial() -> void:
	var settings := _settings()
	if settings:
		settings.set("lan_tutorial_seen", true)
	lan_tutorial_overlay.visible = false


func _back_from_character_page() -> void:
	if joined_room_waiting_for_character:
		var settings := _settings()
		if settings:
			settings.call("reset_lan")
			settings.set("character_chosen", false)
		_clear_peer()
		joined_room_waiting_for_character = false
		_show_page(home_page)
		return

	_show_page(home_page)


func _select_character(character: String) -> void:
	if _is_lan_character_locked():
		return

	var settings := _settings()
	if settings:
		settings.set("selected_character", character)
		settings.set("character_chosen", true)
	var character_name := String(CHARACTER_DISPLAY_NAMES.get(character, "Ash Golem"))
	if joined_room_waiting_for_character:
		_lock_lan_character_selection()
		if _is_joining_room():
			rpc_id(1, "_client_lan_character_selected", character)
			character_status.text = _t("waiting_for_host_start")
			lan_status.text = _t("waiting_for_host_start")
		else:
			character_status.text = _t("selected_lan") % character_name
			lan_status.text = _t("selected_lan") % character_name
		joined_room_waiting_for_character = false
		_show_page(lan_page)
	else:
		character_status.text = _t("selected") % character_name
	_update_character_cards()
	_update_room_buttons()


func _make_character_card_tappable(card: Control, character: String) -> void:
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(event: InputEvent): _select_character_from_card_input(event, character))
	for child in card.find_children("*", "Control"):
		var control := child as Control
		control.mouse_filter = Control.MOUSE_FILTER_PASS
		control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _select_character_from_card_input(event: InputEvent, character: String) -> void:
	if _is_lan_character_locked():
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_select_character(character)
			accept_event()
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			_select_character(character)
			accept_event()


func _update_character_cards() -> void:
	player_card.modulate = Color(1.0, 1.0, 1.0)
	golem_card.modulate = Color(1.0, 1.0, 1.0)
	var settings := _settings()
	if not settings or settings.get("character_chosen") != true:
		character_status.text = _t("choose_first")
		_set_character_buttons_enabled(true)
		return
	if String(settings.get("selected_character")) == "golem":
		golem_card.modulate = Color(0.65, 1.0, 0.65)
	else:
		player_card.modulate = Color(0.65, 1.0, 0.65)
	_set_character_buttons_enabled(not _is_lan_character_locked())


func _start_game() -> void:
	var settings := _settings()
	if not settings or settings.get("character_chosen") != true:
		character_status.text = _t("choose_first")
		return

	if settings.get("lan_mode") == true:
		if String(settings.get("lan_role")) == "host":
			_start_lan_host_game()
		elif String(settings.get("lan_role")) == "client":
			character_status.text = _t("waiting_for_host_start")
		return

	settings.call("reset_lan")
	_clear_peer()
	get_tree().change_scene_to_file(_selected_main_scene())


func _selected_main_scene() -> String:
	var settings := _settings()
	if settings:
		var selected_level := String(settings.get("selected_level"))
		if selected_level == "hard":
			return HARD_SCENE
		if selected_level == "medium":
			return MEDIUM_SCENE
	return MAIN_SCENE


func _host_lan_game() -> void:
	if _is_hosting_room():
		return

	_clear_peer()
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(LAN_PORT, 1)
	if error != OK:
		lan_status.text = _t("host_failed") % _error_message(error)
		return

	var settings := _settings()
	if settings:
		settings.set("lan_mode", true)
		settings.set("lan_role", "host")
		settings.set("character_chosen", false)
		if settings.has_method("reset_lan_rounds"):
			settings.reset_lan_rounds()
	multiplayer.multiplayer_peer = peer
	hosted_player_count = 1
	hosted_room_id = _make_room_id()
	selected_room_key = ""
	remote_client_character = "golem"
	remote_client_character_chosen = false
	_start_host_broadcast()
	_refresh_room_list()
	lan_status.text = _t("room_open")
	lan_start_button.visible = true
	_update_room_buttons()
	joined_room_waiting_for_character = true
	character_status.text = _t("connected_choose")
	_update_character_cards()
	_show_page(choose_page)


func _start_lan_host_game() -> void:
	var settings := _settings()
	if settings and settings.get("lan_mode") == true and String(settings.get("lan_role")) == "host":
		if settings.get("character_chosen") != true:
			joined_room_waiting_for_character = true
			character_status.text = _t("connected_choose")
			_update_character_cards()
			_show_page(choose_page)
			return
		if multiplayer.get_peers().is_empty():
			lan_status.text = _t("room_waiting")
			_show_page(lan_page)
			return
		if not remote_client_character_chosen:
			character_status.text = _t("waiting_for_player_choice")
			lan_status.text = _t("waiting_for_player_choice")
			_show_page(lan_page)
			return
		_stop_lan_discovery()
		rpc("_start_lan_match")
		get_tree().change_scene_to_file(MAIN_SCENE)


func _join_lan_game() -> void:
	if _is_hosting_room():
		lan_status.text = _t("hosting_device")
		return

	var address := _get_selected_room_address()
	if String(address["ip"]).is_empty():
		lan_status.text = _t("no_room_selected")
		return

	_stop_lan_discovery()
	_clear_peer()
	host_button.disabled = true
	join_button.disabled = true
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address["ip"], address["port"])
	if error != OK:
		lan_status.text = _t("join_failed") % _error_message(error)
		_start_discovery_listener()
		_update_room_buttons()
		return

	var settings := _settings()
	if settings:
		settings.set("lan_mode", true)
		settings.set("lan_role", "client")
		settings.set("character_chosen", false)
		if settings.has_method("reset_lan_rounds"):
			settings.reset_lan_rounds()
	multiplayer.multiplayer_peer = peer
	remote_client_character = "golem"
	remote_client_character_chosen = false
	lan_status.text = _t("joining")


func _on_connected_to_server() -> void:
	var settings := _settings()
	if settings and settings.get("lan_mode") == true and String(settings.get("lan_role")) == "client":
		_stop_lan_discovery()
		joined_room_waiting_for_character = true
		settings.set("character_chosen", false)
		character_status.text = _t("connected_choose")
		_update_character_cards()
		_show_page(choose_page)


func _on_peer_connected(peer_id: int) -> void:
	var settings := _settings()
	if settings and settings.get("lan_mode") == true and String(settings.get("lan_role")) == "host":
		hosted_player_count = min(multiplayer.get_peers().size() + 1, MAX_ROOM_PLAYERS)
		remote_client_character_chosen = false
		_refresh_room_list()
		lan_status.text = _t("player_connected")
		_update_room_buttons()


func _on_peer_disconnected(_peer_id: int) -> void:
	var settings := _settings()
	if settings and settings.get("lan_mode") == true and String(settings.get("lan_role")) == "host":
		hosted_player_count = min(multiplayer.get_peers().size() + 1, MAX_ROOM_PLAYERS)
		remote_client_character_chosen = false
		_refresh_room_list()
		lan_status.text = _t("room_waiting")
		_update_room_buttons()


func _on_connection_failed() -> void:
	lan_status.text = _t("connection_failed")
	var settings := _settings()
	if settings:
		settings.call("reset_lan")
	_clear_peer()
	lan_start_button.visible = false
	_start_discovery_listener()
	_update_room_buttons()


func _back_from_lan() -> void:
	var settings := _settings()
	if settings:
		settings.call("reset_lan")
	_stop_lan_discovery()
	_clear_peer()
	hosted_player_count = 1
	hosted_room_id = ""
	selected_room_key = ""
	joined_room_waiting_for_character = false
	remote_client_character = "golem"
	remote_client_character_chosen = false
	lan_start_button.visible = false
	lan_status.text = _t("lan_status_default")
	_update_room_buttons()
	_show_page(home_page)


func _update_wifi_room_text() -> void:
	lan_status.text = _t("lan_status_default")
	_refresh_room_list()
	_update_room_buttons()


func _clear_peer() -> void:
	var peer := multiplayer.multiplayer_peer
	if peer:
		peer.close()
	multiplayer.multiplayer_peer = null


func _start_host_broadcast() -> void:
	_stop_lan_discovery()
	discovery_udp = PacketPeerUDP.new()
	discovery_udp.set_broadcast_enabled(true)
	var error := discovery_udp.set_dest_address("255.255.255.255", DISCOVERY_PORT)
	if error != OK:
		lan_status.text = _t("discovery_failed") % _error_message(error)
		return
	broadcast_timer = 0.0


func _start_discovery_listener() -> void:
	var settings := _settings()
	if settings and settings.get("lan_role") == "host":
		return
	_stop_lan_discovery()
	discovered_rooms.clear()
	selected_room_key = ""
	_refresh_room_list()
	discovery_udp = PacketPeerUDP.new()
	var error := discovery_udp.bind(DISCOVERY_PORT)
	if error != OK:
		lan_status.text = _t("search_failed")
		return
	lan_status.text = _t("searching")


func _stop_lan_discovery() -> void:
	if discovery_udp:
		discovery_udp.close()
	discovery_udp = null
	broadcast_timer = 0.0


func _poll_lan_discovery(delta: float) -> void:
	if not discovery_udp:
		return

	var settings := _settings()
	if settings and settings.get("lan_role") == "host":
		broadcast_timer -= delta
		if broadcast_timer <= 0.0:
			var message := "%s|%s|%d|%d|%d|%s" % [DISCOVERY_MESSAGE, ROOM_NAME, LAN_PORT, hosted_player_count, MAX_ROOM_PLAYERS, hosted_room_id]
			discovery_udp.put_packet(message.to_utf8_buffer())
			broadcast_timer = 0.75
		return

	while discovery_udp.get_available_packet_count() > 0:
		var sender_ip := discovery_udp.get_packet_ip()
		var text := discovery_udp.get_packet().get_string_from_utf8()
		if not text.begins_with(DISCOVERY_MESSAGE):
			continue
		var parts := text.split("|", false)
		var room_name := ROOM_NAME
		var port := LAN_PORT
		var players := 1
		var max_players := MAX_ROOM_PLAYERS
		var room_id := ""
		if parts.size() >= 2 and not String(parts[1]).is_empty():
			room_name = String(parts[1])
		if parts.size() >= 3 and String(parts[2]).is_valid_int():
			port = int(parts[2])
		if parts.size() >= 4 and String(parts[3]).is_valid_int():
			players = int(parts[3])
		if parts.size() >= 5 and String(parts[4]).is_valid_int():
			max_players = int(parts[4])
		if parts.size() >= 6:
			room_id = String(parts[5])

		var room_key := room_id if not room_id.is_empty() else "%s:%d:%s" % [room_name, port, DISCOVERY_MESSAGE]
		discovered_rooms[room_key] = {
			"key": room_key,
			"name": room_name,
			"ip": sender_ip,
			"port": port,
			"players": players,
			"max_players": max_players,
			"room_id": room_id
		}
		_refresh_room_list()
		lan_status.text = _t("room_found")
		_update_room_buttons()


func _settings() -> Node:
	return get_node_or_null("/root/GameSettings")


func _get_selected_room_address() -> Dictionary:
	var result := {
		"ip": "",
		"port": LAN_PORT
	}
	if not selected_room_key.is_empty() and discovered_rooms.has(selected_room_key):
		var selected_room: Dictionary = discovered_rooms[selected_room_key]
		result["ip"] = String(selected_room.get("ip", ""))
		result["port"] = int(selected_room.get("port", LAN_PORT))
		return result

	var selected_items := room_list.get_selected_items()
	if selected_items.is_empty() and discovered_rooms.size() == 1:
		var only_room_key: String = String(discovered_rooms.keys()[0])
		selected_room_key = only_room_key
	elif selected_items.is_empty():
		return result
	else:
		_select_room_from_list(selected_items[0])

	if not selected_room_key.is_empty() and discovered_rooms.has(selected_room_key):
		var room: Dictionary = discovered_rooms[selected_room_key]
		result["ip"] = String(room.get("ip", ""))
		result["port"] = int(room.get("port", LAN_PORT))
	return result


func _select_room_from_list(index: int) -> void:
	var metadata = room_list.get_item_metadata(index)
	if metadata is Dictionary:
		selected_room_key = String(metadata.get("key", ""))


func _activate_room_from_list(index: int) -> void:
	_select_room_from_list(index)
	_join_lan_game()


func _refresh_room_list() -> void:
	if not room_list:
		return

	room_list.clear()
	if _is_hosting_room():
		var index := room_list.item_count
		room_list.add_item(_t("room_players") % [ROOM_NAME, hosted_player_count, MAX_ROOM_PLAYERS])
		room_list.set_item_selectable(index, false)
		room_list.set_item_metadata(index, {
			"key": hosted_room_id,
			"name": ROOM_NAME,
			"ip": "",
			"port": LAN_PORT,
			"players": hosted_player_count,
			"max_players": MAX_ROOM_PLAYERS
		})
		return

	for room_key in discovered_rooms:
		var room: Dictionary = discovered_rooms[room_key]
		var index := room_list.item_count
		room_list.add_item(_t("room_players") % [
			String(room.get("name", ROOM_NAME)),
			int(room.get("players", 1)),
			int(room.get("max_players", MAX_ROOM_PLAYERS))
		])
		room_list.set_item_metadata(index, room)
		if String(room.get("key", "")) == selected_room_key:
			room_list.select(index)

	if room_list.item_count == 0:
		room_list.add_item(_t("no_rooms"))
		room_list.set_item_disabled(0, true)
	elif selected_room_key.is_empty() or not discovered_rooms.has(selected_room_key):
		var first_room_key: String = String(discovered_rooms.keys()[0])
		selected_room_key = first_room_key
		room_list.select(0)

	_update_room_buttons()


func _is_hosting_room() -> bool:
	var settings := _settings()
	return settings and settings.get("lan_mode") == true and String(settings.get("lan_role")) == "host"


func _is_joining_room() -> bool:
	var settings := _settings()
	return settings and settings.get("lan_mode") == true and String(settings.get("lan_role")) == "client"


func _update_room_buttons() -> void:
	if not host_button or not join_button or not lan_start_button:
		return

	var hosting := _is_hosting_room()
	var joining := _is_joining_room()
	host_button.disabled = hosting or joining
	join_button.disabled = hosting or joining or discovered_rooms.is_empty()
	lan_start_button.visible = hosting
	if hosting:
		var settings := _settings()
		lan_start_button.disabled = not settings or settings.get("character_chosen") != true or multiplayer.get_peers().is_empty() or not remote_client_character_chosen


func _lock_lan_character_selection() -> void:
	_set_character_buttons_enabled(false)


func _set_character_buttons_enabled(enabled: bool) -> void:
	player_select_button.disabled = not enabled
	golem_select_button.disabled = not enabled
	player_card.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	golem_card.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE


func _is_lan_character_locked() -> bool:
	var settings := _settings()
	return joined_room_waiting_for_character and settings and settings.get("lan_mode") == true and settings.get("character_chosen") == true


@rpc("any_peer", "reliable")
func _client_lan_character_selected(character: String) -> void:
	if not _is_hosting_room():
		return

	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id == 0 or not multiplayer.get_peers().has(sender_id):
		return

	remote_client_character = character
	remote_client_character_chosen = true
	var settings := _settings()
	if settings:
		settings.set("lan_remote_character", character)
	lan_status.text = _t("player_connected")
	_update_room_buttons()


@rpc("authority", "reliable")
func _start_lan_match() -> void:
	var settings := _settings()
	if settings:
		settings.set("character_chosen", true)
	_stop_lan_discovery()
	joined_room_waiting_for_character = false
	get_tree().change_scene_to_file(MAIN_SCENE)


func _make_room_id() -> String:
	return "%d-%d" % [Time.get_ticks_msec(), randi()]


func _error_message(error: int) -> String:
	if error == ERR_CANT_CREATE:
		return "20 no network permission/port busy"
	return str(error)
