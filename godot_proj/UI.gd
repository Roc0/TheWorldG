extends Control

const STATE_LOGIN = 0
const STATE_AVATAR = 1
const STATE_WORLD = 2
var game_state
var avatars_collected = false

var time_from_last_process = 0
const Time_Period_Process = 0.01	# 10 millisecond

func set_game_state(state):
	if state == STATE_LOGIN:
		game_state = state
		$LoginPanel.show()
		$AvatarPanel.hide()
	elif state == STATE_AVATAR:
		game_state = state
		avatars_collected = false
		$AvatarPanel.hide()
		$AvatarPanel.show()
	#elif state == STATE_WORLD:

# Called when the node enters the scene tree for the first time.
func _ready():
	var result = Client.client_app.connect("login_success", self, "login_success", [])
	result = Client.client_app.connect("login_failed", self, "login_failed", [])
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
			var avatar_count = Client.client_app.get_avatar_count()
			if (avatar_count > 0):
				avatars_collected = true
				for i in range(0, avatar_count):
					var id = Client.client_app.get_avatar_id(i)
					var name = Client.client_app.get_avatar_name(i)
					print("Avatar: (" + String(i) + ") - ID: " + String(id) + ", NAME: " + name)
			

	#if Client.client_app.get_app_mode() == ClientApp_AppMode_InitialMenu:
		#if client_app.get_login_status() == ClientApp_Login_NotDone:
		#elif client_app.get_login_status() == ClientApp_Login_Started:
		#elif client_app.get_login_status() == ClientApp_Login_Done:
	#elif Client.client_app.get_app_mode() == ClientApp_AppMode_World:

func _on_loginButton_pressed():
	var s = "TheWorld"
	var ip = ""
	var port = 0
	$LoginPanel/Message.text = "Login in progress ..."
	var result = Client.client_app.login($LoginPanel/usernameEdit.text, $LoginPanel/passwordEdit.text, s, ip, port)

func login_success():
	$LoginPanel/Message.text = "Login success"
	set_game_state(STATE_AVATAR)
	
func login_failed(fail_code):
	if fail_code == 20:
		$LoginPanel/Message.text = "Login failed! Server is starting, please wait!"
	else:
		$LoginPanel/Message.text = "Login failed (error=" + String(fail_code) + ")!"
