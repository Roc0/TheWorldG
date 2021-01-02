extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_loginButton_pressed():
	Client.client_app.say("Login!")
	var s = "TheWorldG"
	var ip = ""
	var port = 0
	var result = Client.client_app.login($LoginPanel/usernameEdit.text, $LoginPanel/passwordEdit.text, s, ip, port)

