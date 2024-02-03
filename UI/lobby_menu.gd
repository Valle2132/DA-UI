extends Control

var user_prefs: UserPreferences

enum Fractions {
	STARSERAPHS,
	OLYMPUS,
	DARKTEMPLARS
}

var chosen_fraction

var http = HTTPClient.new() # Create the Client.
var err = 0
var headers = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	
var game_key

# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_code()
		
	$PrivateButton.button_pressed = true
	user_prefs = UserPreferences.load_or_create()
	$Player1LineEdit.text = user_prefs.user_name
	
	if user_prefs.user_name == "":
		$Player1LineEdit.text = "Player1"
		
		#TODO: player2.name == "":
	if $Player2LineEdit.text == "":
		$Player2LineEdit.text = "Player2"
	#if user_prefs.user_name:
		#text = user_prefs.user_name
		# TODO: spielername zu spielerliste hinzufügen
	# TODO: verbinden mit container + code + socket
	
	err = http.connect_to_host("https://valtonlobbycontainer.trueberryless.org", 80) # Connect to host/port.
	assert(err == OK) # Make sure connection is OK.

	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		print("Connecting...")

	assert(http.get_status() == HTTPClient.STATUS_CONNECTED) # Check if the connection was made successfully.

	var headers = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	err = http.request(HTTPClient.METHOD_POST,"/StartSession",headers,game_key)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_return_button_pressed():
	$ButtonClickSound.play()
	# leave lobby if guest
	# close lobby if host
	# return to play menu
	get_tree().change_scene_to_file("res://UI/play_menu.tscn")

func _on_return_button_mouse_entered():
	$ButtonHoverSound.play()

# Ready Button
func _on_game_start_button_pressed():
	$ButtonClickSound.play()

func _on_game_start_button_mouse_entered():
	$ButtonHoverSound.play()


func _on_game_start_button_toggled(toggled_on):
	if toggled_on:
		$GameStartButton.text = "Ready!"
		# TODO: if both players are ready the game can start after [time]
		# TODO: method_name(chosen_fraction, player1, player2)
	else:
		$GameStartButton.text = "Ready?"


func _on_choose_star_seraphs_button_toggled(toggled_on):
	$GameStartButton.disabled = false
	if toggled_on:
		$ChooseFraction/ChooseStarSeraphsButton.scale = Vector2(2.2, 2.2)
		$ChooseFraction/ChooseStarSeraphsButton.position = Vector2(1490, 700)
		chosen_fraction = Fractions.STARSERAPHS
	else:
		$ChooseFraction/ChooseStarSeraphsButton.scale = Vector2(2, 2)
		$ChooseFraction/ChooseStarSeraphsButton.position = Vector2(1500, 710)


func _on_choose_olympus_button_toggled(toggled_on):
	$GameStartButton.disabled = false
	if toggled_on:
		$ChooseFraction/ChooseOlympusButton.scale = Vector2(2.2, 2.2)
		$ChooseFraction/ChooseOlympusButton.position = Vector2(1490, 476)
		chosen_fraction = Fractions.OLYMPUS
	else:
		$ChooseFraction/ChooseOlympusButton.scale = Vector2(2, 2)
		$ChooseFraction/ChooseOlympusButton.position = Vector2(1500, 486)


func _on_choose_dark_templars_button_toggled(toggled_on):
	$GameStartButton.disabled = false
	if toggled_on:
		$ChooseFraction/ChooseDarkTemplarsButton.scale = Vector2(2.2, 2.2)
		$ChooseFraction/ChooseDarkTemplarsButton.position = Vector2(1490, 250)
		chosen_fraction = Fractions.DARKTEMPLARS
	else:
		$ChooseFraction/ChooseDarkTemplarsButton.scale = Vector2(2, 2)
		$ChooseFraction/ChooseDarkTemplarsButton.position = Vector2(1500, 260)

func _generate_code():
	var random = RandomNumberGenerator.new()
	var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var code_array = []
	var code_length = 6

	for i in range(code_length):
		var random_index = random.randi_range(0, characters.length() - 1)
		code_array.append(characters[random_index])

	game_key = "".join(code_array)
	$GeneratedKeyLineEdit.text = game_key
	# TODO: send key to server

func _on_copy_key_button_pressed():
	DisplayServer.clipboard_set($GeneratedKeyLineEdit.text)

func _on_public_button_toggled(toggled_on):
	if toggled_on:
		$CopyKeyButton.hide()
		$GeneratedKeyLineEdit.text = ""
		$PublicButton.scale = Vector2(1.1, 1.1)
		$PublicButton.position = Vector2(645, 155)
		err = http.request(HTTPClient.METHOD_POST,"/UpdateToPublic",headers,game_key)
	else:
		$CopyKeyButton.show()
		$PublicButton.scale = Vector2(1, 1)
		$PublicButton.position = Vector2(650, 160)

func _on_private_button_toggled(toggled_on):
	if toggled_on:
		$GeneratedKeyLineEdit.text = game_key
		$PrivateButton.scale = Vector2(1.1, 1.1)
		$PrivateButton.position = Vector2(975, 155)
	else:
		$PrivateButton.scale = Vector2(1, 1)
		$PrivateButton.position = Vector2(980, 160)

# TODO: if player2 joins $Player2LineEdit.visible = true 
# TODO: else false !process(delta)!

