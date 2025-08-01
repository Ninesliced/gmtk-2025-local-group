extends Node2D

func _ready() -> void:
	%HTTPRequestGetSeed.request_completed.connect(_on_get_seed_completed)
	%HTTPRequestGetLeaderboard.request_completed.connect(_on_get_leaderboard_completed)
	%HTTPRequestGetRank.request_completed.connect(_on_get_rank_completed)
	%HTTPRequestSubmit.request_completed.connect(_on_submit_completed)

func get_seed():
	%HTTPRequestGetSeed.request("http://laby.arkanyota.com/get_seed")

func submit():
	var data_to_send = {
		"h": "Heil Hit"
	}
	var json = JSON.stringify(data_to_send)
	var headers = ["Content-Type: application/json"]
	%HTTPRequestSubmit.request("http://laby.arkanyota.com/submit", headers, HTTPClient.METHOD_POST, json)


func _on_get_seed_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json["name"])

func _on_get_leaderboard_completed(result, response_code, headers, body):
	pass
	
func _on_get_rank_completed(result, response_code, headers, body):
	pass
	
func _on_submit_completed(result, response_code, headers, body):
	pass
