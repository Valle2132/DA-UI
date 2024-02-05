extends Control

var user_prefs: UserPreferences

enum Fractions {
	STARSERAPHS,
	OLYMPUS,
	DARKTEMPLARS
}
var chosen_fraction

var game_key
var ip

var httpActive : bool = false;

func _ready():
	#TODO !!!!!! if LobbyType.lobby_owner macht unterschiedliche Dinge mit Networking!!!
	
	_generate_code()
	
	user_prefs = UserPreferences.load_or_create()
	$Player1LineEdit.text = user_prefs.user_name
	if user_prefs.user_name == "":
		$Player1LineEdit.text = "Player1"
	# TODO: peer host entity

	httpActive = true
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("https://api.ipify.org")
	while(httpActive): 
		await get_tree().create_timer(0.1).timeout
	
	$PrivateButton.button_pressed = true


func _on_request_completed(result, response_code, headers, body):
	ip = body.get_string_from_utf8()
	httpActive = false

func _on_return_button_pressed():
	$ButtonClickSound.play()
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

func _on_copy_key_button_pressed():
	$ButtonClickSound.play()
	DisplayServer.clipboard_set($GeneratedKeyLineEdit.text)

func _on_copy_key_button_mouse_entered():
	$ButtonHoverSound.play()

func _on_public_button_toggled(toggled_on):
	if toggled_on:
		$CopyKeyButton.hide()
		$GeneratedKeyLineEdit.text = ""
		$PublicButton.scale = Vector2(1.1, 1.1)
		$PublicButton.position = Vector2(635, 155)
	else:
		$CopyKeyButton.show()
		$PublicButton.scale = Vector2(1, 1)
		$PublicButton.position = Vector2(650, 160)

func _on_private_button_toggled(toggled_on):
	if toggled_on:
		$GeneratedKeyLineEdit.text = game_key

		httpActive = true
		create_private_lobby()
		while(httpActive): 
			await get_tree().create_timer(0.1).timeout

		$PrivateButton.scale = Vector2(1.1, 1.1)
		$PrivateButton.position = Vector2(965, 155)
	else:
		$PrivateButton.scale = Vector2(1, 1)
		$PrivateButton.position = Vector2(980, 160)

func create_private_lobby():
	var urlparam = "https://valtonlobbycontainer.trueberryless.org/Lobby/StartSession?hostAddress="+str(ip)+"&lobbyCode="+str(game_key)
	#var urlparam = "http://localhost:5077/Lobby/StartSession?hostAddress="+str(ip)+"&lobbyCode="+str(game_key)
	$HTTPRequest.request(urlparam, [], HTTPClient.METHOD_POST, "")
	httpActive = false
