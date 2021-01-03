extends Control

const STATE_LOGIN = 0
const STATE_AVATAR = 1
const STATE_WORLD = 2
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
		info("")
		$LoginPanel.show()
		$AvatarPanel.hide()
		get_node("../World").hide()
	elif state == STATE_AVATAR:
		game_state = state
		avatars_collected = false
		sel_avatar_id = 0
		$AvatarPanel/AccountNameLabel.text	= "Account: " + Client.account_name
		$AvatarPanel/AvatarNameLabel.text = ""
		sel_avatar_name = ""
		clear_avatar_list()
		$AvatarPanel/AvatarNameTextEdit.hide()
		$AvatarPanel/CreateButton.hide()
		$LoginPanel.hide()
		$AvatarPanel.show()
		get_node("../World").hide()
	elif state == STATE_WORLD:
		game_state = state
		$LoginPanel.hide()
		$AvatarPanel.hide()
		get_node("../World").show()

# Called when the node enters the scene tree for the first time.
func _ready():
	var result = Client.client_app.connect("login_success", self, "login_success", [])
	result = Client.client_app.connect("login_failed", self, "login_failed", [])
	result = Client.client_app.connect("server_closed", self, "server_closed", [])
	result = Client.client_app.connect("kicked_from_server", self, "kicked_from_server", [])
	result = Client.client_app.connect("update_avatars", self, "update_avatars", [])
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

	#if Client.client_app.get_app_mode() == ClientApp_AppMode_InitialMenu:
		#if client_app.get_login_status() == ClientApp_Login_NotDone:
		#elif client_app.get_login_status() == ClientApp_Login_Started:
		#elif client_app.get_login_status() == ClientApp_Login_Done:
	#elif Client.client_app.get_app_mode() == ClientApp_AppMode_World:

func _on_loginButton_pressed():
	var s = "TheWorld"
	var ip = ""
	var port = 0
	info("Login in progress ...")
	account_name = $LoginPanel/UsernameEdit.text
	var result = Client.client_app.login($LoginPanel/UsernameEdit.text, $LoginPanel/PasswordEdit.text, s, ip, port)

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

func _on_logoutButton_pressed():
	var result = Client.client_app.logout()
	Client.account_name = ""
	set_game_state(STATE_LOGIN)


func _on_EnterGameButton_pressed():
	pass # Replace with function body.


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
