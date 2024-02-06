extends Control

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

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene # TODO: was das

var id

func _ready():
	user_prefs = UserPreferences.load_or_create()

	if LobbyType.lobby_type == "HOST":
		host_lobby()

	if LobbyType.lobby_type == "JOIN_WITH_KEY":
		join_private()

	if LobbyType.lobby_enter_key == "JOIN":
		join_public()


func host_lobby():
	id = 1
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

	peer.create_server(9000)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player_card)
	add_player_card(id)

func join_private():
	#if LobbyType.lobby_enter_key == generated_game_key:
	id = 2
	httpActive = true
	join_private_lobby()
	while(httpActive): 
		await get_tree().create_timer(0.1).timeout
	
	#peer.create_client(str(ip), 9000)
	peer.create_client("127.0.0.1", 9000)
	multiplayer.multiplayer_peer = peer
	add_player_card(id)
	# TODO: falscher GameKey???

func join_public():
	id = 2
	httpActive = true
	join_public_lobby()
	while(httpActive): 
		await get_tree().create_timer(0.1).timeout
	
	#peer.create_client(str(ip), 9000)
	peer.create_client("127.0.0.1", 9000)
	multiplayer.multiplayer_peer = peer
	add_player_card(id)
	
	#else:
		# TODO: error msg
		#get_tree().change_scene_to_file("res://UI/play_menu.tscn")


#else:
	# TODO: error msg
	#get_tree().change_scene_to_file("res://UI/play_menu.tscn")

func _on_request_completed(result, response_code, headers, body):
	ip = body.get_string_from_utf8()
	httpActive = false

func _on_return_button_pressed():
	$ButtonClickSound.play()
	#exit_lobby(name.to_int())
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

	generated_game_key = "".join(code_array)

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

func add_player_card(id):
	#var player_card = player_scene.instantiate()
	#player_card.name = str(id)
	if id == 1:
		$Player1LineEdit.show()
		$Player1LineEdit.text = user_prefs.user_name
		if user_prefs.user_name == "":
			$Player1LineEdit.text = "Player1"
	if id == 2:
		$Player2LineEdit.show()
		$Player2LineEdit.text = user_prefs.user_name
		if user_prefs.user_name == "":
			$Player2LineEdit.text = "Player2"
	call_deferred("add_player_card")

func exit_lobby(id):
	multiplayer.peer_disconnected.connect(del_player)
	if id == 1:
		$Player1LineEdit.hide()
	if id == 2:
		$Player2LineEdit.hide()
	del_player(id)

func del_player(id):
	rpc("_del_player", id)

@rpc("any_peer", "call_local")
func _del_player(id):
	#get_node(str(id)).queue_free()
	pass

# TODO: wenn der Rest geht, UpdateToPublic, UpdateToPrivate !!! NUR HOST !!!
