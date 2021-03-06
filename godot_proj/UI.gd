extends Control

const STATE_LOGIN = 0
const STATE_AVATAR = 1
const STATE_WORLD = 2
const STATE_EDIT = 999

var game_state
var avatars_collected = false

var time_from_last_process = 0
const Time_Period_Process = 0.01	# 10 millisecond

var account_name = ""
var sel_avatar_name = ""
var sel_avatar_id = 0

func set_game_state(state):
	if state == STATE_LOGIN:
		game_state = state
		Client.client_app.set_app_mode(Client.ClientApp_AppMode_InitialMenu, false)
		info("")
		$LoginPanel.rect_size = get_viewport_rect().size
		$LoginPanel.show()
		$AvatarPanel.hide()
		$Message.rect_position.x = 10
		$Message.rect_position.y = get_viewport_rect().size.y - $Message.rect_size.y - 10
		get_node("../World").hide()
		get_node("../World/WorldLogoutButton").hide()
		if Client.debug_enabled:
			var d = get_node_or_null("../World/DebugText")
			if d != null:
				d.hide()
		#get_node("../World/CameraTest").mouse_mode = 0
	elif state == STATE_AVATAR:
		game_state = state
		Client.client_app.set_app_mode(Client.ClientApp_AppMode_InitialMenu, false)
		avatars_collected = false
		sel_avatar_id = 0
		$AvatarPanel/AccountNameLabel.text	= "Account: " + Client.account_name
		$AvatarPanel/AvatarNameLabel.text = ""
		$Message.rect_position.x = 10
		$Message.rect_position.y = get_viewport_rect().size.y - $Message.rect_size.y - 10
		sel_avatar_name = ""
		clear_avatar_list()
		$AvatarPanel/AvatarNameTextEdit.hide()
		$AvatarPanel/CreateButton.hide()
		$AvatarPanel.rect_size = get_viewport_rect().size
		$LoginPanel.hide()
		$AvatarPanel.show()
		get_node("../World").hide()
		get_node("../World/WorldLogoutButton").hide()
		if Client.debug_enabled:
			var d = get_node_or_null("../World/DebugText")
			if d != null:
				d.hide()
		#get_node("../World/CameraTest").mouse_mode = 0
	elif state == STATE_WORLD:
		game_state = state
		Client.client_app.set_app_mode(Client.ClientApp_AppMode_World, false)
		$LoginPanel.hide()
		$AvatarPanel.hide()
		$Message.rect_position.x = 10
		$Message.rect_position.y = get_viewport_rect().size.y - $Message.rect_size.y - 10
		var w = get_node("../World")
		w.show()
		OS.window_maximized = true
		var b = get_node("../World/WorldLogoutButton")
		b.show()
		b.rect_position.y = get_viewport_rect().size.y - b.rect_size.y - 10
		b.rect_position.x = get_viewport_rect().size.x - b.rect_size.x - 10
		if Client.debug_enabled:
			var d = get_node_or_null("../World/DebugText")
			if d != null:
				d.show()
				d.rect_position.y = 10
				d.rect_position.x = 10
		info("")
		w.enter_world()
	elif state == STATE_EDIT:
		game_state = state
		$LoginPanel.hide()
		$AvatarPanel.hide()
		$Message.rect_position.x = 10
		$Message.rect_position.y = get_viewport_rect().size.y - $Message.rect_size.y - 10
		var w = get_node("../World")
		w.show()
		OS.window_maximized = true
		var b = get_node("../World/WorldLogoutButton")
		b.rect_position.y = get_viewport_rect().size.y - b.rect_size.y - 10
		b.rect_position.x = get_viewport_rect().size.x - b.rect_size.x - 10
		b.hide()
		if Client.debug_enabled:
			var d = get_node_or_null("../World/DebugText")
			if d != null:
				d.show()
				d.rect_position.y = 10
				d.rect_position.x = 10
		info("")
		
		
		
func is_in_world_state() -> bool:
	return (game_state == STATE_WORLD)

