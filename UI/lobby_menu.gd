extends Control
var first_toggle = true
var user_prefs: UserPreferences

enum Fractions {
	STARSERAPHS,
	OLYMPUS,
	DARKTEMPLARS
}
var chosen_fraction

var generated_game_key
var ip

var httpActive : bool = false;

func _ready():
	Lobby.connect("player_connected", show_player_line_edit)
	Lobby.connect("player_disconnected", hide_player_line_edit)
	Lobby.connect("server_disconnected", server_disconnected_return)

	user_prefs = UserPreferences.load_or_create()
	Lobby.player_info["name"] = user_prefs.user_name
	
	#Quasi die UI Buttons
	if LobbyType.lobby_type == "HOST": 
		host_lobby()

	if LobbyType.lobby_type == "JOIN_WITH_KEY":
		join_private()

	if LobbyType.lobby_type == "JOIN":
		join_public()


func host_lobby():
	# Host IP Adresse
	httpActive = true
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("https://api.ipify.org")
	while(httpActive): 
		await get_tree().create_timer(0.1).timeout
		
	_generate_code()
	$PublicButton.disabled = false
	$PrivateButton.disabled = false
	$PrivateButton.button_pressed = true
	$CopyKeyButton.show()
	
	httpActive = true
	create_private_lobby()
	while(httpActive): 
		await get_tree().create_timer(0.1).timeout
	# TODO: lobby manager
	Lobby.create_game()

func join_private():
	httpActive = true
	join_private_lobby()
	while(httpActive): 
		await get_tree().create_timer(0.1).timeout
	#Lobby.join_game()
	# TODO: DEFAULT_IP
	Lobby.join_game(str(ip))

func join_public():
	httpActive = true
	join_public_lobby()
	while(httpActive): 
		await get_tree().create_timer(0.1).timeout
	#Lobby.join_game()
	# TODO: DEFAULT_IP
	Lobby.join_game(str(ip))

func _on_request_completed(result, response_code, headers, body):
	ip = body.get_string_from_utf8()
	httpActive = false

func _on_return_button_pressed():
	$ButtonClickSound.play()
	if LobbyType.lobby_type == "HOST": 
		Lobby.remove_multiplayer_peer()
	get_tree().change_scene_to_file("res://UI/play_menu.tscn")

func _on_return_button_mouse_entered():
	$ButtonHoverSound.play()

func _on_game_start_button_pressed():
	$ButtonClickSound.play()

func _on_game_start_button_mouse_entered():
	$ButtonHoverSound.play()

func _on_game_start_button_toggled(toggled_on):
	if toggled_on:
		$GameStartButton.text = "Ready!"
		Lobby.player_info["fraction"] = chosen_fraction
		$PublicButton.disabled = true
		$PrivateButton.disabled = true
		$CopyKeyButton.disabled = true
		if chosen_fraction == Fractions.DARKTEMPLARS:
			$ChooseFraction/ChooseStarSeraphsButton.disabled = true
			$ChooseFraction/ChooseOlympusButton.disabled = true
		if chosen_fraction == Fractions.STARSERAPHS:
			$ChooseFraction/ChooseDarkTemplarsButton.disabled = true
			$ChooseFraction/ChooseOlympusButton.disabled = true
		if chosen_fraction == Fractions.OLYMPUS:
			$ChooseFraction/ChooseStarSeraphsButton.disabled = true
			$ChooseFraction/ChooseDarkTemplarsButton.disabled = true
	else:
		$GameStartButton.text = "Ready?"
		$PublicButton.disabled = false
		$PrivateButton.disabled = false
		$CopyKeyButton.disabled = false
		$ChooseFraction/ChooseDarkTemplarsButton.disabled = false
		$ChooseFraction/ChooseStarSeraphsButton.disabled = false
		$ChooseFraction/ChooseOlympusButton.disabled = false

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

	generated_game_key = "".join(code_array)

func _on_copy_key_button_pressed():
	$ButtonClickSound.play()
	DisplayServer.clipboard_set($GeneratedKeyLineEdit.text)

func _on_copy_key_button_mouse_entered():
	$ButtonHoverSound.play()

func _on_public_button_toggled(toggled_on):
	if toggled_on:
		var urlparam = "https://valtonlobbycontainer.trueberryless.org/Lobby/UpdateToPublic?lobbyCode="+str(generated_game_key)
		$HTTPRequest.request(urlparam, [], HTTPClient.METHOD_POST, "")
		httpActive = false
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
		if not first_toggle:
			var urlparam = "https://valtonlobbycontainer.trueberryless.org/Lobby/UpdateToPrivate?lobbyCode=" + str(generated_game_key)
			$HTTPRequest.request(urlparam, [], HTTPClient.METHOD_POST, "")
			httpActive = false
		else:
			# Falls es der erste Toggle ist, setzen Sie die Variable auf False
			first_toggle = false
		$GeneratedKeyLineEdit.text = generated_game_key
		$PrivateButton.scale = Vector2(1.1, 1.1)
		$PrivateButton.position = Vector2(965, 155)
	else:
		$PrivateButton.scale = Vector2(1, 1)
		$PrivateButton.position = Vector2(980, 160)

func create_private_lobby():
	var urlparam = "https://valtonlobbycontainer.trueberryless.org/Lobby/StartSession?hostAddress="+str(ip)+"&lobbyCode="+str(generated_game_key)
	$HTTPRequest.request(urlparam, [], HTTPClient.METHOD_POST, "")
	httpActive = false
	
func join_private_lobby():
	$HTTPRequest.request_completed.connect(_on_private_request_completed)
	$HTTPRequest.request("https://valtonlobbycontainer.trueberryless.org/Lobby/JoinSessionWithCode?lobbyCode="+str(LobbyType.lobby_enter_key))
	
func _on_private_request_completed(result, response_code, headers, body):
	ip = body.get_string_from_utf8()
	httpActive = false
	
func join_public_lobby():
	$HTTPRequest.request_completed.connect(_on_public_request_completed)
	$HTTPRequest.request("https://valtonlobbycontainer.trueberryless.org/Lobby/JoinSession")
	httpActive = false
	

func _on_public_request_completed(result, response_code, headers, body):
	ip = body.get_string_from_utf8()
	httpActive = false


func show_player_line_edit(peer_id, player_info):
	if peer_id == 1:
		$Player1LineEdit.show()
		$Player1LineEdit.text = player_info["name"]
	elif peer_id != 1:
		$Player2LineEdit.show()
		$Player2LineEdit.text = player_info["name"]


func hide_player_line_edit(peer_id):
	if peer_id == 1:
		$Player1LineEdit.hide()
	elif peer_id != 1:
		$Player2LineEdit.hide()

func server_disconnected_return():
	get_tree().change_scene_to_file("res://UI/play_menu.tscn")
