extends Control

var user_prefs: UserPreferences

var game_key

var http = HTTPClient.new() # Create the Client.
var err = 0
var headers = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	
# Called when the node enters the scene tree for the first time.
func _ready():
	user_prefs = UserPreferences.load_or_create()
	if user_prefs.user_name:
		$EnterNameLineEdit.text = user_prefs.user_name
		
	err = http.connect_to_host("https://valtonlobbycontainer.trueberryless.org", 80) # Connect to host/port.
	assert(err == OK) # Make sure connection is OK.

	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		print("Connecting...")

	assert(http.get_status() == HTTPClient.STATUS_CONNECTED) # Check if the connection was made successfully

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

func _on_host_session_button_pressed():
	$ButtonClickSound.play()
	get_tree().change_scene_to_file("res://UI/lobby_menu.tscn")

func _on_join_session_button_pressed():
	$ButtonClickSound.play()
	#TODO: join online lobby screen (use key for private lobby, leave blank for public lobby) 
	err = http.request(HTTPClient.METHOD_GET,"/JoinSession",headers,game_key)


func _on_enter_name_line_edit_text_changed(name_text):
	user_prefs.user_name = name_text
	user_prefs.save()


func _on_enter_key_line_edit_text_changed(new_text):
	if new_text.length() >= 6:
		game_key = new_text