# Called when the node enters the scene tree for the first time.
func _ready():
	var _result = get_tree().get_root().connect("size_changed", self, "resizing")
	
	_result = Client.client_app.connect("login_success", self, "login_success", [])
	_result = Client.client_app.connect("login_failed", self, "login_failed", [])
	_result = Client.client_app.connect("server_closed", self, "server_closed", [])
	_result = Client.client_app.connect("kicked_from_server", self, "kicked_from_server", [])

	_result = Client.client_app.connect("clear_entities", self, "clear_entities", [])
	_result = Client.client_app.connect("created_entity", self, "created_entity", [])
	_result = Client.client_app.connect("erase_entity", self, "erase_entity", [])
	_result = Client.client_app.connect("clear_avatars", self, "clear_avatars", [])
	_result = Client.client_app.connect("erase_avatar", self, "erase_avatar", [])


	_result = Client.client_app.connect("update_avatars", self, "update_avatars", [])
	_result = Client.client_app.connect("player_enter_space", self, "player_enter_space", [])
	_result = Client.client_app.connect("player_leave_space", self, "player_leave_space", [])
	_result = Client.client_app.connect("add_space_geomapping", self, "add_space_geomapping", [])
	if Client.edit_mode:
		set_game_state(STATE_EDIT)
	else:
		set_game_state(STATE_LOGIN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var do_process = false
	time_from_last_process += _delta
	if time_from_last_process > Time_Period_Process:
		time_from_last_process = 0
		do_process = true
	
	if !do_process:
		pass
	
	if game_state == STATE_AVATAR:
		if !avatars_collected:
			populate_avatar_list()
			
	#if game_state == STATE_WORLD:
	#	print("game_state: STATE_WORLD")

	#if Client.client_app.get_app_mode() == ClientApp_AppMode_InitialMenu:
		#if client_app.get_login_status() == ClientApp_Login_NotDone:
		#elif client_app.get_login_status() == ClientApp_Login_Started:
		#elif client_app.get_login_status() == ClientApp_Login_Done:
	#elif Client.client_app.get_app_mode() == ClientApp_AppMode_World:

func _input(event):
	#print("UI: " + event.as_text())
	# Shortcut for debug
	if event.is_action_pressed("ui_cancel"):
		if not is_in_world_state():
			get_tree().set_input_as_handled()
			quit_app()
	if event.is_action_pressed("ui_jump_to_world"):
		set_game_state(STATE_WORLD)
	if event.is_action_pressed("ui_toggle_fullscreen"):
		get_tree().set_input_as_handled()
		OS.window_fullscreen = !OS.window_fullscreen

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		quit_app()

func quit_app() -> void:
	if is_in_world_state():
		var w = get_node("../World")
		w.hide()
		w.exit_world()
		#warning-ignore:return_value_discarded
		logout_from_server()
		#set_game_state(STATE_LOGIN)
	info ("Quitting ...")
	get_tree().quit()

func _on_loginButton_pressed():
	var s = "TheWorld"
	var ip = ""
	var port = 0
	info("Login in progress ...")
	account_name = $LoginPanel/UsernameEdit.text
	var _result = Client.client_app.login($LoginPanel/UsernameEdit.text, $LoginPanel/PasswordEdit.text, s, ip, port)

func login_success():
	info("Login success")
	Client.account_name = account_name
	set_game_state(STATE_AVATAR)
	
func login_failed(fail_code):
	if fail_code == 20:
		err("Login failed! Server is starting, please wait!")
	else:
		err("Login failed (error=" + String(fail_code) + ")!")

func server_closed():
	err("Server closed unexpectedly!")
	set_game_state(STATE_LOGIN)

func kicked_from_server():
	err("Client kicked from server!")
	set_game_state(STATE_LOGIN)

func clear_entities():
	pass

func created_entity(_id, _player):
	pass

func erase_entity(_id):
	pass

func clear_avatars():
	pass

func erase_avatar(_id):
	pass

func clear_avatar_list():
	sel_avatar_id = 0
	$AvatarPanel/AvatarNameLabel.text = ""
	sel_avatar_name = ""
	for child in $AvatarPanel/AvatarList.get_children():
		child.queue_free()

func populate_avatar_list():
	clear_avatar_list()
	var avatar_count = Client.client_app.get_avatar_count()
	if (avatar_count > 0):
		avatars_collected = true
		var y = 0
		for i in range(0, avatar_count):
			var id = Client.client_app.get_avatar_id_by_idx(i)
			var name = Client.client_app.get_avatar_name_by_idx(i)
			#print("Avatar: (" + String(i) + ") - ID: " + String(id) + ", NAME: " + name)
			var button = AvatarButton.new(id, self)
			$AvatarPanel/AvatarList.add_child(button)
			button.toggle_mode = true
			button.text = name
			button.rect_size.x = 125
			button.rect_size.y = 35
			button.rect_position.y += y
			y += button.rect_size.y + 10
			button.connect("toggled", button, "_on_avatar_Button_toggled", [])
			if sel_avatar_id == 0:
				button._pressed()
				button.grab_focus()
			
class AvatarButton extends Button:
	var id
	var ui
	# warning-ignore:shadowed_variable
	# warning-ignore:shadowed_variable
	func _init(id, ui):
		self.id = id
		self.ui = ui
	func _pressed():
		#ui.sel_avatar_id = self.id
		pass
	func _on_avatar_Button_toggled(button_pressed):
		for child in get_parent().get_children():
			if child.id != self.id:
				if button_pressed:
					child.pressed = false
		var l = get_node("../../AvatarNameLabel")
		if button_pressed:
			l.text = "Avatar: " + self.text
			ui.sel_avatar_name = self.text
			ui.sel_avatar_id = self.id
		else:
			l.text = ""
			ui.sel_avatar_name = ""
			ui.sel_avatar_id = 0

func logout_from_server() -> bool:
	var result = Client.client_app.logout()
	Client.account_name = ""
	return result

func _on_logoutButton_pressed():
	if not is_in_world_state():
		var _result = logout_from_server()
		set_game_state(STATE_LOGIN)

func _on_EnterGameButton_pressed():
	if sel_avatar_id == 0:
		err("Please select an Avatar!")
	else:
		info("")
		var result = Client.client_app.enter_game(sel_avatar_id)
		if result:
			info("Entering game ...")
		else:
			err("Enter game failed!")

func _on_CreateAvatarButton_pressed():
	$AvatarPanel/AvatarNameTextEdit.show()
	$AvatarPanel/CreateButton.show()

func _on_RemoveAvatarButton_pressed():
	var avatarName = sel_avatar_name
	if avatarName == "":
		err("Please select an Avatar to remove!")
	else:
		info("")
		var result = Client.client_app.remove_avatar(avatarName)
		if result:
			info("Avatar " + avatarName + " succesfully removed!")
		else:
			err("Avatar " + avatarName + " not removed!")
		
func err(msg):
	$Message.add_color_override("font_color", Color(1,0,0))
	$Message.text = msg

func info(msg):
	$Message.add_color_override("font_color", Color(0,1,0))
	$Message.text = msg


func _on_CreateButton_pressed():
	var avatarName = $AvatarPanel/AvatarNameTextEdit.text
	if avatarName == "":
		err("Please specify the name of the Avatar to create!")
	else:
		info("")
		var result = Client.client_app.create_avatar(avatarName)
		if result:
			info("Avatar " + avatarName + " succesfully created!")
		else:
			err("Avatar " + avatarName + " not created!")

func update_avatars():
	avatars_collected = false

func player_enter_space(_space_id):
	set_game_state(STATE_WORLD)
		
func player_leave_space(_space_id):
	pass
	
func add_space_geomapping(_space_id, _res_path):
	pass


func _on_WorldLogoutButton_pressed():
	if is_in_world_state():
		#var n = get_node("/root/Main/World")
		#var a = n.get_children()
		#var s = a.size()
		#n = get_node("/root/Main/World/OtherEntities")
		#a = n.get_children()
		#s = a.size()
		
		var w = get_node("../World")
		w.exit_world()
		var _result = logout_from_server()
		set_game_state(STATE_LOGIN)

func resizing():
	#print("Resizing: ", get_viewport_rect().size)
	$Message.rect_position.x = 10
	$Message.rect_position.y = get_viewport_rect().size.y - $Message.rect_size.y - 10
	if game_state == STATE_LOGIN:
		$LoginPanel.rect_size = get_viewport_rect().size
	elif game_state == STATE_AVATAR:
		$AvatarPanel.rect_size = get_viewport_rect().size
	elif game_state == STATE_WORLD:
		var b = get_node("../World/WorldLogoutButton")
		b.rect_position.x = get_viewport_rect().size.x - b.rect_size.x - 10
		b.rect_position.y = get_viewport_rect().size.y - b.rect_size.y - 10
		if Client.debug_enabled:
			b = get_node_or_null("../World/DebugText")
			if b != null:
				b.rect_position.x = 10
				b.rect_position.y = 10
	elif game_state == STATE_EDIT:
		pass
