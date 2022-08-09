extends Node2D

var pos = Vector2(240,100)
var timer = 0
var tog = 0

func _ready():
	var file = File.new()
	file.open("res://serverconfig/data.json", File.READ)
	var json = JSON.parse(file.get_as_text())
	file.close()
	datas = json.result
	print(datas)
	$Text.text = "Please Choose server..."
	#_requestdata("ngrokip","")

var data
var ip
var path = OS.get_executable_path().get_base_dir()

var datas
var bedrock = false

func _requestdata(type,message):
	match type:
		"ngrokip":
			$Network.request("http://127.0.0.1:4040/api/tunnels")

func _sendmessage(type,message):
	match type:
		"serverstart":
			var text = ":signal_strength: A szerver éppen indul, kérlek legyetek türelmesek..."
			var messagee = {"content": "**" + text + "**"}
			$Discord.request("https://discord.com/api/webhooks/" + datas.webhook, ["content-type: application/json"], true, HTTPClient.METHOD_POST, JSON.print(messagee))
		"image":
			var messagee = {"content": datas.imageurl}
			$Discord.request("https://discord.com/api/webhooks/" + datas.webhook, ["content-type: application/json"], true, HTTPClient.METHOD_POST, JSON.print(messagee))
		"serverinfo":
			var iptext
			if bedrock:
				iptext = "JAVA/BEDROCK SZERVER IP: "
			else:
				iptext = "SZERVER IP: "
			var messagee = {"content": "**" + ":white_check_mark: Szerver Online\n" + iptext + message + "\n" + datas.version + "**"}
			$Discord.request("https://discord.com/api/webhooks/" + datas.webhook, ["content-type: application/json"], true, HTTPClient.METHOD_POST, JSON.print(messagee))
		"serverclose":
			var text = ":x: Szerver Offline"
			var messagee = {"content": "**" + text + "**"}
			$Discord.request("https://discord.com/api/webhooks/" + datas.webhook, ["content-type: application/json"], true, HTTPClient.METHOD_POST, JSON.print(messagee))

func _on_Network_request_completed( result, response_code, headers, body ):
	var json = JSON.parse(body.get_string_from_utf8())
	data = json.result
	ip = data.tunnels[0].public_url
	ip.erase(0, 6)
	_sendmessage("serverinfo",str(ip))
	print(data)

func _process(delta):
	serverstart(delta)
	_Animation(delta)

var steps = 0

func _on_Left_pressed():
	match steps:
		0:
			OS.shell_open(path + "/serverconfig/ngrok.bat")
			$Left.hide()
			$Right.hide()
			$Close.hide()
			$Middle.show()
			$Middle.text = "NGROK IP cím lekérése"
			$Text.text = ""
			steps = 1

func _on_Right_pressed():
	match steps:
		0:
			if datas.bedrock:
				bedrock = true
			OS.shell_open(path + "/serverconfig/playit.exe")
			ip = datas.ip
			$Left.hide()
			$Right.hide()
			$Close.hide()
			$Middle.show()
			$Middle.text = "Szerver indítása"
			$Text.text = ""
			steps = 2

func _on_Middle_pressed():
	match steps:
		1:
			_requestdata("ngrokip","")
			$Left.hide()
			$Right.hide()
			$Middle.show()
			$Middle.text = "Szerver indítása"
			steps = 2
		2:
			OS.shell_open(path + "/start.bat")
			_sendmessage("serverstart","")
			$Left.hide()
			$Right.hide()
			$Middle.show()
			$Middle.text = "A szerver készen áll!"
			steps = 3
		3:
			$Middle.text = "Bezárás"
			messagetimer = 1
			_sendmessage("image","")
			steps = 4
		4:
			get_tree().quit()

var messagetimer = 0
var messageboolean = false

func serverstart(delta):
	if messagetimer > 0 and !messageboolean:
		messageboolean = true
	elif messagetimer > 0:
		messagetimer -= 1 * delta
	elif messagetimer <= 0 and messageboolean:
		messageboolean = false
		_sendmessage("serverinfo",ip)
	

func _Animation(delta):
	$Logo.position = $Logo.position.linear_interpolate(pos,5 * delta)
	$Logo.scale.x = lerp($Logo.scale.x, 1,10 * delta)
	$Logo.scale.y = lerp($Logo.scale.y, 1,10 * delta)
	$Logo.rotation_degrees = lerp($Logo.rotation_degrees, 0,10 * delta)
	timer += 1.8 * delta
	if timer > 1 and tog == 0:
		tog = 1
		timer = 0
		$Logo.position += Vector2(rand_range(-5,5),rand_range(-5,5))
		$Logo.scale.x += 0.01
		$Logo.scale.y -= 0.005
		$Logo.rotation_degrees += 2
	elif timer > 1 and tog == 1:
		tog = 2
		timer = 0
		$Logo.position += Vector2(rand_range(-5,5),rand_range(-5,5))
		$Logo.scale.x -= 0.005
		$Logo.scale.y += 0.01
		$Logo.rotation_degrees -= 2
	elif timer > 1 and tog == 2:
		tog = 3
		timer = 0
		$Logo.position += Vector2(rand_range(-5,5),rand_range(-5,5))
		$Logo.scale.x += 0.01
		$Logo.scale.y -= 0.005
		$Logo.rotation_degrees -= 2
	elif timer > 1 and tog == 3:
		tog = 0
		timer = 0
		$Logo.position += Vector2(rand_range(-5,5),rand_range(-5,5))
		$Logo.scale.x -= 0.005
		$Logo.scale.y += 0.01
		$Logo.rotation_degrees += 2



func _on_Close_pressed():
	$Left.hide()
	$Right.hide()
	$Middle.show()
	$Close.hide()
	$Middle.text = "Bezárás"
	_sendmessage("serverclose",ip)
	steps = 4
