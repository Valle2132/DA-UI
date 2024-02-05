extends Control

var user_prefs: UserPreferences

var game_key




# Called when the node enters the scene tree for the first time.
func _ready():
	user_prefs = UserPreferences.load_or_create()
	if user_prefs.user_name:
		$EnterNameLineEdit.text = user_prefs.user_name

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_return_button_mouse_entered():
	$ButtonHoverSound.play()

func _on_return_button_pressed():
	$ButtonClickSound.play()
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_local_session_button_mouse_entered():
	$ButtonHoverSound.play()

func _on_host_session_button_mouse_entered():
	$ButtonHoverSound.play()

func _on_join_session_button_mouse_entered():
	$ButtonHoverSound.play()
	
# --------------------------------------------------------------------

func _on_local_session_button_pressed():
	$ButtonClickSound.play()
	get_tree().change_scene_to_file("res://UI/lobby_menu.tscn")
	LobbyType.lobby_owner = true
	
func _on_host_session_button_pressed():
	$ButtonClickSound.play()
	get_tree().change_scene_to_file("res://UI/lobby_menu.tscn")
	LobbyType.lobby_owner = true

func _on_join_session_button_pressed():
	$ButtonClickSound.play()
	#TODO: join online lobby screen (use key for private lobby, leave blank for public lobby) 
	get_tree().change_scene_to_file("res://UI/lobby_menu.tscn")
	LobbyType.lobby_owner = false

func _on_enter_name_line_edit_text_changed(name_text):
	user_prefs.user_name = name_text
	user_prefs.save()


func _on_enter_key_line_edit_text_changed(new_text):
	if new_text.length() >= 6:
		game_key = new_text


